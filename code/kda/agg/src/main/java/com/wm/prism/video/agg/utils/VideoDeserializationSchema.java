// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package com.wm.prism.video.agg.utils;

import com.google.gson.JsonObject;
import com.wm.prism.video.agg.constructors.custom.VideoEvent;
import org.apache.flink.api.common.serialization.DeserializationSchema;
import org.apache.flink.api.common.typeinfo.TypeInformation;
import org.apache.flink.shaded.jackson2.com.fasterxml.jackson.databind.DeserializationFeature;
import org.apache.flink.shaded.jackson2.com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;

/**
 * Turn byte messages delivered by Kinesis into a Pojo objects to be processed
 * by Flink.
 * Example from training - based off the KafkaDeserializationSchema example
 *
 * @author vgiacomini
 * @see https://nightlies.apache.org/flink/flink-docs-master/api/java/org/apache/flink/api/common/serialization/DeserializationSchema.html
 * @see https://www.baeldung.com/kafka-flink-data-pipeline#custom-object-deserialization
 */
public class VideoDeserializationSchema implements DeserializationSchema<VideoEvent> {
    private static final Logger LOG = LoggerFactory.getLogger(VideoDeserializationSchema.class);
    private static final long serialVersionUID = 1L;

    private static final ObjectMapper objectMapper = new ObjectMapper()
            .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

    @Override
    public VideoEvent deserialize(byte[] message) throws IOException {
        try {
            return objectMapper.readValue(message, VideoEvent.class);
        } catch (Exception e) {
            // Get Error Message to JSON
            JsonObject errorContents = new JsonObject();
            errorContents.addProperty("message", e.toString());

            StringWriter sw = new StringWriter();
            PrintWriter pw = new PrintWriter(sw);
            e.printStackTrace(pw);
            String sStackTrace = sw.toString(); // stack trace as a string
            errorContents.addProperty("stackTrace", sStackTrace);

            // Add Error Message and stack Trace to a general videoError JSON obj
            JsonObject eventError = new JsonObject();
            eventError.add("eventError", errorContents);

            VideoEvent ev = objectMapper.readValue(eventError.toString().getBytes(), VideoEvent.class);
            ev.setEventType("video-qos-error");

            // Sleep Jitter before CloudWatch call to prevent CloudWatch ThrottlingException
            try {
                double time = Math.random() * 1000;
                Thread.sleep((long) (time));
            } catch (InterruptedException ex) {
                LOG.debug("Could not sleep before sending to CloudWatch" + ex);
            }

            return ev;
        }
    }

    @Override
    public boolean isEndOfStream(VideoEvent nextElement) {
        return false;
    }

    @Override
    public TypeInformation<VideoEvent> getProducedType() {
        return TypeInformation.of(VideoEvent.class);
    }
}