## create a SNS topic which will be handling request from lambda function

resource "aws_sns_topic" "Vehicle_sns_terraform" {
    name = "Vehicle_sns_terraform"
}


## create a SNS topic for final report via email
resource "aws_sns_topic" "final_report" {
    name = "final_report"
    policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": { "Service": "s3.amazonaws.com" },
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:*:*:final_report",
        "Condition":{
            "ArnLike":{"aws:SourceArn":"arn:aws:s3:::consolidated-data-bucket-speeders"}
        }
    }]
}
POLICY
}


## Two_wheeler_sqs
## Next lets add our SQS queue which will get data from SNS topic.
resource "aws_sqs_queue" "two_whl_sqs" {
    name = "two_whl_sqs"
    redrive_policy  = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.two_whl_sqs_dl_queue.arn}\",\"maxReceiveCount\":5}"
    visibility_timeout_seconds = 300

    tags = {
        Environment = "dev"
    }
}

## Two wheeler
## This is our Dead Letter Queue, it’s just a simple SQS queue. Just like the one above.
resource "aws_sqs_queue" "two_whl_sqs_dl_queue" {
    name = "two_whl_sqs_dl_queue"
}

## Four wheeler
## Next lets add our SQS queue which will get data from SNS topic.
resource "aws_sqs_queue" "four_whl_sqs" {
    name = "four_whl_sqs"
    redrive_policy  = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.four_whl_sqs_dl_queue.arn}\",\"maxReceiveCount\":5}"
    visibility_timeout_seconds = 300

    tags = {
        Environment = "dev"
    }
}

## Four wheeler
## This is our Dead Letter Queue, it’s just a simple SQS queue. Just like the one above.
resource "aws_sqs_queue" "four_whl_sqs_dl_queue" {
    name = "four_whl_sqs_dl_queue"
}

## Two Wheeler
## Now we will need to create a subscription, which will allow our SQS queue to receive notifications from the SNS topic we created above.
resource "aws_sns_topic_subscription" "Vehicle_sns_terraform_sqs_target" {
    topic_arn = "${aws_sns_topic.Vehicle_sns_terraform.arn}"
    protocol  = "sqs"
    endpoint  = "${aws_sqs_queue.two_whl_sqs.arn}"
    filter_policy = <<EOF
  {"VehicleType": ["Two wheeler"]}
  EOF
}

## Four wheeler
## Now we will need to create a subscription, which will allow our SQS queue to receive notifications from the SNS topic we created above.
resource "aws_sns_topic_subscription" "Vehicle_sns_terraform_sqs_target_truck" {
    topic_arn = "${aws_sns_topic.Vehicle_sns_terraform.arn}"
    protocol  = "sqs"
    endpoint  = "${aws_sqs_queue.four_whl_sqs.arn}"
    filter_policy = <<EOF
  {"VehicleType": ["Four wheeler"]}
  EOF
}


##Two Wheeler
## SQS policy that is needed for our SQS to actually receive events from the SNS topic
resource "aws_sqs_queue_policy" "two_whl_sqs_queue_policy" {
    queue_url = "${aws_sqs_queue.two_whl_sqs.id}"

    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.two_whl_sqs.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.Vehicle_sns_terraform.arn}"
        }
      }
    }
  ]
}
POLICY
}


## Four wheeler
## SQS policy that is needed for our SQS to actually receive events from the SNS topic
resource "aws_sqs_queue_policy" "four_whl_sqs_queue_policy" {
    queue_url = "${aws_sqs_queue.four_whl_sqs.id}"

    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.four_whl_sqs.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.Vehicle_sns_terraform.arn}"
        }
      }
    }
  ]
}
POLICY
}


## send email from SNS
resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = aws_sns_topic.final_report.arn
  protocol  = "email"
  endpoint  = "rasheerashee@yandex.com"
}
