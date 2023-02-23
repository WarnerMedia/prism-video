// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package com.wm.prism.video.agg;

import com.amazonaws.regions.Regions;
import com.amazonaws.services.kinesisanalytics.runtime.KinesisAnalyticsRuntime;
import com.wm.prism.video.agg.constructors.custom.VideoEvent;
import com.wm.prism.video.agg.constructors.custom.VideoSession;
import com.wm.prism.video.agg.pipelines.ProcessVideoMetrics;
import com.wm.prism.video.agg.utils.*;

import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.api.java.utils.ParameterTool;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.connectors.kinesis.FlinkKinesisConsumer;
import org.apache.flink.streaming.connectors.kinesis.FlinkKinesisProducer;
import org.apache.flink.streaming.connectors.kinesis.KinesisPartitioner;
import org.apache.flink.streaming.connectors.kinesis.config.ConsumerConfigConstants;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.math.BigInteger;
import java.time.Duration;
import java.util.Map;
import java.util.Properties;
import java.util.Random;

public class ProcessVideoStream {

    private static final Logger LOG = LoggerFactory.getLogger(ProcessVideoStream.class);
    private static boolean isLocal = false;
    private static String secsAllowedLateArrivingData = new String();
    private static String kinesisRawStream = new String();
    private static String kinesisLateStream = new String();

    private static String kinesisSessionStream = new String();
    private static String kinesisRegion = new String();
    private static String videoSessionTtlSecs = new String();
    private static String stateTtlSecs = new String();
    private static Properties inputProperties = new Properties();

    /**
     * Processes the video stream
     *
     * @param args
     */
    public static void main(String[] args) throws Exception {
        LOG.info("Starting ProcessVideoStream");

        // setting up environment and sinks..
        final StreamExecutionEnvironment env = setupEnvironment(args);
        FlinkKinesisProducer<VideoEvent> lateEventSink = createSinkForLateEvents(kinesisRegion, kinesisLateStream);
        FlinkKinesisProducer<VideoSession> sessionSink = createSinkForSession(kinesisRegion, kinesisSessionStream);

        // watermarking strategy
        WatermarkStrategy<VideoEvent> watermarkStrategy = WatermarkStrategy
                .<VideoEvent>forBoundedOutOfOrderness(Duration.ofSeconds(Long.parseLong(secsAllowedLateArrivingData)))
                .withTimestampAssigner(
                        (event, streamRecordTimestamp) -> event
                                .getEventReceivedAtTimestampInMS());

        // The datastream; making sure we are filtering just video-qos events
        DataStream<VideoEvent> events = env
                .addSource(new FlinkKinesisConsumer<>(kinesisRawStream,
                        new VideoDeserializationSchema(), inputProperties))
                .filter(ev -> ev.getEventType().equalsIgnoreCase(Constants.EVENT_TYPE_VIDEO_QOS) ||
                        ev.getEventType().equalsIgnoreCase(Constants.EVENT_TYPE_VIDEO_QOS_BETA))
                .name("video-qos-filter")
                .assignTimestampsAndWatermarks(watermarkStrategy)
                .keyBy(new VideoEventKeySelector());

        ProcessVideoMetrics vm = new ProcessVideoMetrics(isLocal, Integer.parseInt(stateTtlSecs));
        vm.load(env, null, events, sessionSink, lateEventSink);
        env.execute("ProcessVideoStream");
    }

    /**
     * Creates a sink for late arriving events (Video Events)
     *
     * @param kinesisRegion where the sink will be created
     * @param streamName
     * @return
     */
    private static FlinkKinesisProducer<VideoEvent> createSinkForLateEvents(String kinesisRegion, String streamName) {
        Properties outputProperties = new Properties();
        outputProperties.setProperty(ConsumerConfigConstants.AWS_REGION, kinesisRegion);
        FlinkKinesisProducer<VideoEvent> sink = new FlinkKinesisProducer<>(new VideoEventSerializationSchema(),
                outputProperties);
        sink.setDefaultStream(streamName);
        sink.setCustomPartitioner(new KinesisPartitioner<VideoEvent>() {
            @Override
            public String getPartitionId(VideoEvent element) {
                return new BigInteger(128, new Random()).toString(10);
            }
        });
        return sink;
    }

