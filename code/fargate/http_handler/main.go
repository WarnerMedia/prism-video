// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package main

import (
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"doppler-video-telemetry/code/internal/web"
	"doppler-video-telemetry/code/pkg/log"
	"doppler-video-telemetry/code/pkg/sqs"

	statsd "github.com/etsy/statsd/examples/go"
	"github.com/gorilla/mux"
	"github.com/rs/cors"
	"github.com/turnerlabs/kplclientgo"
)

var (
	kpl           *kplclientgo.KPLClient
	metricsPrefix string
	statsdClient  *statsd.StatsdClient
	logger        *log.Logger
	kinesisDownTS time.Time
)

func startServer() {
	//create a KPL client
	kpl = kplclientgo.NewKPLClient(getHost(), getSocketServerPort())

	// Register error handler
	dlq := sqs.New(getDLQ())
	kpl.ErrHost = getErrHost()
	kpl.ErrPort = getErrPort()
	kpl.ErrHandler = func(data string) {
		kinesisDownTS = time.Now()
		err := dlq.SendMessage(data)
		if err != nil {
			logger.Error("Error while sending to SQS", err)
		}
	}

	// statsdClient
	statsdClient = statsd.New("localhost", 8125)

	// prefix for all the metrics
	metricsPrefix = getMetricPrefix()

	//start it up
	logger.Infof("starting kpl client: %v:%v", kpl.Host, kpl.Port)
	err := kpl.Start()
	if err != nil {
		logger.Error("Error starting kpl east client", err)
		panic(err)
	}

	//routes
	r := mux.NewRouter()
	r.Path(getHealthcheck()).Handler(web.Action(healthcheck))

	r.PathPrefix("/v1/vid").Handler(web.Action(processData)).
		Methods("POST").
		HeadersRegexp("Content-Type", "application/json")

	port := getPort()
	logger.Infof("http server started on %s...", port)

	srv := &http.Server{
		Addr:         ":" + port,
		Handler:      cors.AllowAll().Handler(r),
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  120 * time.Second,
	}

	err = srv.ListenAndServe()
	if err != nil {
		logger.Error("ListenAndServe", err)
	}
}

func main() {
	c := make(chan os.Signal)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-c
		fmt.Println("received SIGTERM, exiting")
		os.Exit(1)
	}()

	logger = log.New()
	defer logger.Sync()

	startServer()
}
