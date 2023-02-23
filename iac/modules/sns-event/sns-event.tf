#
# Topic creation - this SNS topic will be triggered at any ObjectCreate s3 event 
#
resource "aws_sns_topic" "topic" {
  name = var.name
}

#
# Topic policy. It includes permission to post from s3 plus permission for
# iam user and lambda function to subscribe to the SNS 
#
resource "aws_sns_topic_policy" "topic_policy" {
  arn    = aws_sns_topic.topic.arn
  policy = <<EOF
{
    "Version":"2012-10-17",
    "Id":"topic-access",
    "Statement" :[
        {
            "Sid":"publish-from-s3",
            "Effect":"Allow",
            "Principal" :{
                "Service": "s3.amazonaws.com"
             },
            "Action":["sns:Publish"],
            "Resource": "${aws_sns_topic.topic.arn}",
            "Condition": {
               "ArnLike": {
                  "aws:SourceArn": "arn:aws:s3:*:*:${var.s3_bucket_name}"
               }
            }
        },
        {
            "Sid": "allow-subscribe",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${var.snowflake_iam_user}"
            },
            "Action": [ "sns:Subscribe" ],
            "Resource": [ "${aws_sns_topic.topic.arn}" ]
        }
    ]
}
EOF
}

### And now adding the s3 event notification to the bucket...
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.s3_bucket_name

  topic {
    topic_arn = aws_sns_topic.topic.arn
    events    = ["s3:ObjectCreated:*"]
  }
}


