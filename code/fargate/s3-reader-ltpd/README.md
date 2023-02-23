# s3-reader-ltpd

This is the reader for the load test production environment.

It does the following:

- Reads messages from the job SQS Queue that contain JSON describing the date range to process.

Example Job.

`{
"start_year": "2022",
"start_month": "4",
"start_day": "4",
"start_hour": "17",
"end_year": "2022",
"end_month": "4",
"end_day": "4",
"end_hour": "20"
}`

- It starts a loop by beginning with start date range, reading the s3 objects from each bucket folder and writing the S3 objects location to SQS

- It continues writing S3 objects to SQS until it reaches the end date range.
