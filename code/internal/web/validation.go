// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package web

import (
	"io/ioutil"
	"mime"
	"net/http"
	"strings"
	"time"

	statsd "github.com/etsy/statsd/examples/go"
	"github.com/google/uuid"

	"github.com/pkg/errors"

	"doppler-video-telemetry/code/pkg/log"
)

func ValidateRequest(r *http.Request,
	logger *log.Logger,
	statsdClient *statsd.StatsdClient,
	metricsPrefix string,
	traceID *uuid.UUID,
	startTime time.Time) error {
	mediaType, params, err := mime.ParseMediaType(r.Header.Get("Content-type"))
	if err != nil {
		incrementStatDCounter(statsdClient, metricsPrefix, "-MissingMediaType")
		logger.Error("error parsing media type", err)
		return errors.Wrap(err, "error parsing media type")
	}

	charset := params["charset"]
	if charset == "" {
		charset = "utf-8"
	}
	if mediaType != "application/json" || strings.ToLower(charset) != "utf-8" {
		incrementStatDCounter(statsdClient, metricsPrefix, "-UnsupportedMediaType")
		logger.Warnf("unsupported media type: %s", mediaType)
		return errors.New("unsupported media type")
	}

	// interrogate user agent header
	userAgent := r.UserAgent()
	logger.With("traceID", traceID, "duration", time.Since(startTime).String(), "User Agent", userAgent).
		Debugw("parsed User-Agent")
	if userAgent == "" {
		logger.Warn("missing User Agent")
		incrementStatDCounter(statsdClient, metricsPrefix, "-MissingUserAgent")
	}

	// Googlebot
	if strings.Contains(userAgent, "Googlebot") == true {
		logger.Warn("found Googlebot in user agent")
		incrementStatDCounter(statsdClient, metricsPrefix, "-IsGooglebot")
		return errors.New("unsupported useragent")
	}

	// AdsBot-Google
	if strings.Contains(userAgent, "AdsBot-Google") == true {
		logger.Warn("found AdsBot-Google in user agent")
		incrementStatDCounter(statsdClient, metricsPrefix, "-IsAdsBot-Google")
		return errors.New("unsupported useragent")
	}

	//validate the content size
	if r.ContentLength < 1 {
		logger.Warnf("payload too small: %v", r.ContentLength)
		incrementStatDCounter(statsdClient, metricsPrefix, "-TooSmallPayload")
		return errors.New("invalid ContentLength")
	}

	// log body if too large
	if r.ContentLength > int64(getPayloadLimit()) {
		logger.Warnf("payload too large: %v", r.ContentLength)
		incrementStatDCounter(statsdClient, metricsPrefix, "-TooLargePayload")
		if displayPayloadOnError() {
			printResponseBody(r, logger)
		}
		return errors.New("invalid ContentLength")
	}

	return nil
}

func printResponseBody(r *http.Request, logger *log.Logger) {
	defer r.Body.Close()
	bits, err := ioutil.ReadAll(r.Body)
	logger.Warnf("payload body: %s", string(bits))
	if err != nil {
		logger.Error("reading body", err) // Log error but don't do anything because we are already failing things
	}
}

func incrementStatDCounter(statsdClient *statsd.StatsdClient, metricsPrefix, metric string) {
	if statsdClient != nil {
		statsdClient.Increment(metricsPrefix + metric)
	}
}
