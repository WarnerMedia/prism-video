// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package com.wm.prism.video.agg.metrics;

import com.wm.prism.video.agg.constructors.custom.VideoEvent;
import com.wm.prism.video.agg.constructors.custom.VideoSession;
import com.wm.prism.video.agg.utils.EventMapping;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Play = count of mediaStarting events. Some brands are mistakenly sending more
 * than one
 * play event per session, so counting a distinct on the session to avoid
 * duplication count
 */
public class Play {

    private static final Logger LOG = LoggerFactory.getLogger(Play.class);

    public void calculate(final List<VideoEvent> events, final VideoSession videoSession) {
        final List<VideoEvent> filteredEvents = events.stream()
                .filter(ev -> EventMapping.isPlay(ev.getEventName()) == true)
                .collect(Collectors.toList());

        final int eventCnt = (int) filteredEvents.stream()
                .map(VideoEvent::getVideoSessionId).distinct().count();
        videoSession.setPlayCount(eventCnt);

        LOG.debug("Play: counted {} plays for video session id {} ", eventCnt, videoSession.getVideoSessionId());

    }

}
