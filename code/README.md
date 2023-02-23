# Doppler-Video

## Description

- This repo contains all the code for Doppler Video broken out by resources used.

### Directories

- fargate - code that resides in Fargate
- kda - code that resides in KDA
- Lambda - code that resides in Lambda

### Deployment Strategies

- All code that is used today will be deployed via Github Actions.
- When a Pull Request is created, the code is built, and deployed to the Local environment to allow for out of band testing.
- When a Pull Request is merged into main, the code is built, tagged and deployed to the Development environment. As part of this process, the Docker images, Flink jars, and Lambda zips are each pushed to locations(docker images -> ECR, Flink jars -> S3, Lambda zips -> S3) where they can eventually be deployed to QA and Production environments via the github repo's below.
