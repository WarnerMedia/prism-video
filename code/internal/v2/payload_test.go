// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package v2

import (
	"math/big"
	"strconv"
	"testing"
	"time"

	"doppler-video/pkg/log"

	"github.com/Jeffail/gabs/v2"
	"github.com/google/uuid"
)

func Test_PrepareKinesisRecord(t *testing.T) {
	logger := log.New()
	env := "test"
	sourceIpAddress := "44.123.4.125"
	browserName := "Chrome"
	browserVersion := "2"
	operatingSystem := "Windows"
	osVersion := "2"
	device := "iPad"
	deviceBrandName := "Apple"
	model := "other"
	sessionId := "71f456bb-df93-4dc5-b7a1-a72a85f34fbb2022-02-10T15:20:20.005Z"
	exampleJson := []byte(`[{
		"eventId": "1234c-85c6-401b-8da0-0a01ab6a11b8-2",
		"eventName": "mediaStarting",
		"eventTimestamp": "2022-06-30T12:00:26.643Z",
		"eventType": "VideoQoS",
		"receivedAtTimestamp": 1656590428,
		"kdsHashKey": 1.729709657569941e+38,
  		"receivedAtTimestampString": "2022-06-30T12:00:28.575"
	}]`)
	expectedBrowserName := `"chrome"`
	jsonPayload, err := gabs.ParseJSON(exampleJson)
	if err != nil {
		t.Errorf("Failed %v", err)
	}

	for _, event := range jsonPayload.Children() {

		//Generate message payload
		kinesisData, responseError := PrepareKinesisRecord(env, event, logger, "false", sourceIpAddress, browserName, browserVersion, operatingSystem, osVersion, device, deviceBrandName, model, "us-east-1", sessionId)
		if responseError != nil {
			t.Errorf("Failed: %v", responseError)
		}

		receivedJson, err := gabs.ParseJSON(kinesisData)
		if err != nil {
			t.Errorf("Failed %v", err)
		}
		t.Logf("received JSON: %v", receivedJson.StringIndent("", "  "))

		//Grab the values from the generated message, and compare it to the expected values.
		receivedBrowserNameValue := receivedJson.Search("backendUserAgentParser", "browserName").String()
		if receivedBrowserNameValue != expectedBrowserName {
			t.Logf("expectedBrowserName: %v and receivedBrowserNameValue: %v", expectedBrowserName, receivedBrowserNameValue)
			t.Errorf("Failed: A received value was not equal to the expected value.")
		}
	}
}

func Test_EncryptSensitiveFields(t *testing.T) {
	logger := log.New()
	//Fake key used for testing only
	key := "4c13c15b62e7fb09ac3462596500bkg2"
	exampleJson := []byte(`{
		"sessionId": "71f456bb-df93-4dc5-b7a1-a72a85f34fbb2022-02-10T15:20:20.005Z",
		"ipAddress": "12.345.6.789"
    }`)
	jsonPayload, err := gabs.ParseJSON(exampleJson)
	if err != nil {
		t.Errorf("Failed %v", err)
	}
	expectedSessionID, _ := jsonPayload.Path("sessionId").Data().(string)
	expectedIPAddress, _ := jsonPayload.Path("ipAddress").Data().(string)

	//encrypt the payload
	encryptedFields, err := encryptSensitiveFields(jsonPayload, logger, key)
	if err != nil {
		t.Errorf("Failed: %v", err)
	}

	sessionId := []byte(encryptedFields.Path("sessionId").Data().(string))
	ipAddress := []byte(encryptedFields.Path("ipAddress").Data().(string))
	decryptSessionID := decrypt(sessionId, key)
	decryptIPAdddress := decrypt(ipAddress, key)

	//After decryption, check if the value returns back to its original form.
	if string(decryptSessionID) != expectedSessionID {
		t.Errorf("Failed: decryptSessionID (%v) is not equal to expectedSessionID (%v).", decryptSessionID, expectedSessionID)
	} else if string(decryptKruxID) != expectedKruxID {
		t.Errorf("Failed: decryptIPAddress (%v) is not equal to expectedIPAddress (%v).", decryptIPAdddress, expectedIPAddress)
	}
}

