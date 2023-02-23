// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package com.wm.prism.video.agg;

import com.wm.prism.video.agg.constructors.custom.VideoSession;
import com.wm.prism.video.agg.constructors.custom.VideoEvent;
import com.wm.prism.video.agg.pipelines.ProcessVideoMetrics;
import com.wm.prism.video.agg.utils.EventMapping;
import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.sink.SinkFunction;
import org.apache.flink.test.util.MiniClusterResourceConfiguration;
import org.apache.flink.test.util.MiniClusterWithClientResource;
import org.junit.BeforeClass;
import org.junit.ClassRule;
import org.junit.Test;

import java.time.Duration;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

import static org.junit.Assert.assertEquals;

public class PlayCount_Multiple_Test {
    @ClassRule
    public static MiniClusterWithClientResource flinkCluster = new MiniClusterWithClientResource(
            new MiniClusterResourceConfiguration.Builder()
                    .setNumberSlotsPerTaskManager(2)
                    .setNumberTaskManagers(1)
                    .build());

    private static List<VideoSession> actual;

    @BeforeClass
    public static void Setup() throws Exception {
        // r1 and r2 should not be aggregated together; we do have 2 plays but do a
        // distinct count per session
        VideoEvent r1 = new VideoEvent();
        r1.setBrand("cnn");
        r1.getVideoSession().setVideoSessionId("video-session-1");
        r1.setEventName(EventMapping.getTopPlayEvent());
        r1.setEventReceivedAtTimestampInMS(1642524605L * 1000L);
        r1.getVideo().setCurrentMediaState("playing");

        VideoEvent r2 = new VideoEvent();
        r2.setBrand("cnn");
        r2.getVideoSession().setVideoSessionId(r1.getVideoSessionId());
        r2.setEventName(EventMapping.getTopPlayEvent());
        r2.setEventReceivedAtTimestampInMS(r1.getEventReceivedAtTimestampInMS());
        r2.getVideo().setCurrentMediaState("playing");

        // r3 should be its own row since it has a different brand and different session
        // id so
        // the result should be aggregated separately
        VideoEvent r3 = new VideoEvent();
        r3.setBrand("tnt");
        r3.getVideoSession().setVideoSessionId("video-session-3");
        r3.setEventName(EventMapping.getTopPlayEvent());
        r3.setEventReceivedAtTimestampInMS(r1.getEventReceivedAtTimestampInMS());
        r3.getVideo().setCurrentMediaState("playing");

        // r4 should be its own row since it is on the same session but at a later time,
        // past our late arriving window
        VideoEvent r4 = new VideoEvent();
        r4.setBrand("cnn");
        r4.getVideoSession().setVideoSessionId(r1.getVideoSessionId());
        r4.setEventName(EventMapping.getTopPlayEvent());
        r4.setEventReceivedAtTimestampInMS(r1.getEventReceivedAtTimestampInMS() + (120 * 1000));
        r4.getVideo().setCurrentMediaState("playing");

        List<VideoSession> unsortedActual = PlayCount_Multiple_Test.RunPipeline(r1, r2, r3, r4);

        // the results come out non-deterministically, so sort them by brand so cnn is
        // always first
        // also filter results for play metric only, since process returns plays and
        // concurrents
        actual = unsortedActual
                .stream()
                // .filter(agg ->
                // agg.getMeasureName().equalsIgnoreCase(Constants.PrismTelemetryMetrics.play.name()))
                .sorted((a, b) -> a.getBrand().compareTo(b.getBrand()))
                .collect(Collectors.toList());

        for (int i = 0; i < actual.size(); i++) {
            System.out.println(actual.get(i));
        }

    }

    @Test
    public void ResultCount() {
        assertEquals("There must be the correct number of aggregated records: ", 3, actual.size());
    }

    // Correct sum for CNN (first window)
    @Test
    public void CorrectSum() {
        assertEquals("The result must be the correct number of attempts for cnn: ", 1, actual.get(0).getPlayCount());
    }

    // First brand to show up should be CNN
    @Test
    public void BrandOne() {
        assertEquals("The brand must be correct for the tnt result.", "cnn", (String) actual.get(0).getBrand());
    }

    @Test
    public void BrandTwo() {
        assertEquals("The brand must be correct for the TNT result.", "tnt", (String) actual.get(2).getBrand());
    }

    // Correct sum for CNN (second window)
    @Test
    public void BrandOne_Later() {
        assertEquals("The brand must be correct for the tnt later attempt: ", "cnn", (String) actual.get(1).getBrand());
    }

    private static List<VideoSession> RunPipeline(VideoEvent... testData) throws Exception {
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        WatermarkStrategy<VideoEvent> watermarkStrategy = WatermarkStrategy
                .<VideoEvent>forBoundedOutOfOrderness(Duration.ofSeconds(1))
                .withTimestampAssigner(
                        (event, streamRecordTimestamp) -> event.getEventReceivedAtTimestampInMS());

        // configure your test environment
        env.setParallelism(2);

        // DummySink sink = new DummySink();
        CollectSink.values.clear();

        ProcessVideoMetrics pipeline = new ProcessVideoMetrics(true, 120);

        DummySource<VideoEvent> source = new DummySource<>(testData);
        DataStream<VideoEvent> ds = env
                .addSource(source)
                .assignTimestampsAndWatermarks(watermarkStrategy);

        pipeline.load(env, null, ds, new CollectSink(), null);

        // execute
        env.execute();

        return CollectSink.values;
    }

    // create a testing sink
    public static class CollectSink implements SinkFunction<VideoSession> {

        // must be static
        public static final List<VideoSession> values = Collections.synchronizedList(new ArrayList<>());

        @Override
        public void invoke(VideoSession value, Context context) throws Exception {
            values.add(value);
        }
    }

}
