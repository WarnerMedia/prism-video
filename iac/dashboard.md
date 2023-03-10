# Resource Dashboard

## What resources are being monitored in the Dashboard?

- Application Load Balancer(ALB)
  - A load balancer serves as the single point of contact for clients. Clients send requests to the load balancer, and the load balancer sends them to targets(i.e. containers).
- Target Group
  - Each target group is used to route requests to one or more registered targets(i.e. containers).
- Fargate Containers(ECS)
  - Docker containers providing business logic.
- Kinesis Data Streams(KDS)
  - Amazon Kinesis Data Streams (KDS) is a massively scalable and durable real-time data streaming service.
- Kinesis Firehose(Firehose)
  - Amazon Kinesis Data Firehose is the easiest way to reliably load streaming data into data lakes, data stores, and analytics services.
- Kinesis Data Analytics(KDA)
  - Amazon Kinesis Data Analytics is the easiest way to transform and analyze streaming data in real time with Apache Flink.
- Global Accelerator(GA)
  - AGA is a networking service that improves the performance of your users’ traffic by up to 60% using Amazon Web Services’ global network infrastructure. When the internet is congested, AWS Global Accelerator optimizes the path to your application to keep packet loss, jitter, and latency consistently low.
- Timestream
  - Amazon Timestream is a fast, scalable, and serverless time series database service for IoT and operational applications that makes it easy to store and analyze trillions of events per day up to 1,000 times faster and at as little as 1/10th the cost of relational databases.
- Custom Metrics
  - Metrics provided from within the code via StatsD and the Cloudwatch Agent.

## What statistics are being monitored by resource and why?

### Application Load Balancer(ALB)

- ResponseCodeCounts of all the 2xx, 3xx, 4xx and 5xx Requests
  - The number of HTTP codes that originate from the load balancer for each type(2xx, 3xx, 4xx, and 5xx)
- Requests Per Minute
  - The number of requests processed over IPv4 and IPv6. This metric is only incremented for requests where the load balancer node was able to choose a target. Requests rejected before a target is chosen (for example, HTTP 460, HTTP 400, some kinds of HTTP 503 and 500) are not reflected in this metric.
- us-east-1 ResponseCounts
  - More granular representation of the response code counts in the us-east-1 region.
- us-east-1 ResponseTimes
  - Representation of the time it takes to respond to a request in us-east-1 region.
- us-west-2 ResponseCounts
  - More granular representation of the response code counts in the us-west-2 region.
- us-west-2 ResponseTimes
  - Representation of the time it takes to respond to a request in us-west-2 region.

### Target Group(Target)

- UnHealthyHostCount
  - The number of targets(i.e. containers) that are considered unhealthy.
- HealthyHostCount
  - The number of targets(i.e. containers) that are considered healthy.
- ResponseTime
  - The time elapsed, in seconds, after the request leaves the load balancer until a response from the target is received.
- RequestCount
  - The number of requests processed over IPv4 and IPv6. This metric is only incremented for requests where the load balancer node was able to choose a target. Requests rejected before a target is chosen (for example, HTTP 460, HTTP 400, some kinds of HTTP 503 and 500) are not reflected in this metric.
- HTTP 5XXs
  - The number of 5XX HTTP response codes generated by the targets. This does not include any response codes generated by the load balancer.
- HTTP 4XXs
  - The number of 4XX HTTP response codes generated by the targets. This does not include any response codes generated by the load balancer.
- HTTP 3XXs
  - The number of 3XX HTTP response codes generated by the targets. This does not include any response codes generated by the load balancer.
- HTTP 2XXs
  - The number of 2XX HTTP response codes generated by the targets. This does not include any response codes generated by the load balancer.
- us-east-1 ResponseCounts
  - More granular representation of the response code counts in the us-east-1 region.
- us-west-2 ResponseCounts
  - More granular representation of the response code counts in the us-west-2 region.

### Fargate Containers(ECS)

- Service MemoryUtilized
  - The memory being used by all tasks within the service.
- Service Memory and CPU Utilization
  - The memory and cpu utilization as a percentage.
- Service RunningTaskCount
  - The number of tasks currently in the RUNNING state.
- Service CpuUtilized(In Units not percentage)
  - The CPU units used by all tasks within the service.
- Service CPUUtilization >= 70%
  - Graph to show CPU Usage greater than 70%(where ECS autoscales up)

### Kinesis Data Streams(KDS)

- PutRecords.Success
  - The number of successful PutRecord operations per Kinesis stream, measured over the specified time period. Average reflects the percentage of successful writes to a stream.
- PutRecords.SuccessfulRecords
  - The number of successful records in a PutRecords operation per Kinesis data stream, measured over the specified time period.
- PutRecords.FailedRecords
  - The number of records rejected due to internal failures in a PutRecords operation per Kinesis data stream, measured over the specified time period. Occasional internal failures are to be expected and should be retried.
