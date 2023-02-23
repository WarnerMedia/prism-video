// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package com.wm.prism.video.agg.constructors.custom;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import org.apache.flink.util.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

@Getter
@Setter
@ToString
public class VideoSession {

    private static final Logger LOG = LoggerFactory.getLogger(VideoSession.class);

    private String videoSessionId;
    private String wmukid;
    private String awsregion;
    private String brand;
    private String assetName;
    private String platform;
    private String streamType;
    private String appVersion;
    private String city;
    private String cdn;
    private String playerVersion;
    private String deviceOs;
    private String osVersion;
    private String browserName;
    private String browserVersion;
    private String deviceModel;
    private String assetType;
    private String productName;
    private String subBrand;
    private String deviceType;
    private String libraryName;
    private String libraryVersion;
    private String playerVendor;

    private long latestWindow;
    private long sessionStartTimeMs;
    private String endedPlayReason;
    private long previousEventTimestampMS;
    private long previousBufferStartTimeMs;
    private String previousMediaState;
    private long previousAttemptTimestampMS;
    private long playTimeMS;
    private long attemptTimeMS;

    // metrics
    private int playCount;

    // error info on the session
    private String errorSeverity;
    private String errorCode;
    private String errorMessage;

    // for timestream
    private String timeUnit;

    /* Flink default constructor */
    public VideoSession() {
    }

    /* constructor to create a VideoSession from a VideoEvent */
    public VideoSession(VideoEvent event) {
        this.setAwsregion(event.getAwsregion());
        this.setBrand(event.getBrand());
        this.setSubBrand(event.getSubBrand());
        this.setPlatform(event.getPlatform());

        if (event.getProductProperties() != null) {
            this.setAppVersion(event.getProductProperties().getAppVersion());
            this.setProductName(event.getProductProperties().getProductName());
        }

        if (event.getVideo() != null) {
            this.setAssetName(event.getVideo().getAssetName());
            this.setStreamType(event.getVideo().getStreamType());
            this.setAssetType(event.getVideo().getAssetType());
        }

        if (event.getPlayer() != null) {
            this.setPlayerVendor(event.getPlayer().getPlayerVendor());
            this.setPlayerVersion(event.getPlayer().getPlayerVersion());
        }

        if (event.getLibrary() != null) {
            this.setLibraryName(event.getLibrary().getName());
            this.setLibraryVersion(event.getLibrary().getVersion());
        }

        if (event.getBackendUserAgentParser() != null) {
            this.setDeviceOs(event.getBackendUserAgentParser().getOperatingSystem());
            this.setOsVersion(event.getBackendUserAgentParser().getOsVersion());
            this.setBrowserName(event.getBackendUserAgentParser().getBrowserName());
            this.setBrowserVersion(event.getBackendUserAgentParser().getBrowserVersion());
            this.setDeviceModel(event.getBackendUserAgentParser().getModel());
            this.setDeviceType(event.getBackendUserAgentParser().getDevice());
        }

        this.setCity(event.getLocation() != null ? event.getLocation().getCity() : null);
        this.setCdn(event.getCdn());
        this.setWmukid(event.getWmukid());
        this.setVideoSessionId(event.getVideoSession().getVideoSessionId());
        this.setSessionStartTimeMs(event.getEventTimestampInMS());
    }

