// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package log

import (
	"os"

	"go.uber.org/zap"
)

type Logger = zap.SugaredLogger

func getEnvironment() string {
	return os.Getenv("ENVIRONMENT")
}

func getLoggingLevel() string {
	return os.Getenv("LOG_LEVEL")
}

func New() *Logger {
	var cfg zap.Config

	if getEnvironment() == "prod" {
		// Sane defaults; logs to stderr, structured json, errors include stacktraces, etc.
		cfg = zap.NewProductionConfig()
	} else {
		cfg = zap.NewDevelopmentConfig()
	}
	level := cfg.Level.Level()
	err := level.Set(getLoggingLevel())
	if err != nil {
		cfg.Level.SetLevel(zap.DebugLevel)
	}
	cfg.Level.SetLevel(level)
	result, err := cfg.Build()
	if err != nil {
		panic(err)
	}

	return result.Sugar()
}
