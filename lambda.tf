
# Archive file for LAMBDA FUNCTION NO. 1
#create zip file for lambda function
data "archive_file" "firehoselambda" {
  type        = "zip"
  source_file = "python/firehose_lambda.py"
  output_path = "outputs/firehoselambda.zip"
}


# Archive file for LAMBDA FUNCTION NO. 2
#create zip file for the function invoked after s3 bucket to prepare data from sns
data "archive_file" "sns_prep" {
  type        = "zip"
  source_file = "python/sns_prep.py"
  output_path = "outputs/sns_prep.zip"
}

# Archive file for LAMBDA FUNCTION NO. 3
#create zip file for lambda function
data "archive_file" "two_whl_recorder" {
  type        = "zip"
  source_file = "python/two_whl_recorder.py"
  output_path = "outputs/two_whl_recorder.zip"
}


# Archive file for LAMBDA FUNCTION NO. 4
#create zip file for lambda function
data "archive_file" "four_whl_recorder" {
  type        = "zip"
  source_file = "python/four_whl_recorder.py"
  output_path = "outputs/four_whl_recorder.zip"
}


# Archive file for LAMBDA FUNCTION NO. 5
#create zip file for lambda function
data "archive_file" "agglambda" {
  type        = "zip"
  source_file = "python/Aggregator.py"
  output_path = "outputs/agglambda.zip"
}


# create a lambda layer for pandas and numpy: awswrangler
resource "aws_lambda_layer_version" "aws_wrangler_layer" {
  filename = "awswrangler-layer-2.10.0-py3.8.zip"
  layer_name = "pandaslayer"
  compatible_runtimes = ["python3.8"]
}


# LAMBDA FUNCTION NO. 1
#create firehose processing function, it processed data within firehose...
resource "aws_lambda_function" "firehose_lambda" {
  filename      = "outputs/firehoselambda.zip"
  function_name = "firehose_lambda"
  role          = "${aws_iam_role.lambda_role.arn}"
  handler       = "firehose_lambda.lambda_handler"
  layers = [aws_lambda_layer_version.aws_wrangler_layer.arn]
  source_code_hash = "${data.archive_file.firehoselambda.output_base64sha256}"
  runtime = "python3.8"
  timeout = 90
  description = "Process input inside firehose: append two_wheeler or four_wheeler "
}



# LAMBDA FUNCTION NO. 2
#Lambda function for sns to decide which sqs to invoke...
resource "aws_lambda_function" "sns_prep" {
  filename      = "outputs/sns_prep.zip"
  function_name = "sns_prep"
  role          = "${aws_iam_role.lambda_role.arn}"
  handler       = "sns_prep.lambda_handler"
  description = "After s3 this lambda preprocess sns input: msg attributes and invoke sns"
  layers = [aws_lambda_layer_version.aws_wrangler_layer.arn]
  source_code_hash = "${data.archive_file.sns_prep.output_base64sha256}"
  runtime = "python3.8"
  timeout = 90
}

# LAMBDA FUNCTION NO. 3
#create record processing function, json to csv and overspeeder fucntion...

resource "aws_lambda_function" "two_whl_recorder" {
  filename      = "outputs/two_whl_recorder.zip"
  function_name = "two_whl_recorder"
  role          = "${aws_iam_role.lambda_role.arn}"
  handler       = "two_whl_recorder.lambda_handler"
  description = "After sns/sqs process for two Wheeler"
  layers = [aws_lambda_layer_version.aws_wrangler_layer.arn]
  source_code_hash = "${data.archive_file.two_whl_recorder.output_base64sha256}"
  runtime = "python3.8"
  timeout = 180
  environment {
    variables = {
      ALERT_PHONE_NUMBER = "phone number",
      SPEED_ALERT_THRESHOLD = 120
    }
  }

}


# LAMBDA FUNCTION NO. 4
# Lambda to preprocess and record four wheeler over speeding data
resource "aws_lambda_function" "four_whl_recorder" {
  filename      = "outputs/four_whl_recorder.zip"
  function_name = "four_whl_recorder"
  role          = "${aws_iam_role.lambda_role.arn}"
  handler       = "four_whl_recorder.lambda_handler"
  description = "After sns/sqs process for four Wheeler"
  layers = [aws_lambda_layer_version.aws_wrangler_layer.arn]
  source_code_hash = "${data.archive_file.four_whl_recorder.output_base64sha256}"
  runtime = "python3.8"
  timeout = 180
  environment {
    variables = {
      ALERT_PHONE_NUMBER = "phone number",
      SPEED_ALERT_THRESHOLD = 120
    }
  }
}

# LAMBDA FUNCTION NO. 5
#2nd function choice for the step function..
resource "aws_lambda_function" "agglambda" {
  filename      = "outputs/agglambda.zip"
  function_name = "agglambda"
  role          = "${aws_iam_role.lambda_role.arn}"
  handler       = "Aggregator.lambda_handler"
  description = "Merge all csv file for two wheeler and four wheeler on daily basis"
  layers = [aws_lambda_layer_version.aws_wrangler_layer.arn]
  source_code_hash = "${data.archive_file.agglambda.output_base64sha256}"
  runtime = "python3.8"
  timeout = 300
}
