// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package main

import (
	"errors"
	"io/ioutil"
	"net/http"
	"strings"
	"time"

	"github.com/Jeffail/gabs/v2"
	"github.com/google/uuid"
	"github.com/ua-parser/uap-go/uaparser"
	"go.uber.org/zap"

	"doppler-video-telemetry/code/internal/web"

	v2 "doppler-video-telemetry/code/internal/v2"
)

// test to trigger build
func healthcheck(r *http.Request) *web.Response {
	if time.Since(kinesisDownTS).Minutes() >= 10 {
		return web.Empty(http.StatusOK)
	} else {
		return web.Empty(http.StatusServiceUnavailable)
	}
}

func processData(r *http.Request) *web.Response {
	env := getEnvironment()
	traceID := uuid.New()
	startTime := time.Now()
	ua := r.UserAgent()
	logger := logger.With(zap.String("traceID", traceID.String()))

	// Record an end time
	defer endTrace(logger, startTime)

	// log the request.start
	logger.With("duration", time.Since(startTime).String(), "method", r.Method, "uri", r.RequestURI, "evt", "request.start").Debug()

	// Run standard validations, if there are any issues, return them to the client
	if err := web.ValidateRequest(r, logger, statsdClient, metricsPrefix, &traceID, startTime); err != nil {
		return web.DataJSON(http.StatusBadRequest, err.Error(), nil)
	}

	//Parse UserAgent for Browser and Device information
	browserName, browserVersion, operatingSystem, osVersion, device, deviceBrandName, model := ParseUserAgent(ua)

	//parse/validate input
	defer r.Body.Close()
	bits, err := ioutil.ReadAll(r.Body)
	if err != nil {
		logger.Error("reading body", err)
		statsdClient.Increment(metricsPrefix + "-UnableToReadBody")
		return web.DataJSON(http.StatusBadRequest, "unable to read body", nil)
	}

	logger.With("duration", time.Since(startTime).String()).Debug("passed validations")
	logger.With("duration", time.Since(startTime).String(), "HTTP Data In", string(bits)).Debug()

	jsonPayload, err := gabs.ParseJSON(bits)
	if err != nil {
		logger.Errorw("Could not decode request body", "duration", time.Since(startTime).String(), "error", err)
		statsdClient.Increment(metricsPrefix + "-UnableToDecodeBody")
		return web.DataJSON(http.StatusBadRequest, "unable to parse body", nil)
	}

	for _, event := range jsonPayload.Children() {

		//Validate if certain event payload fields are not empty or missing
		err := validateFields(event)
		if err != nil {
			logger.Warn(err)
			statsdClient.Increment(metricsPrefix + "-FailedSimpleValidation")
			return web.Empty(http.StatusBadRequest)
		}

		// Grab ession id to pass in as our hash.  We should have at least one.  if we have both use sessionId
		sessionId := ""
		if event.Path("session.sessionId") != nil {
			sessionId = event.Path("session.sessionId").Data().(string)
		}

		kinesisData, responseError := v2.PrepareKinesisRecord(env, event, logger, getEnableEncrpytion(), v2.GetIP(r), browserName, browserVersion, operatingSystem, osVersion, device, deviceBrandName, model, getAWSRegion(), sessionId)
		if responseError != nil {
			logger.Warn("error in marshalling struct to json", responseError)
			return web.Empty(http.StatusBadRequest)
		}

		logger.With("duration", time.Since(startTime).String(), "Kinesis Data In", string(kinesisData)).Debug()

		//write to kpl to send to kinesis
		logger.Debugw("sending to Kinesis", "duration", time.Since(startTime).String())

		err = kpl.PutRecord(string(kinesisData))
		if err != nil {
			logger.Warnf("kpl.PutRecord error %v", err)
		}
	}
	return web.Empty(http.StatusCreated)
}

func endTrace(logger *zap.SugaredLogger, startTime time.Time) {
	logger.With("duration", time.Since(startTime).String(), "evt", "request.end").Debug()

	endTime := time.Now()

	duration := int64(endTime.Sub(startTime) / time.Millisecond)
	statsdClient.Timing(metricsPrefix+"-Timer", duration)
}

// ParseUserAgent can parse different sections of the user agent in the request. Reference uaparser Go library for more options.
func ParseUserAgent(userAgent string) (string, string, string, string, string, string, string) {
	parser, err := uaparser.New("./regexes.yaml")
	if err != nil {
		logger.Error(err)
	}
	client := parser.Parse(userAgent)
	browserName := client.UserAgent.Family
	browserVersion := client.UserAgent.Major + "." + client.UserAgent.Minor + "." + client.UserAgent.Patch
	browserVersion = strings.Trim(browserVersion, ".")

	operatingSystem := client.Os.Family
	device := client.Device.Family
	deviceBrandName := client.Device.Brand
	model := client.Device.Model

	//get OS version
	osMajorVersion := client.Os.Major
	osMinorVersion := client.Os.Minor
	osMinorPatch := client.Os.Patch
	osPatchMinor := client.Os.PatchMinor
	osVersion := osMajorVersion + "." + osMinorVersion + "." + osMinorPatch + "." + osPatchMinor
	osVersion = strings.Trim(osVersion, ".")

	return browserName, browserVersion, operatingSystem, osVersion, device, deviceBrandName, model
}

func validateFields(event *gabs.Container) (err error) {
	eventName := event.Path("eventName").String()
	eventType := event.Path("eventType").String()
	sessionId := event.Path("session.sessionId").String()

	//Checks if len is 2 because a String of "" == 2 and should be treated as a blank string
	if event.Path("eventName") == nil || eventName == "\"null\"" || eventName == "\"nil\"" || len(eventName) == 2 {
		return errors.New("missing or invalid value for field: eventName")
	}

	if event.Path("eventType") == nil || eventType == "\"null\"" || eventType == "\"nil\"" || len(eventType) == 2 {
		return errors.New("missing or invalid value for field: eventType")
	}

	// if we do have a sessionId, verify it's greater than 30 characters
	if event.Path("session.sessionId") != nil && len(sessionId) < 30 {
		return errors.New("session.sessionId is less than 30 characters")
	}

	return nil
}
