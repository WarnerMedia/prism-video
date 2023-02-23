// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package com.wm.prism.video.agg.constructors.custom;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.wm.prism.video.agg.constructors.VideoEventBase;
import com.wm.prism.video.agg.utils.Constants;
import com.wm.prism.video.agg.utils.DateUtils;
import lombok.Getter;
import lombok.Setter;
import org.apache.flink.util.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Getter
@Setter
public class VideoEvent extends VideoEventBase {

    private static final Logger LOG = LoggerFactory.getLogger(VideoEvent.class);
    private static final Gson gson = new GsonBuilder().create();
    private Long eventReceivedAtTimestampInMS;
    private Long eventTimestampInMS;

    public VideoEvent() {
        this.setIds(new Ids());
        this.setMvpd(new Mvpd());
        this.setPlayer(new Player());
        this.setProductProperties(new ProductProperties());
        this.setSession(new Session());
        this.setVideo(new Video());
        this.setVideoSession(new VideoSession());
        this.setLocation(new Location());
        this.setLibrary(new Library());
        this.setEventError(new EventError());
        this.setBackendUserAgentParser(new BackendUserAgentParser());
        this.setNavigationProperties(new NavigationProperties());
        this.setError(new Error());
        this.setSchema(new Schema());
        this.setDevice(new Device());
    }

    /**
     * Converts eventTimestamp from String into MS - if eventTimestamp is null OR
     * fails parsing assume the serverReceived timestamp, so Flink
     * does not bomb. We window the events by the eventReceivedAt timestamp but
     * order the events within the window by the client timestamp (eventTimestampMS)
     *
     * @see com.wm.prism.video.agg.functions.PrismVideoSessionHandler
     * @return eventTimestamp in MS (Long)
     */
    public Long getEventTimestampInMS() {
        if (getEventTimestamp() == null) {
            eventTimestampInMS = this.getEventReceivedAtTimestampInMS();
        } else {
            if (this.eventTimestampInMS == null) {
                try {
                    setEventTimestampInMS(DateUtils.convertIso8601ToMsEpoc(getEventTimestamp()));
                } catch (Exception e) {
                    // using receivedAtTimestamp instead of eventTimestamp if an exception happens
                    // on parsing the date
                    eventTimestampInMS = this.getEventReceivedAtTimestampInMS();
                    LOG.warn("Payload contains a NULL or invalid eventTimestamp attribute: {} ",
                            this.getEventTimestamp());
                }
            }
        }
        return eventTimestampInMS;
    }

    /**
     * Helper method
     * 
     * @return videoSessionId
     */
    public String getVideoSessionId() {
        return !StringUtils.isNullOrWhitespaceOnly(super.getVideoSession().getVideoSessionId())
                ? super.getVideoSession().getVideoSessionId().strip()
                : "default-video-session-id";
    }

    public String toString() {
        return gson.toJson(this);
    }

    /**
     * This is an override of the main class; once we set the
     * receivedAtTimestampString attribute
     * we will also set the eventReceivedAtTimestampInMS, which is just a conversion
     * from the prior
     * one and should be set at the same time
     * 
     * @param receivedAtTimestampString
     */
    @Override
    public void setReceivedAtTimestampString(String receivedAtTimestampString) {
        super.setReceivedAtTimestampString(receivedAtTimestampString);
        this.eventReceivedAtTimestampInMS = DateUtils.convertIso8601ToMsEpoc(receivedAtTimestampString);
    }

}
