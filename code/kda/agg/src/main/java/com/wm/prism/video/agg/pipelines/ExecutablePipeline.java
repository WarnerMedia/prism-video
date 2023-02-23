// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package com.wm.prism.video.agg.pipelines;

import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.functions.sink.SinkFunction;
import org.apache.flink.streaming.api.functions.source.SourceFunction;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;

public interface ExecutablePipeline<IN, OUT> {

    DataStream<OUT> load(StreamExecutionEnvironment env,
            SourceFunction<IN> sourceFunction,
            DataStream<IN> sourceDataStream,
            SinkFunction<OUT> sink,
            SinkFunction<IN> lateEventsSink)
            throws Exception;

}
