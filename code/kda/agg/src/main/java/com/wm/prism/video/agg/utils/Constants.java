// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package com.wm.prism.video.agg.utils;

import org.apache.flink.streaming.api.windowing.time.Time;

import java.util.concurrent.TimeUnit;

/**
 * Class to hold constant variables used in the project
 */
public class Constants {

    /* Video qos event type */
    public static final String EVENT_TYPE_VIDEO_QOS = "VideoQos";

    /* Video qos event type for beta */
    public static final String EVENT_TYPE_VIDEO_QOS_BETA = "video-qos";

    /* Window size for tumbling aggregate windows */
    public static final Time WINDOW_SIZE = Time.of(60, TimeUnit.SECONDS);

    /* Number of seconds used for allowed lateness on the window */
    public static final int ALLOWED_LATENESS_SECS = 0;

    /* Tag used to segregate late arriving data */
    public static final String LATE_ARRIVING_DATA_TAG = "late-data";

    public static final String NO_DATA = "psm.unk";

}
