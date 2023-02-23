// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package v2

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/md5"
	"crypto/rand"
	"math/big"

	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"doppler-video-telemetry/code/pkg/log"
	"encoding/base64"

	"github.com/Jeffail/gabs/v2"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/secretsmanager"
)

// GetIP - Get the X-FORWARDED-FOR ip address
func GetIP(r *http.Request) string {
	forwarded := r.Header.Get("X-FORWARDED-FOR")
	if forwarded != "" {
		return forwarded
	}
	return r.RemoteAddr
}

func stringHashCode(o string) (*big.Int, error) {
	if o == "" {
		return big.NewInt(0), nil
	}

	if o == "0" {
		return big.NewInt(0), nil
	}

	hasher := md5.New()
	_, err := hasher.Write([]byte(o))
	if err != nil {
		return big.NewInt(0), err
	}
	md := hasher.Sum(nil)

	return new(big.Int).SetBytes(md), nil

}

func PrepareKinesisRecord(env string, httpIn *gabs.Container, log *log.Logger, enableEncryption string, sourceIpAddress string, browserName string, browserVersion string, operatingSystem string, osVersion string, device string, deviceBrandName string, model string, region string, sessionId string) ([]byte, error) {
	receivedAtTimestamp := time.Now().Unix()
	receivedAtTimestampString := time.Now().UTC().Format("2006-01-02T15:04:05.000")

	//populated by us, not sent by clients
	httpIn.Set(receivedAtTimestamp, "receivedAtTimestamp")
	httpIn.Set(receivedAtTimestampString, "receivedAtTimestampString")
	httpIn.Set(sourceIpAddress, "sourceIpAddress")
	httpIn.Set(region, "awsregion")
	httpIn.Set(browserName, "backendUserAgentParser", "browserName")
	httpIn.Set(browserVersion, "backendUserAgentParser", "browserVersion")
	httpIn.Set(operatingSystem, "backendUserAgentParser", "operatingSystem")
	httpIn.Set(osVersion, "backendUserAgentParser", "osVersion")
	httpIn.Set(device, "backendUserAgentParser", "device")
	httpIn.Set(deviceBrandName, "backendUserAgentParser", "deviceBrandName")
	httpIn.Set(model, "backendUserAgentParser", "model")

	//Lowercase all payload attributes besides TimeStamps, ids, and URLs
	for key, child := range httpIn.ChildrenMap() {
		//If the child is not a string, it's an inner json struct
		if _, ok := child.Data().(string); ok {
			isTimeStamp := strings.Contains(key, "Timestamp")
			if !isTimeStamp {
				httpIn.Set(strings.ToLower(child.Data().(string)), key)
			}
		} else {
			for innerKey, child := range httpIn.S(key).ChildrenMap() {
				if key != "ids" {
					if !strings.Contains(innerKey, "Url") {
						if _, ok := child.Data().(string); ok {
							httpIn.Set(strings.ToLower(child.Data().(string)), key, innerKey)
						}
					}
				}
			}
		}
	}

	// don't allow an empty string or and int of zero as a hash key or all our writes will be to the same shard.
	if sessionId != "" {

		hashKey, err := stringHashCode(sessionId)
		if err != nil {
			log.Warnf("Failed to hash session id %v", err)
		}

		if hashKey.Cmp(big.NewInt(0)) != 0 {
			httpIn.Set(hashKey, "kdsHashKey")
		}
	}

	//encrypt all sensitive fields in Dev and Enable Encryption env variable is true
	if strings.Contains(env, "devus") && enableEncryption == "true" {
		//get ecryption key for AWS Secrets Manager
		key, err := getSecret(log)
		if err != nil {
			log.Warnf("Failed to encrypt a field: %v", err)
			return nil, err
		}
		//Encrypt the fields
		httpIn, err = encryptSensitiveFields(httpIn, log, key)
		if err != nil {
			return nil, err
		}
	}

	kinesisBits, err := json.Marshal(httpIn)
	if err != nil {
		return nil, err
	}

	return kinesisBits, nil
}

