// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package com.wm.prism.video.agg.pipelines;

import com.wm.prism.video.agg.constructors.custom.VideoEvent;
import com.wm.prism.video.agg.constructors.custom.VideoSession;
import com.wm.prism.video.agg.functions.PrismVideoSessionHandler;
import com.wm.prism.video.agg.utils.Constants;
import com.wm.prism.video.agg.utils.VideoEventKeySelector;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.datastream.SingleOutputStreamOperator;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.sink.SinkFunction;
import org.apache.flink.streaming.api.functions.source.SourceFunction;
import org.apache.flink.streaming.api.windowing.assigners.TumblingEventTimeWindows;
import org.apache.flink.streaming.api.windowing.time.Time;
import org.apache.flink.util.OutputTag;

public class ProcessVideoMetrics implements ExecutablePipeline<VideoEvent, VideoSession> {
    private boolean isLocal = false;
    private int stateTtlSecs;

    /**
     * Main constructor for metrics that are used to count occurrences.
     *
     * @param isLocalExecution Indicates if pipeline is running locally or in KDA
     */
    public ProcessVideoMetrics(boolean isLocalExecution, int stateTtlSecs) {
        this.isLocal = isLocalExecution;
        this.stateTtlSecs = stateTtlSecs;
    }

    public DataStream<VideoSession> load(StreamExecutionEnvironment env,
            SourceFunction<VideoEvent> sourceFunction,
            DataStream<VideoEvent> sourceDataStream,

            SinkFunction<VideoSession> sessionSink,
            SinkFunction<VideoEvent> lateEventsSink) {

        /* Tagging late arriving data */
        final OutputTag<VideoEvent> lateOutputTag = new OutputTag<VideoEvent>(Constants.LATE_ARRIVING_DATA_TAG) {
        };

        // Creating the video session stream...
        SingleOutputStreamOperator<VideoSession> videoSession = sourceDataStream
                .keyBy(new VideoEventKeySelector())
                .window(TumblingEventTimeWindows.of(Constants.WINDOW_SIZE))
                .allowedLateness(Time.seconds(Constants.ALLOWED_LATENESS_SECS))
                .sideOutputLateData(lateOutputTag)
                .process(new PrismVideoSessionHandler(stateTtlSecs))
                .name("prism-video-session-handler")
                .uid("prism-video-session-handler");

        DataStream<VideoEvent> lateStream = videoSession.getSideOutput(lateOutputTag);
        if (lateEventsSink != null) {
            lateStream.addSink(lateEventsSink)
                    .name("late-events-kds-sink")
                    .uid("late-events-kds-sink");
        }

        if (sessionSink != null) {
            videoSession.addSink(sessionSink)
                    .name("video-session-kds-sink")
                    .uid("video-session-kds-sink");
        }

        if (isLocal) {
            videoSession.print();
            lateStream.print();
        }

        return videoSession;
    }

}
