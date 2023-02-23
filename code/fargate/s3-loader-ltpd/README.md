# s3-loader-ltpd

This is the loader for the load test production environment.

It does the following:

- Reads messages from the util SQS Queue that contain S3 Objects.

- Reads the S3 Object.

- Loops through the records in the S3 Object pushing each record to a kpl sidecar that writes to a destination Kinesis Data Stream
