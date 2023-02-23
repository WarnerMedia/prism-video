// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package com.wm.prism.video.agg.functions;

import com.wm.prism.video.agg.constructors.custom.VideoSession;
import com.wm.prism.video.agg.constructors.custom.VideoEvent;
import com.wm.prism.video.agg.metrics.*;
import org.apache.flink.api.common.state.StateTtlConfig;
import org.apache.flink.api.common.state.ValueState;
import org.apache.flink.api.common.state.ValueStateDescriptor;
import org.apache.flink.api.common.time.Time;
import org.apache.flink.configuration.Configuration;
import org.apache.flink.streaming.api.functions.windowing.ProcessWindowFunction;
import org.apache.flink.streaming.api.windowing.windows.TimeWindow;
import org.apache.flink.util.Collector;
import org.apache.flink.util.IterableUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Counts distinct video session ids
 */
public class PrismVideoSessionHandler
        extends ProcessWindowFunction<VideoEvent, VideoSession, String, TimeWindow> {

    private static final Logger LOG = LoggerFactory.getLogger(PrismVideoSessionHandler.class);
    private transient ValueState<VideoSession> sessionState;
    private transient Play playCalculator;

    private final int stateTtlSecs;

    public PrismVideoSessionHandler(final int stateTtlSecs) {
        this.stateTtlSecs = stateTtlSecs;
    }

    /**
     * Overrides the Flink open method to retrieve the state for each key and uses
     * the parameter TTL to kill the state
     * after inactivity. The state is considered active at creation or any update
     * (all metrics are updated at the window
     * end time)
     *
     * @param config
     */
    @Override
    public void open(final Configuration config) throws Exception {
        super.open(config);
        final ValueStateDescriptor<VideoSession> sessionStateDef = new ValueStateDescriptor<>("session-state",
                VideoSession.class);

        final StateTtlConfig ttlConfig = StateTtlConfig
                .newBuilder(Time.seconds(stateTtlSecs))
                .setUpdateType(StateTtlConfig.UpdateType.OnCreateAndWrite)
                .setStateVisibility(StateTtlConfig.StateVisibility.NeverReturnExpired)
                .cleanupFullSnapshot() // check for expired entries before taking snapshot
                .build();
        sessionStateDef.enableTimeToLive(ttlConfig);

        sessionState = getRuntimeContext().getState(sessionStateDef);
        playCalculator = new Play();

    }

    /**
     * Overrides the Flink process method for the window; it will iterate through
     * the list of events, calculate metrics
     * and update the VideoSession object at the end
     *
     * @param key
     * @param context
     * @param events
     * @param out
     */
    @Override
    public void process(
            String key,
            Context context,
            Iterable<VideoEvent> events,
            Collector<VideoSession> out) throws Exception {

        // sorting the events by the client timestamp, not the server one since we might
        // get
        // several events with same server time due to batching
        List<VideoEvent> evList = IterableUtils.toStream(events)
                .sorted(Comparator.comparingLong(VideoEvent::getEventTimestampInMS))
                .collect(Collectors.toList());
        LOG.debug("PrismVideoSessionHandler.process - received " + evList.size() + " events on timer");

        VideoSession videoSession = sessionState.value();
        if (videoSession == null) {
            videoSession = new VideoSession(evList.get(0));
        }
        videoSession.setLatestWindow(context.window().getStart());
        videoSession.updateVideoSessionMetadata(evList);

        // Calculating the metrics...
        playCalculator.calculate(evList, videoSession);

        // updating the state right before the end
        sessionState.update(videoSession);

        out.collect(videoSession);
    }

}