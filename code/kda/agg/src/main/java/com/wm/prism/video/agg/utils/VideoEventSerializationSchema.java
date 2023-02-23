// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package com.wm.prism.video.agg.utils;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.wm.prism.video.agg.constructors.custom.VideoEvent;
import org.apache.flink.api.common.serialization.SerializationSchema;

import java.nio.charset.StandardCharsets;

public class VideoEventSerializationSchema implements SerializationSchema<VideoEvent> {
    @Override
    public byte[] serialize(VideoEvent event) {
        Gson gson = new GsonBuilder()
                .create();

        String jsonString = gson.toJson(event);
        return jsonString.getBytes(StandardCharsets.UTF_8);
    }
}