- PutRecords.Latency
  - The time taken per PutRecords operation, measured over the specified time period.
- KPL RetriesPerRecord
  - Number of retries performed per user record. Zero is emitted for records that succeed in one try.
- WriteProvisionedThroughputExceeded
  - The number of records rejected due to throttling for the stream over the specified time period. This metric includes throttling from PutRecord and PutRecords operations. The most commonly used statistic for this metric is Average.
- us-east-1 Raw KPL
  - All Raw KPL metrics in one location for us-east-1.
- us-west-2 Raw KPL
  - All Raw KPL metrics in one location for us-west-2.
- us-east-1 Sess KPL
  - All Agg KPL metrics in one location for us-east-1.
- us-west-2 Sess KPL
  - All Agg KPL metrics in one location for us-west-2.

### Kinesis Firehose(Firehose)

- DeliveryToS3.Success
  - The sum of successful Amazon S3 put commands over the sum of all Amazon S3 put commands. Kinesis Data Firehose always emits this metric regardless of whether backup is enabled for failed documents only or for all documents.
- DeliveryToS3.Records
  - The number of records delivered to Amazon S3 over the specified time period. Kinesis Data Firehose emits this metric only when you enable backup for all documents.
- DeliveryToS3.DataFreshness
  - The age (from getting into Kinesis Data Firehose to now) of the oldest record in Kinesis Data Firehose. Any record older than this age has been delivered to the S3 bucket. Kinesis Data Firehose emits this metric only when you enable backup for all documents.
- KinesisMillisBehindLatest
  - When the data source is a Kinesis data stream, this metric indicates the number of milliseconds that the last read record is behind the newest record in the Kinesis data stream.

### Kinesis Data Analytics(KDA)

- Uptime
  - The time(in milliseconds) that the job has been running without interruption.
- Downtime
  - For jobs currently in a failing/recovering situation, the time elapsed(in milliseconds) during this outage.
- Number of KPUs
  - The number of Kinesis Processing Units (KPUs) currently in use.
- fullRestarts
  - The total number of times this job has fully restarted since it was submitted. This metric does not measure fine-grained restarts.
- cpuUtilization
  - Overall percentage of CPU utilization across task managers. For example, if there are five task managers, Kinesis Data Analytics publishes five samples of this metric per reporting interval.
- numberOfFailedCheckpoints
  - The number of times checkpointing has failed.
- lastCheckpointSize
  - The total size of the last checkpoint
- currentOutputWatermark
  - The last watermark this application/operator/task/thread has emitted
- millisBehindLatest
  - The number of milliseconds the consumer is behind the head of the stream, indicating how far behind current time the consumer is.
- numRecordsInPerSecond
  - The total number of records this application, operator or task has received per second.
- numRecordsOutPerSecond
  - The total number of records this application, operator or task has emitted per second.
- numLateRecordsDropped
  - The number of records this operator or task has dropped due to arriving late.

### Global Accelerator(GA)

- NewFlowCount
  - The total number of new TCP and UDP flows (or connections) established from clients to endpoints in the time period.
- Flow Count By Edge location
  - The total number of new TCP and UDP flows (or connections) established from clients to endpoints in the time period. This is filtered by the destination edge, which is the geographic area of the AWS edge locations that serve your client traffic.
- Flow Count by Region
  - The total number of new TCP and UDP flows (or connections) established from clients to endpoints in the time period. This is filtered by the source region, which is the geographic area of the AWS Regions where your application endpoints are running.

### Timestream

- WriteRecords SuccessfulRequestLatency Avg
  - The successful requests to Timestream during the specified time period. SuccessfulRequestLatency can provide two different kinds of information:
    - The elapsed time for successful requests (Minimum, Maximum,Sum, or Average).
    - The number of successful requests (SampleCount).
- WriteRecords SuccessfulRequestLatency Count
  - Sample Count Version of above.
- WriteRecords UserErrors SystemErrors
  - Requests to Timestream that generate an InvalidRequest error during the specified time period. An InvalidRequest usually indicates a client-side error, such as an invalid combination of parameters, an attempt to update a nonexistent table, or an incorrect request signature. UserErrors represents the aggregate of invalid requests for the current AWS Region and the current AWS account.
  - The requests to Timestream that generate a SystemError during the specified time period. A SystemError usually indicates an internal service error.

### Lambda

...

### Custom Metrics

- API Error Counts - Other
  - This is the count of the various ways a request is thrown out.
    - Missing Media Type
    - Unsupported Media Type
    - Missing Required Field
    - Unable to Decode the Body
    - Request was not a POST
- API Error Counts - GoogleBots
  - This is the count of the various Google Bots that are thrown out.
    - Google Bot
    - Ads Bot
- API timing - Happy path
  - The average time(in milliseconds) from request entering the API until it's pushed into KDS via the KPL.
