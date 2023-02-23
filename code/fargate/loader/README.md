# loader

This is the loader that sends records to the data mart and slow prod environments. It's similar to loader for load testing but it does no conversion and will be most likely be changed less so I thought it be better to have its own folder.

It does the following:

- Reads messages from the outbound SQS Queue that contain S3 Events(From Raw S3 Bucket via SNS to SQS).

- Reads the S3 Object.

- Loops through the records in the S3 Object pushing each record to a data mart kpl sidecar and a slow prod sidecar that write to destination Kinesis Data Streams.
