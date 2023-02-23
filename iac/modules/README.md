# Modules

- The general thought is to only create a module if you have to create more than 1 of a resource.
- Obviously there are some things duplicated in the video_detail module that are still duplicated(load balancers, ecs tasks, etc) but it's a work in progress.

## Detail

- datamart_destination_east_only - [data mart destination readme](./datamart_destination_east_only) - module used by data mart which is similar to the video_destination except that it's only in the east region
- datamart_east_only - [data mart readme](./datamart_east_only) - module used by data mart which is similar to the video_env except that it's only in the east region
- ecr - [ecr readme](./ecr) - ecr module
- firehose - [firehose readme](./firehose) - firehose module
- kda - [kda readme](./kda) - kinesis data analytics module
- kds-consumer - [kds consumer readme](./kds-consumer) - efo consumer creation module
- lambda-kds-notifier - [lambda kds notifier readme](./lambda-kds-notifier) - kds event trigger to Lambda module
- lambda-s3-notifier - [lambda s3 notifier readme](./lambda-s3-notifier) - s3 event trigger to Lambda module
- ondemand-kds - [ondemand kds readme](./ondemand-kds) - on-demand kinesis data stream module
- provisioned-kds - [provisioned kds readme](./provisioned-kds) - provisioned kinesis data stream module
- s3-kda - [s3 kda readme](./s3-kda) - bucket creation for flink kda CICD module
- s3-lambda - [s3 lambda readme](./s3-lambda) - bucket creation for lambda CICD module
- slow_prod_destination_east_only - [slow prod destination readme](./slow_prod_destination_east_only) - module used by slow prod which is similar to the video_destination except that it's only in the east region
- slow_prod_east_only - [slow prod readme](./slow_prod_east_only) - module used by slow prod which is similar to the - video_env except that it's only in the east region
- sns-event - [sns event readme](./sns-event) - s3 to sns for snowflake module
- video_destination - [video destination readme](./video_destination) - module containing s3 related code for cross region replication to us-east-1(destination)
- video_detail - [video detail readme](./video_detail) - module containing most of the pieces and parts of the architecture
- video_env - [video env readme](./video_env) - module containing items that are for all regions.
- video_source - [video source readme](./video_source) - module containing s3 related code for cross region replication from us-west-2(source)

## Structure

**Dev Environment**  
leverage the  
**video_env module**  
which leverages the  
**video_source and video_desintation modules**  
which each leverage the  
**video_detail module**  
which leverages the  
**firehose, kda, and kds modules**
