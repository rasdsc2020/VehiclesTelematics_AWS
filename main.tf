## region and credentials
provider "aws" {
  region = "${var.region}"
  access_key = "${var.access}"
  secret_key = "${var.secret}"
}

data "aws_kms_alias" "kms_encryption" {
  name = "alias/aws/s3"
}

## BUCKET NO 1
# aws create first s3 bucket: firehose destination bucket, processed data from lambda function
resource "aws_s3_bucket" "bucket" {
  bucket = "preprocessed-sns-bucket"
  acl    = "private"
  tags = {
    Description = "Preparing data from firehose for sns"
    Name        = "My bucket"
    Environment = "Testpahse"
  }
}

## BUCKET NO 2
# aws create second s3 bucket: firehose original backup data
resource "aws_s3_bucket" "bucket2" {
  bucket = "originaldata-backup-bucket"
  force_destroy = true
  acl    = "private"
  tags = {
    Purpose        = "Original data backup for machine learning models"
  }
}


## BUCKET NO 3
# aws create third s3 bucket: speeders bucket with filtered data

resource "aws_s3_bucket" "bucket3" {
  bucket = "consolidated-data-bucket-speeders"
  acl    = "private"
  force_destroy = true
  tags = {
    Name        = "Speeder 2-wheeler and 4-wheeler"
    Purpose     = "storing data of over speeding vehicles"
    Environment = "Dev"
  }
}



# create firehose
resource "aws_kinesis_firehose_delivery_stream" "my_firehose_stream" {
  name        = "${var.app_name}_vehicleTelematics"
  destination = "extended_s3"
  //refer the more s3 configuration at https://docs.aws.amazon.com/firehose/latest/APIReference/API_ExtendedS3DestinationConfiguration.html
  extended_s3_configuration  {
    role_arn        = "${aws_iam_role.firehose_role.arn}"
    bucket_arn      = aws_s3_bucket.bucket.arn
    buffer_size     = 5
    buffer_interval = "100"

    s3_backup_mode = "Enabled"
    s3_backup_configuration {
      role_arn   = "${aws_iam_role.firehose_role.arn}"
      bucket_arn = aws_s3_bucket.bucket2.arn
      prefix = "firehosebackup/"
    }

    processing_configuration {
      enabled = "true"
      processors {
        type = "Lambda"
        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.firehose_lambda.arn}:$LATEST"
        }
      }
    }


    }
  }


######## SNS prep lambda function to be invoked by s3 bucket put request ##########
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_prep.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}

# Adding S3 bucket as trigger to my sns_prep lambda and giving the permissions
##################
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.sns_prep.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.allow_bucket]
}



# Event source from SQS --- connect two_wheeler queue to recordreader1 lambda
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = aws_sqs_queue.two_whl_sqs.arn
  enabled          = true
  function_name    = "${aws_lambda_function.two_whl_recorder.arn}"
  batch_size       = 1
}

# Event source from SQS --- connect four_wheeler queue to recordreader2 lambda
resource "aws_lambda_event_source_mapping" "event_source_mapping_truck" {
  event_source_arn = aws_sqs_queue.four_whl_sqs.arn
  enabled          = true
  function_name    = "${aws_lambda_function.four_whl_recorder.arn}"
  batch_size       = 1
}

## cloudwatch event

resource "aws_cloudwatch_event_rule" "once_a_day" {
    name = "Once_a_day"
    description = "Fires every day at mid-night"
    schedule_expression = "cron(0 0 * * ? *)"
}

resource "aws_cloudwatch_event_target" "check_foo_once_a_day" {
    rule = "${aws_cloudwatch_event_rule.once_a_day.name}"
    target_id = "agglambda"
    arn = "${aws_lambda_function.agglambda.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_agglambda" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.agglambda.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.once_a_day.arn}"
}


### trigger sns final from s3 put event
resource "aws_s3_bucket_notification" "final_report_bucket_notification" {
  bucket = aws_s3_bucket.bucket3.id
  topic {
    topic_arn     = "${aws_sns_topic.final_report.arn}"
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "final-report/"
    filter_suffix = ".csv"
  }
}
