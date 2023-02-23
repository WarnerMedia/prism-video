// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package com.wm.prism.video.agg.utils;

import com.wm.prism.video.agg.constructors.custom.VideoEvent;
import org.apache.flink.api.java.functions.KeySelector;

/**
 * The key selector for the video event object
 */
public class VideoEventKeySelector
        implements KeySelector<VideoEvent, String> {

    /**
     * Garantees a video session id is always present, since we are partitioning our
     * data by it. this method can be
     * simplified once Receive starts validating the presence of video session id
     * 
     * @return the video session id; if not present then the session id otherwise
     *         returns "default-session-id" concatenated
     *         with the epoch system time in milliseconds
     */
    @Override
    public String getKey(VideoEvent item) {
        return item.getVideoSessionId();
    }

}
