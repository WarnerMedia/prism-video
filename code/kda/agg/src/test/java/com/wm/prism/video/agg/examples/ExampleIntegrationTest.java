// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package com.wm.prism.video.agg.examples;

import org.apache.flink.api.common.typeinfo.TypeInformation;
import org.apache.flink.api.java.typeutils.ResultTypeQueryable;
import org.apache.flink.api.java.typeutils.TypeExtractor;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.sink.SinkFunction;
import org.apache.flink.streaming.api.functions.source.SourceFunction;
import org.apache.flink.test.util.MiniClusterWithClientResource;
import org.apache.flink.test.util.MiniClusterResourceConfiguration;
import org.junit.ClassRule;
import org.junit.Test;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import static org.junit.Assert.assertTrue;

public class ExampleIntegrationTest {

    @ClassRule
    public static MiniClusterWithClientResource flinkCluster = new MiniClusterWithClientResource(
            new MiniClusterResourceConfiguration.Builder()
                    .setNumberSlotsPerTaskManager(2)
                    .setNumberTaskManagers(1)
                    .build());

    @Test
    public void testIncrementPipeline() throws Exception {

        ArrayList<Long> expected = new ArrayList<Long>();
        Collections.addAll(expected, new Long[] { 2L, 22L, 23L });

        List<Long> actual = RunPipeline(1L, 21L, 22L);

        // assert that all the values were in the result
        assertTrue("The result must have all of the expected values", actual.containsAll(expected));
    }

    private List<Long> RunPipeline(Long... testData) throws Exception {
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        // configure your test environment
        env.setParallelism(2);

        // DummySink sink = new DummySink();

        ExampleIntegrationPipeline pipeline = new ExampleIntegrationPipeline();

        DummySource<Long> source = new DummySource<>(testData);

        pipeline.load(env, source, null, new CollectSink(), null);

        // execute
        env.execute();

        return CollectSink.values;
    }

    // create a testing sink
    private static class CollectSink implements SinkFunction<Long> {

        // must be static
        public static final List<Long> values = Collections.synchronizedList(new ArrayList<>());

        @Override
        public void invoke(Long value, SinkFunction.Context context) throws Exception {
            values.add(value);
        }
    }

    private class DummySink implements SinkFunction<Long> {

        // must be static
        public final List<Long> values = Collections.synchronizedList(new ArrayList<>());

        @Override
        public void invoke(Long value, SinkFunction.Context context) throws Exception {
            values.add(value);
        }
    }

    public class DummySource<T> implements SourceFunction<T>, ResultTypeQueryable<T> {

        private final T[] testStream;
        private final TypeInformation<T> typeInfo;

        @SuppressWarnings("unchecked")
        @SafeVarargs
        public DummySource(T... events) {
            this.testStream = events;
            this.typeInfo = (TypeInformation<T>) TypeExtractor.createTypeInfo(events[0].getClass());

        }

        @Override
        public void run(SourceContext<T> sourceContext) throws Exception {
            for (T element : testStream) {
                sourceContext.collect(element);
            }
        }

        @Override
        public void cancel() {
            // can be ignored
        }

        @Override
        public TypeInformation<T> getProducedType() {
            return typeInfo;
        }
    }

}