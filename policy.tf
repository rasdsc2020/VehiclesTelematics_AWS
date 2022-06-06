data "aws_caller_identity" "current" {}

resource "aws_iam_role" "firehose_role" {
  name = "${var.app_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "read_policy" {
  name = "${var.app_name}-read-policy"
  //description = "Policy to allow reading from the ${var.stream_name} stream"
  role = "${aws_iam_role.firehose_role.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [

        {
          "Effect": "Allow",
          "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
          ],
          "Resource": [
                "arn:aws:s3:::preprocessed-sns-bucket",
                "arn:aws:s3:::preprocessed-sns-bucket/*",
                "arn:aws:s3:::originaldata-backup-bucket",
                "arn:aws:s3:::originaldata-backup-bucket/*"
            ]
        },
        {
          "Effect": "Allow",
          "Action": [
              "glue:GetTableVersions"
          ],
          "Resource": "*"
       },
       {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction",
        "lambda:GetFunctionConfiguration"
      ],
      "Resource": "arn:aws:lambda:eu-central-1:*"
      }
  ]
}
EOF
}