    /**
     * Creates a sink for the session data (VideoSession)
     *
     * @param kinesisRegion where the sink will be created
     * @param streamName
     * @return
     */
    private static FlinkKinesisProducer<VideoSession> createSinkForSession(String kinesisRegion, String streamName) {
        Properties outputProperties = new Properties();
        outputProperties.setProperty(ConsumerConfigConstants.AWS_REGION, kinesisRegion);
        FlinkKinesisProducer<VideoSession> sink = new FlinkKinesisProducer<>(new VideoSessionSerializationSchema(),
                outputProperties);
        sink.setDefaultStream(streamName);

        sink.setCustomPartitioner(new KinesisPartitioner<VideoSession>() {
            @Override
            public String getPartitionId(VideoSession element) {
                return new BigInteger(128, new Random()).toString(10);
            }
        });

        return sink;
    }

    private static StreamExecutionEnvironment setupEnvironment(String[] args) throws Exception {

        ParameterTool parameter = ParameterTool.fromArgs(args);

        // read the parameters from the Kinesis Analytics environment
        Map<String, Properties> applicationProperties = KinesisAnalyticsRuntime.getApplicationProperties();

        kinesisRawStream = parameter.get("KINESIS_RAW_STREAM", "default-kds-raw");
        kinesisLateStream = parameter.get("KINESIS_LATE_STREAM", "default-kds-late");
        kinesisSessionStream = parameter.get("KINESIS_SESSION_STREAM", "default-kds-session");
        String enableEFO = parameter.get("ENABLE_EFO", "false");
        kinesisRegion = parameter.get("KINESIS_REGION", "us-east-1");
        secsAllowedLateArrivingData = parameter.get("KDA_LATE_ARRIVING_SECS", "30");
        videoSessionTtlSecs = parameter.get("KDA_VIDEO_SESSION_TTL_SECS", "300");
        stateTtlSecs = parameter.get("KDA_STATE_TTL_SECS", "3600");

        Properties flinkProperties = applicationProperties.get("FlinkApplicationProperties");
        if (flinkProperties != null) {
            kinesisRegion = Regions.getCurrentRegion().getName();
            kinesisRawStream = flinkProperties.get("KINESIS_RAW_STREAM").toString();
            kinesisLateStream = flinkProperties.get("KINESIS_LATE_STREAM").toString();
            kinesisSessionStream = flinkProperties.get("KINESIS_SESSION_STREAM").toString();
            enableEFO = flinkProperties.get("ENABLE_EFO").toString();
            secsAllowedLateArrivingData = flinkProperties.get("KDA_LATE_ARRIVING_SECS").toString();
            videoSessionTtlSecs = flinkProperties.get("KDA_VIDEO_SESSION_TTL_SECS").toString();
            stateTtlSecs = flinkProperties.get("KDA_STATE_TTL_SECS").toString();
        } else {
            isLocal = true;
            LOG.info("Running Flink pipeline locally...");
        }
        LOG.info("Kinesis Raw Stream is: {}", kinesisRawStream);
        LOG.info("Kinesis Late Stream is: {}", kinesisLateStream);
        LOG.info("Kinesis Session Stream is: {}", kinesisSessionStream);
        LOG.info("Kinesis Region is: {}", kinesisRegion);
        LOG.info("Enable EFO is: {}", enableEFO);
        LOG.info("Watermark Number of seconds is: {}", secsAllowedLateArrivingData);
        LOG.info("Video session TTL (secs) is: {}", videoSessionTtlSecs);
        LOG.info("State TTL (secs) is: {}", stateTtlSecs);

        inputProperties.setProperty(ConsumerConfigConstants.AWS_REGION, kinesisRegion);
        inputProperties.setProperty(ConsumerConfigConstants.STREAM_INITIAL_POSITION, "LATEST");

        // If enabled in config , add EFO(enhanced Fan Out) for KDS
        if (enableEFO.equals("true")) {
            LOG.info("Enabling EFO");
            inputProperties.putIfAbsent(ConsumerConfigConstants.RECORD_PUBLISHER_TYPE, "EFO");
            inputProperties.putIfAbsent(ConsumerConfigConstants.EFO_CONSUMER_NAME, "efo-kda-agg");
        }
        return StreamExecutionEnvironment.getExecutionEnvironment();
    }

}
