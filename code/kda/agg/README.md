# agg

- This Flink applications goal is to consume data from the raw Kinesis Data Stream, aggregate the data based on the supplied rules, and write to the aggregate Kinesis Data Stream.

- The code leverages the Datastream API described here: https://nightlies.apache.org/flink/flink-docs-release-1.13/docs/connectors/datastream/kinesis/

- The following are the Flink Properties used for this application:  
  - KINESIS_RAW_STREAM - The raw Kinesis Data Stream (KDS) to read from. Default is "default-kds-raw".  
  - KINESIS_LATE_STREAM - KDS populated with all data considered as late arriving in Flink. Default is "default-kds-late"
  - KINESIS_SESSION_STREAM - Aggregated, session based KDS. Default is "default-kds-session"
  - ENABLE_EFO - Enables advanced fan out on KDS. Default is false.
  - KINESIS_REGION - The region the aggregates KDS resides in. Default is "us-east-1".
  - KDA_LATE_ARRIVING_SECS - Number of seconds used to calculate the watermark based on the event time; all data arrived after the watermark is considered late. Default is 30 
  - KDA_VIDEO_SESSION_TTL_SECS - How many seconds after an event a session will be timed out, if no events are received. Default is 300
  - KDA_STATE_TTL_SECS - How many seconds we will keep state for the session in memory after inactivity. Default is 3600 
  - STREAM_POSITION - The initial position to start reading KDS from. Default is "latest"  

- The Flink application processes data based on event received time (stamped by the Receiver) but the actual time from the client is used to order events when processing a window.
