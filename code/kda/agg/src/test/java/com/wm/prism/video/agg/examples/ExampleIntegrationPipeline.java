// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package com.wm.prism.video.agg.examples;

import com.wm.prism.video.agg.pipelines.ExecutablePipeline;
import org.apache.flink.api.common.functions.MapFunction;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.sink.SinkFunction;
import org.apache.flink.streaming.api.functions.source.SourceFunction;

public class ExampleIntegrationPipeline implements ExecutablePipeline<Long, Long> {
    @Override
    public DataStream<Long> load(StreamExecutionEnvironment env, SourceFunction<Long> sourceFunction,
            DataStream<Long> sourceDataStream,
            SinkFunction<Long> sink, SinkFunction<Long> lateEventsSink) throws Exception {
        /// create a stream of custom elements and apply transformations
        DataStream<Long> stream = env.addSource(sourceFunction)
                .map(new IncrementMapFunction());

        stream.addSink(sink);
        return stream;
    }

    public class IncrementMapFunction implements MapFunction<Long, Long> {

        @Override
        public Long map(Long record) throws Exception {
            return record + 1;
        }
    }
}
