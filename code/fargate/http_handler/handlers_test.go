// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package main

import (
	"fmt"
	"testing"

	"github.com/Jeffail/gabs/v2"
)

func Test_ParseUserAgent(t *testing.T) {
	userAgent := "Mozilla/5.0 (iPad; CPU OS 14_7_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.2 Mobile/15E148 Safari/604.1"
	browserName, browserVersion, operatingSystem, osVersion, device, brand, model := ParseUserAgent(userAgent)

	if browserName != "Mobile Safari" {
		t.Errorf("Test_ParseUserAgent failed, expected %v, got %v", "Mobile Safari", browserName)
	}

	if browserVersion != "14.1.2" {
		t.Errorf("Test_ParseUserAgent failed, expected %v, got %v", "14.1.2", browserVersion)
	}

	if operatingSystem != "iOS" {
		t.Errorf("Test_ParseUserAgent failed, expected %v, got %v", "iOS", operatingSystem)
	}

	if osVersion != "14.7.1" {
		t.Errorf("Test_ParseUserAgent failed, expected %v, got %v", "14.7.1", osVersion)
	}

	if device != "iPad" {
		t.Errorf("Test_ParseUserAgent failed, expected %v, got %v", "iPad", device)
	}

	if brand != "Apple" {
		t.Errorf("Test_ParseUserAgent failed, expected %v, got %v", "Apple", brand)
	}
	//Model and device are both equal to "iPad"
	if model != "iPad" {
		t.Errorf("Test_ParseUserAgent failed, expected %v, got %v", "iPad", model)
	}
}

func Test_ParseUserAgentWithEmptyFields(t *testing.T) {
	userAgent := "Mozilla/5.0 (X11; CrOS x86_64 13904.97.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.167 Safari/537.36"
	browserName, browserVersion, operatingSystem, osVersion, device, brand, model := ParseUserAgent(userAgent)

	if browserName != "Chrome" {
		t.Errorf("Test_ParseUserAgent failed, expected %v, got %v", "Chrome", browserName)
	}

	if browserVersion != "91.0.4472" {
		t.Errorf("Test_ParseUserAgent failed, expected %v, got %v", "91.0.4472", browserVersion)
	}

	if operatingSystem != "Chrome OS" {
		t.Errorf("Test_ParseUserAgent failed, expected %v, got %v", "Chrome OS", operatingSystem)
	}

	if osVersion != "13904.97.0" {
		t.Errorf("Test_ParseUserAgent failed, expected %v, got %v", "13904.97.0", osVersion)
	}

	if device != "Other" {
		t.Errorf("Test_ParseUserAgent failed, expected %v, got %v", "Other", device)
	}

	if brand != "" {
		t.Errorf("Test_ParseUserAgent failed, expected %v, got %v", "a blank string", brand)
	}

	if model != "" {
		t.Errorf("Test_ParseUserAgent failed, expected %v, got %v", "a blank string", model)
	}
}

func Test_ValidateFields_MissingEventName(t *testing.T) {
	jsonParsed, err := gabs.ParseJSON([]byte(`{
		"eventType":"test"		
	}`))
	if err != nil {
		t.Errorf(err.Error())
	}
	validationErr := validateFields(jsonParsed)
	if validationErr != nil {
		fmt.Println("Test Pass with following error: ", validationErr)
	} else {
		t.Errorf("All checked passed. Test Failed")
	}
}

func Test_ValidateFields_MissingEventType(t *testing.T) {
	jsonParsed, err := gabs.ParseJSON([]byte(`{
		"eventName":"test"
	}`))
	if err != nil {
		t.Errorf(err.Error())
	}
	validationErr := validateFields(jsonParsed)
	if validationErr != nil {
		fmt.Println("Test Pass with following error: ", validationErr)
	} else {
		t.Errorf("All checked passed. Test Failed")
	}
}

func Test_ValidateFields_MissingSession(t *testing.T) {
	jsonParsed, err := gabs.ParseJSON([]byte(`{
	}`))
	if err != nil {
		t.Errorf(err.Error())
	}
	validationErr := validateFields(jsonParsed)
	if validationErr != nil {
		fmt.Println("Test Pass with following error: ", validationErr)
	} else {
		t.Errorf("All checked passed. Test Failed")
	}
}

func Test_ValidateFields_SessionLessThan(t *testing.T) {
	jsonParsed, err := gabs.ParseJSON([]byte(`{
		"session": {
            "sessionId": "y345"
        },
		"eventName":"test",
		"eventType":"test"
	}`))
	if err != nil {
		t.Errorf(err.Error())
	}
	validationErr := validateFields(jsonParsed)
	if validationErr != nil {
		fmt.Println("Test Pass with following error: ", validationErr)
	} else {
		t.Errorf("All checked passed. Test Failed")
	}
}

func Test_ValidateFields_SessionHappy(t *testing.T) {
	jsonParsed, err := gabs.ParseJSON([]byte(`{
		"session": {
            "sessionId": "1111111111111111111111111111111"
        },
		"eventName":"test",
		"eventType":"test"
	}`))
	if err != nil {
		t.Errorf(err.Error())
	}
	validationErr := validateFields(jsonParsed)
	if validationErr != nil {
		t.Errorf("Found error when there shouldn't be one. Test Failed")
	}
}