func encryptSensitiveFields(httpIn *gabs.Container, log *log.Logger, key string) (*gabs.Container, error) {
	//Grab data from the Gabs JSON fields
	sessionid := []byte(httpIn.Path("sessionid").Data().(string))
	ipAddress := []byte(httpIn.Path("ipAddress").Data().(string))

	sessionid, err := encrypt(sessionid, key)
	if err != nil {
		return nil, err
	}

	ipAddress, err = encrypt(ipAddress, key)
	if err != nil {
		return nil, err
	}

	httpIn.Set(string(sessionid), "sessionid")
	httpIn.Set(string(ipAddress), "ipAddress")

	return httpIn, nil
}

// Used to create Keys for Ecrypting/Decrypting
// func createHash(key string) string {
// 	hasher := md5.New()
// 	hasher.Write([]byte(key))
// 	return hex.EncodeToString(hasher.Sum(nil))
// }

func encrypt(data []byte, passphrase string) ([]byte, error) {
	block, _ := aes.NewCipher([]byte(passphrase))
	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return nil, err
	}
	nonce := make([]byte, gcm.NonceSize())
	if _, err = io.ReadFull(rand.Reader, nonce); err != nil {
		panic(err.Error())
	}
	ciphertext := gcm.Seal(nonce, nonce, data, nil)
	return ciphertext, nil
}

func decrypt(data []byte, passphrase string) []byte {
	key := []byte(passphrase)
	block, err := aes.NewCipher(key)
	if err != nil {
		panic(err.Error())
	}
	gcm, err := cipher.NewGCM(block)
	if err != nil {
		panic(err.Error())
	}
	nonceSize := gcm.NonceSize()
	nonce, ciphertext := data[:nonceSize], data[nonceSize:]
	plaintext, err := gcm.Open(nil, nonce, ciphertext, nil)
	if err != nil {
		panic(err.Error())
	}
	return plaintext
}

func getSecret(log *log.Logger) (string, error) {
	secretName := ""
	region := "us-east-1"

	//Create a Secrets Manager client
	svc := secretsmanager.New(session.New(),
		aws.NewConfig().WithRegion(region))
	input := &secretsmanager.GetSecretValueInput{
		SecretId:     aws.String(secretName),
		VersionStage: aws.String("AWSCURRENT"), // VersionStage defaults to AWSCURRENT if unspecified
	}

	// In this sample we only handle the specific exceptions for the 'GetSecretValue' API.
	// See https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html

	result, err := svc.GetSecretValue(input)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			case secretsmanager.ErrCodeDecryptionFailure:
				// Secrets Manager can't decrypt the protected secret text using the provided KMS key.
				log.Warn(secretsmanager.ErrCodeDecryptionFailure, aerr.Error())

			case secretsmanager.ErrCodeInternalServiceError:
				// An error occurred on the server side.
				log.Warn(secretsmanager.ErrCodeInternalServiceError, aerr.Error())

			case secretsmanager.ErrCodeInvalidParameterException:
				// You provided an invalid value for a parameter.
				log.Warn(secretsmanager.ErrCodeInvalidParameterException, aerr.Error())

			case secretsmanager.ErrCodeInvalidRequestException:
				// You provided a parameter value that is not valid for the current state of the resource.
				log.Warn(secretsmanager.ErrCodeInvalidRequestException, aerr.Error())

			case secretsmanager.ErrCodeResourceNotFoundException:
				// We can't find the resource that you asked for.
				log.Warn(secretsmanager.ErrCodeResourceNotFoundException, aerr.Error())
			}
		} else {
			// Print the error, cast err to awserr.Error to get the Code and
			// Message from an error.
			log.Warn(err.Error())
		}
		return "", err
	}

	// Decrypts secret using the associated KMS CMK.
	// Depending on whether the secret is a string or binary, one of these fields will be populated.
	var secretString, decodedBinarySecret string
	if result.SecretString != nil {
		secretString = *result.SecretString
		return secretString, nil
	} else {
		decodedBinarySecretBytes := make([]byte, base64.StdEncoding.DecodedLen(len(result.SecretBinary)))
		len, err := base64.StdEncoding.Decode(decodedBinarySecretBytes, result.SecretBinary)
		if err != nil {
			fmt.Println("Base64 Decode Error:", err)
			return "", err
		}
		decodedBinarySecret = string(decodedBinarySecretBytes[:len])
		return decodedBinarySecret, nil
	}
}
