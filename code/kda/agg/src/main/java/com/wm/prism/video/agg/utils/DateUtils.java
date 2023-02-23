// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package com.wm.prism.video.agg.utils;

import java.time.Instant;

/**
 * Basic date conversion functions
 */
public class DateUtils {

    /**
     * Returns epoc time in MS for the ISO-8601 String; the format expected is:
     * "2022-07-27T19:09:28.824Z", so if the date passed does not contain a Z at the
     * end the code will
     * add it
     * 
     * @param dateString in the format 2022-07-27T19:09:28.824Z
     * @return epoc time in milliseconds
     */
    public static long convertIso8601ToMsEpoc(String dateString) {
        return dateString.endsWith("Z") ? Instant.parse(dateString).toEpochMilli()
                : Instant.parse(dateString + "Z").toEpochMilli();
    }

}
