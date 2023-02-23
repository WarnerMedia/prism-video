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

public class PlayCount_OneEvent_Test {
    @ClassRule
    public static MiniClusterWithClientResource flinkCluster = new MiniClusterWithClientResource(
            new MiniClusterResourceConfiguration.Builder()
                    .setNumberSlotsPerTaskManager(2)
                    .setNumberTaskManagers(1)
                    .build());

    private static List<VideoSession> actual;

    @BeforeClass
    public static void Setup() throws Exception {

        VideoEvent r1 = new VideoEvent();
        r1.setBrand("tnt");
        r1.getVideoSession().setVideoSessionId("session-id");
        r1.setEventName(EventMapping.getTopPlayEvent());
        r1.setEventReceivedAtTimestampInMS(1642524605L * 1000L);
        r1.getVideo().setAssetName("test");
        r1.getVideo().setCurrentMediaState("playing");

        // a play event will count towards a concurrent and a play, so filtering just
        // play metric
        // for the test...
        actual = PlayCount_OneEvent_Test.RunPipeline(r1)
                .stream()
                // .filter(agg ->
                // agg.getMeasureName().equalsIgnoreCase(Constants.PrismTelemetryMetrics.play.name()))
                .collect(Collectors.toList());

        for (int i = 0; i < actual.size(); i++) {
            System.out.println(actual.get(i));
        }

    }

    @Test
    public void ResultCount() {
        assertEquals("There must be the correct number of records.", 1, actual.size());
    }

    @Test
    public void CorrectSum() {
        assertEquals("The result must be the correct sum.", 1, actual.get(0).getPlayCount());
    }

    @Test
    public void AssetName() {
        assertEquals("The asset name must be correct.", "test", (String) actual.get(0).getAssetName());
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
