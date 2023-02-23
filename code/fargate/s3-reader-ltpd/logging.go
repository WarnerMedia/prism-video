// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package main

import (
	"context"
	"fmt"
	"net/http"
	"os"

	"github.com/go-kit/kit/log"
	"github.com/go-kit/kit/log/level"
)

var logger log.Logger

func createLogger() log.Logger {
	result := log.NewJSONLogger(log.NewSyncWriter(os.Stderr))
	switch l := getLoggingLevel(); l {
	case "debug":
		result = level.NewFilter(result, level.AllowDebug())
	case "info":
		result = level.NewFilter(result, level.AllowInfo())
	case "warn":
		result = level.NewFilter(result, level.AllowWarn())
	case "error":
		result = level.NewFilter(result, level.AllowWarn())
	default:
		result = level.NewFilter(result, level.AllowAll())
	}
	return result
}

func debugLog(keyvals ...interface{}) {
	level.Debug(logger).Log(keyvals...)
}

func infoLog(keyvals ...interface{}) {
	level.Info(logger).Log(keyvals...)
}

func warnLog(keyvals ...interface{}) {
	level.Warn(logger).Log(keyvals...)
}
func errorLog(keyvals ...interface{}) {
	level.Error(logger).Log(keyvals...)
}

func debug(format string, a ...interface{}) {
	m := fmt.Sprintf(format, a...)
	debugLog("msg", m)
}

func info(format string, a ...interface{}) {
	m := fmt.Sprintf(format, a...)
	infoLog("msg", m)
}

func warn(format string, a ...interface{}) {
	m := fmt.Sprintf(format, a...)
	warnLog("msg", m)
}

func logError(context string, err error) error {
	e := fmt.Errorf("%s: %w", context, err)
	errorLog("msg", e)
	return e
}

type key int

const loggerIDKey key = 82

// Logger middleware.
type Logger struct {
	h      http.Handler
	logger log.Logger
}

// SetLogger ...
func (l *Logger) SetLogger(logger log.Logger) {
	l.logger = logger
}

// wrapper to capture status.
type wrapper struct {
	http.ResponseWriter
	written int
	status  int
}

// capture status.
func (w *wrapper) WriteHeader(code int) {
	w.status = code
	w.ResponseWriter.WriteHeader(code)
}

// capture written bytes.
func (w *wrapper) Write(b []byte) (int, error) {
	n, err := w.ResponseWriter.Write(b)
	w.written += n
	return n, err
}

// NewLogger middleware with the given log.Logger.
func NewLogger(logger log.Logger) func(http.Handler) http.Handler {
	return func(h http.Handler) http.Handler {
		return &Logger{
			logger: logger,
			h:      h,
		}
	}
}

// ServeHTTP implementation.
func (l *Logger) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	res := &wrapper{w, 0, 200}

	// get the context since we'll use it a few times
	ctx := r.Context()

	logger := log.With(l.logger)

	// continue to the next middleware
	ctx = context.WithValue(ctx, loggerIDKey, logger)
	l.h.ServeHTTP(res, r.WithContext(ctx))
}

// LoggerFromRequest can be used to obtain the Log from the request.
func LoggerFromRequest(r *http.Request) log.Logger {
	return LoggerFromContext(r.Context())
}

// LoggerFromContext can be used to obtain the Log from the context.
func LoggerFromContext(ctx context.Context) log.Logger {
	return ctx.Value(loggerIDKey).(log.Logger)
}
