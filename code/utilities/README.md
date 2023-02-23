# utilities

- This contains utilities needed for the running of doppler-video.

## Failover / Failback

- s3-reader - this process takes a starting and ending date range, an s3 bucket, and an SQS queue.  It reads the objects from S3 within the date range and writes the object and s3 bucket into SQS.
- s3-loader - this process takes an SQS queue, and leverages the KPL sidecar.  It reads the message from the SQS queue, reads the S3 object, and loops through the records in the S3 object pushing them into Kinesis using the KPL sidecar.  Once all records have completed, the message is removed from the SQS queue.

**The failover processes are currently using the local pkg directory but we need to, at some point, migrate any changes to the common packages located in the doppler repo**