    /**
     * Updates the videoSession with values from the event if the attribute in the
     * session is null or empty
     * 
     * @param evList List of events
     * @return
     */
    public void updateVideoSessionMetadata(List<VideoEvent> evList) {

        for (VideoEvent e : evList) {
            if (this.getSessionStartTimeMs() == 0L
                    || this.getSessionStartTimeMs() > e.getEventReceivedAtTimestampInMS()) {
                this.setSessionStartTimeMs(e.getEventReceivedAtTimestampInMS());
            }
            // session value is empty and event contains a value
            if (StringUtils.isNullOrWhitespaceOnly(this.getAssetName()) &&
                    !StringUtils.isNullOrWhitespaceOnly(e.getVideo().getAssetName())) {
                this.setAssetName(e.getVideo().getAssetName().trim());
            }
            if (StringUtils.isNullOrWhitespaceOnly(this.getAssetType()) &&
                    !StringUtils.isNullOrWhitespaceOnly(e.getVideo().getAssetType())) {
                this.setAssetType(e.getVideo().getAssetType().trim());
            }
            if (StringUtils.isNullOrWhitespaceOnly(this.getAwsregion()) &&
                    !StringUtils.isNullOrWhitespaceOnly(e.getAwsregion())) {
                this.setAwsregion(e.getAwsregion().trim());
            }
            if (StringUtils.isNullOrWhitespaceOnly(this.getAppVersion()) &&
                    !StringUtils.isNullOrWhitespaceOnly(e.getProductProperties().getAppVersion())) {
                this.setAppVersion(e.getProductProperties().getAppVersion().trim());
            }
            if (StringUtils.isNullOrWhitespaceOnly(this.getBrand()) &&
                    !StringUtils.isNullOrWhitespaceOnly(e.getBrand())) {
                this.setBrand(e.getBrand().trim());
            }
            if (StringUtils.isNullOrWhitespaceOnly(this.getCdn()) &&
                    !StringUtils.isNullOrWhitespaceOnly(e.getCdn())) {
                this.setCdn(e.getCdn().trim());
            }
            if (StringUtils.isNullOrWhitespaceOnly(this.getCity()) &&
                    !StringUtils.isNullOrWhitespaceOnly(e.getLocation().getCity())) {
                this.setCity(e.getLocation().getCity().trim());
            }
            if (StringUtils.isNullOrWhitespaceOnly(this.getLibraryName()) &&
                    !StringUtils.isNullOrWhitespaceOnly(e.getLibrary().getName())) {
                this.setLibraryName(e.getLibrary().getName().trim());
            }
            if (StringUtils.isNullOrWhitespaceOnly(this.getLibraryVersion()) &&
                    !StringUtils.isNullOrWhitespaceOnly(e.getLibrary().getVersion())) {
                this.setLibraryVersion(e.getLibrary().getVersion().trim());
            }
            if (StringUtils.isNullOrWhitespaceOnly(this.getPlatform()) &&
                    !StringUtils.isNullOrWhitespaceOnly(e.getPlatform())) {
                this.setPlatform(e.getPlatform().trim());
            }
            if (StringUtils.isNullOrWhitespaceOnly(this.getPlayerVendor()) &&
                    !StringUtils.isNullOrWhitespaceOnly(e.getPlayer().getPlayerVendor())) {
                this.setPlayerVendor(e.getPlayer().getPlayerVendor().trim());
            }
            if (StringUtils.isNullOrWhitespaceOnly(this.getPlayerVersion()) &&
                    !StringUtils.isNullOrWhitespaceOnly(e.getPlayer().getPlayerVersion())) {
                this.setPlayerVersion(e.getPlayer().getPlayerVersion().trim());
            }
            if (StringUtils.isNullOrWhitespaceOnly(this.getProductName()) &&
                    !StringUtils.isNullOrWhitespaceOnly(e.getProductProperties().getProductName())) {
                this.setProductName(e.getProductProperties().getProductName().trim());
            }
            if (StringUtils.isNullOrWhitespaceOnly(this.getStreamType()) &&
                    !StringUtils.isNullOrWhitespaceOnly(e.getVideo().getStreamType())) {
                this.setStreamType(e.getVideo().getStreamType().trim());
            }
            if (StringUtils.isNullOrWhitespaceOnly(this.getSubBrand()) &&
                    !StringUtils.isNullOrWhitespaceOnly(e.getSubBrand())) {
                this.setSubBrand(e.getSubBrand().trim());
            }
            if (!StringUtils.isNullOrWhitespaceOnly(this.getPlatform())) {
                switch (this.getPlatform().toLowerCase()) {
                    case "web": {
                        if (e.getBackendUserAgentParser() != null) {
                            if (StringUtils.isNullOrWhitespaceOnly(this.getDeviceOs()))
                                this.setDeviceOs(e.getBackendUserAgentParser().getOperatingSystem());
                            if (StringUtils.isNullOrWhitespaceOnly(this.getOsVersion()))
                                this.setOsVersion(e.getBackendUserAgentParser().getOsVersion());
                            if (StringUtils.isNullOrWhitespaceOnly(this.getBrowserName()))
                                this.setBrowserName(e.getBackendUserAgentParser().getBrowserName());
                            if (StringUtils.isNullOrWhitespaceOnly(this.getBrowserVersion()))
                                this.setBrowserVersion(e.getBackendUserAgentParser().getBrowserVersion());
                            if (StringUtils.isNullOrWhitespaceOnly(this.getDeviceModel()))
                                this.setDeviceModel(e.getBackendUserAgentParser().getModel());
                            if (StringUtils.isNullOrWhitespaceOnly(this.getDeviceType()))
                                this.setDeviceType(e.getBackendUserAgentParser().getDevice());
                        }
                    }
                    default: {
                        if (e.getDevice() != null) {
                            if (StringUtils.isNullOrWhitespaceOnly(this.getDeviceOs()))
                                this.setDeviceOs(e.getDevice().getDeviceOs());
                            if (StringUtils.isNullOrWhitespaceOnly(this.getOsVersion()))
                                this.setOsVersion(e.getDevice().getOsVersion());
                            if (StringUtils.isNullOrWhitespaceOnly(this.getDeviceModel()))
                                this.setDeviceModel(e.getDevice().getDeviceModel());
                            if (StringUtils.isNullOrWhitespaceOnly(this.getDeviceType()))
                                this.setDeviceType(e.getDevice().getDeviceType());
                        }
                    }
                }
            }

        }
    }

}