func Test_BasicStringHashCode(t *testing.T) {

	stringToHash := "71f456bb-df93-4dc5-b7a1-a72a85f34fbb2022-02-10T15:20:20.005Z"
	expectedHash, res := new(big.Int).SetString("194918076778830153406870488784473757983", 10)
	if res != true {
		t.Errorf("Failed to create big int from string")
	}

	resultHash, err := stringHashCode(stringToHash)
	if err != nil {
		t.Errorf("Failed to hash (%v)", stringToHash)
	}

	if resultHash.Cmp(expectedHash) != 0 {
		t.Errorf("Failed: resultHash (%v) is not equal to expectedHash (%v).", resultHash, expectedHash)
	}

	stringToHash = "bc174edc-a6c9-4f6f-b44a-dd5608a88f702022-02-14T16:41:06.105Z"
	expectedHash, res = new(big.Int).SetString("233679631938665420612366265284839939158", 10)
	if res != true {
		t.Errorf("Failed to create big int from string")
	}

	resultHash, err = stringHashCode(stringToHash)
	if err != nil {
		t.Errorf("Failed to hash (%v)", stringToHash)
	}

	if resultHash.Cmp(expectedHash) != 0 {
		t.Errorf("Failed: resultHash (%v) is not equal to expectedHash (%v).", resultHash, expectedHash)
	}

	stringToHash = ""
	expectedHash = big.NewInt(0)
	if res != true {
		t.Errorf("Failed to create big int from string")
	}

	resultHash, err = stringHashCode(stringToHash)
	if err != nil {
		t.Errorf("Failed to hash (%v)", stringToHash)
	}

	if resultHash.Cmp(expectedHash) != 0 {
		t.Errorf("Failed: resultHash (%v) is not equal to expectedHash (%v).", resultHash, expectedHash)
	}

	stringToHash = "0"
	expectedHash = big.NewInt(0)
	if res != true {
		t.Errorf("Failed to create big int from string")
	}

	resultHash, err = stringHashCode(stringToHash)
	if err != nil {
		t.Errorf("Failed to hash (%v)", stringToHash)
	}

	if resultHash.Cmp(expectedHash) != 0 {
		t.Errorf("Failed: resultHash (%v) is not equal to expectedHash (%v).", resultHash, expectedHash)
	}
}

func Test_StringHashCodeVerifyMultiple(t *testing.T) {
	// Verify we always get the same hash for the same string
	x, _ := new(big.Int).SetString("128315357667807226926361442424369717137", 10)
	rndVal := "95d8b7c0-fef8-4096-b88c-a0c9f6b3c6962006-01-02T15:04:05.000Z"

	hashedVal1, _ := stringHashCode(rndVal)
	if hashedVal1.Cmp(x) != 0 {
		t.Errorf("Failed: resultHash (%v) is not equal to expectedHash (%v).", hashedVal1, x)
	}

	hashedVal2, _ := stringHashCode(rndVal)
	if hashedVal2.Cmp(x) != 0 {
		t.Errorf("Failed: resultHash (%v) is not equal to expectedHash (%v).", hashedVal2, x)
	}

	hashedVal3, _ := stringHashCode(rndVal)
	if hashedVal3.Cmp(x) != 0 {
		t.Errorf("Failed: resultHash (%v) is not equal to expectedHash (%v).", hashedVal3, x)
	}

	hashedVal4, _ := stringHashCode(rndVal)
	if hashedVal4.Cmp(x) != 0 {
		t.Errorf("Failed: resultHash (%v) is not equal to expectedHash (%v).", hashedVal4, x)
	}

	hashedVal5, _ := stringHashCode(rndVal)
	if hashedVal5.Cmp(x) != 0 {
		t.Errorf("Failed: resultHash (%v) is not equal to expectedHash (%v).", hashedVal5, x)
	}
}

type shard struct {
	shardId    int
	shardStart string
	shardEnd   string
	counter    int
}

func Test_StringHashCodeDistribution(t *testing.T) {
	// imaginary number of shards
	shardCount := 10
	// number of hashes to run
	hashCount := 100

	shards := make(map[int]*shard)

	// 340282366920938463463374607431768211455 is the whole shard key range
	a, _ := new(big.Int).SetString("340282366920938463463374607431768211455", 10)
	h := big.NewInt(0)
	i, _ := new(big.Int).SetString(strconv.Itoa(shardCount), 10)

	// Divide the whole shard key range by the shardCount to break the key ranges into individual shard key ranges so we can see how well things are distributed
	h.Div(a, i)

	// Loop through and create the ranges for each shard
	for c := 1; c < shardCount; c++ {
		d := big.NewInt(0)
		e := big.NewInt(0)
		f, _ := new(big.Int).SetString(strconv.Itoa(c), 10)
		d.Mul(h, f)
		e.Sub(d, h)
		shardx := shard{shardId: c, shardStart: e.String(), shardEnd: d.String(), counter: 0}
		shards[c] = &shardx
	}

	for f := 1; f < hashCount; f++ {
		// Create Random hash keys
		uuidWithHyphen := uuid.New()
		receivedAtTimestampString := time.Now().UTC().Format("2006-01-02T15:04:05.000Z")
		rndVal := uuidWithHyphen.String() + receivedAtTimestampString
		hashedVal, _ := stringHashCode(rndVal)

		// See where they land on the shards above
		for g := 1; g < shardCount; g++ {
			h, _ := new(big.Int).SetString(shards[g].shardStart, 10)
			i, _ := new(big.Int).SetString(shards[g].shardEnd, 10)
			if hashedVal.Cmp(h) == 1 && hashedVal.Cmp(i) == -1 {
				shards[g].counter = shards[g].counter + 1
				break
			}
		}
	}

	for z := 1; z < shardCount; z++ {
		// if we get no items on a shard or 20 items on a shard then error
		if shards[z].counter == 0 || shards[z].counter == (shardCount*2) {
			t.Errorf("Failed: shard (%v) is out of range (%v).", shards[z].shardId, shards[z].counter)
		}
	}

}
