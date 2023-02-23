// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package com.wm.prism.video.agg.utils;

public class EventMapping {

    public static boolean isPlay(String eventName) {
        return eventName.equalsIgnoreCase(PlayerEvents.mediaStarted.name());
    }

    /* Returns the player event name for play */
    public static String getTopPlayEvent() {
        return PlayerEvents.mediaStarted.name();
    }

    /* List of TOP events */
    private enum PlayerEvents {
        mediaStarted
    }

}
