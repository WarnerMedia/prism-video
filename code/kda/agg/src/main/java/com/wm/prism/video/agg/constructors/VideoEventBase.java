// Copyright (c) Warner Media, LLC. All rights reserved. Licensed under the MIT license.
// See the LICENSE file for license information.
package com.wm.prism.video.agg.constructors;

import lombok.Getter;
import lombok.Setter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.io.Serializable;

@Getter
@Setter
public class VideoEventBase implements Serializable {

    private static final Logger LOG = LoggerFactory.getLogger(VideoEventBase.class);

    private String awsregion;
    private BackendUserAgentParser backendUserAgentParser;
    private String brand;
    private String cdn;
    private String customProperties;
    private Device device;
    private String deviceCode;
    private String environment;
    private Error error;
    private String eventId;
    private String eventName;
    private String eventTimestamp;
    private String eventType;
    private Ids ids;
    private String kdsHashKey;
    private Library library;
    private Location location;
    private Mvpd mvpd;
    private NavigationProperties navigationProperties;
    private String networkConnectionType;
    private String platform;
    private Player player;
    private ProductProperties productProperties;
    private String receivedAtTimestampString;
    private int receivedAtTimestamp;
    private Schema schema;
    private String sentAtTimestamp;
    private Session session;
    private String sourceIpAddress;
    private String subBrand;
    private Video video;
    private VideoSession videoSession;
    private String wmukid;

    private EventError eventError;

    @Getter
    @Setter
    public static class BackendUserAgentParser implements Serializable {
        private String browserName;
        private String browserVersion;
        private String device;
        private String deviceBrandName;
        private String model;
        private String operatingSystem;
        private String osVersion;
    }

    @Getter
    @Setter
    public static class Device implements Serializable {
        private String browserName;
        private String browserVersion;
        private String deviceBrand;
        private String deviceModel;
        private String deviceOs;
        private String deviceType;
        private String osVersion;
        private String userAgent;
    }

    @Getter
    @Setter
    /* Player error codes */
    public static class Error implements Serializable {
        private String errorCode;
        private String errorMessage;
        private String errorSeverity;
    }

    @Getter
    @Setter
    /* Error event created by Receiver when getting bad json */
    public static class EventError implements Serializable {
        private String message;
        private String stackTrace;
    }

    @Getter
    @Setter
    public static class Ids implements Serializable {
        private String cdpid;
    }

    @Getter
    @Setter
    public static class Library implements Serializable {
        private String name;
        private String version;
    }

    @Getter
    @Setter
    public static class Location implements Serializable {
        private String city;
        private String country;
        private String state;
        private String timezone;
    }

    @Getter
    @Setter
    public static class Mvpd implements Serializable {
        private String authRequired;
        private String authState;
        private String mvpdDisplayName;
        private String mvpdId;
    }

    @Getter
    @Setter
    public static class NavigationProperties implements Serializable {
        private String referrer;
        private String rootDomain;
    }

    @Getter
    @Setter
    public static class Player implements Serializable {
        private String playerVendor; // beta: playerName
        private String playerVersion;
    }

    @Getter
    @Setter
    public static class ProductProperties implements Serializable {
        private String appVersion;
        private String productName;
    }

    @Getter
    @Setter
    public static class Session implements Serializable {
        private String sessionId;
    }

    @Getter
    @Setter
    public static class Schema implements Serializable {
        private String schemaVersionNumber;
    }

    @Getter
    @Setter
    public static class Video implements Serializable {
        private String assetEpisodeNumber;
        private String assetId;
        private String assetIdType;
        private String assetName;
        private String assetSeasonNumber;
        private String assetSeries;
        private String assetType;
        private boolean autoplay;
        private Integer bitrate;
        private String currentMediaState;
        private String currentVideoPosition;
        private boolean freePreview;
        private String fullTitle;
        private String liveStreamName;
        private String previousMediaState;
        private String previousVideoPosition;
        private String streamHost;
        private String streamType;
        private String streamUrl;
        private Integer videoDurationSec;
    }

    @Getter
    @Setter
    public static class VideoSession implements Serializable {
        private String videoSessionId;
        private String videoSessionStartTimestamp;
    }

}
