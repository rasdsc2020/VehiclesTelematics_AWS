variable "region" {
  description = "The AWS region we want this bucket to live in."
  default     = "eu-central-1"
}


variable "access" {
  description = "Access key"
  default     = "Your_access_key_here"
}

variable "secret" {
  description = "Secret key"
  default     = "Your_secret_key_here"
}


variable "app_version" {
    default = "1.0.0"
}

variable "stage" {
	default = "dev"
}

variable "resource_name" {
	default = "number"
}


variable "app_name" {
  description = "The AWS region we want this bucket to live in."
  default     = "kinesis_firehose"
}

//aws_kinesis_stream variable
variable "shard_count" {
  description = "The number of shards that the stream will use."
  default     = "1"
}

variable "retention_period" {
  description = "Length of time data records are accessible after they are added to the stream."
  default     = "24"
}

variable "shard_level_metrics" {
  type        = list
  description = "A list of shard-level CloudWatch metrics which can be enabled for the stream."
  default     = []
}

variable "s3_bucket_arn" {
  description = "s3 bucket arn where kinesis firehose put data."
  default     = "arn:aws:s3:::bucket-firehose1"
}

variable "s3_bucket_path" {
  description = "s3 bucket path where kinesis firehose put data."
  default     = "s3://bucket-firehose1"
}

variable "storage_input_format" {
  description = "storage input format for aws glue for parcing data"
  default     = ""
}

variable "storage_output_format" {
  description = "storage output format for aws glue for parcing data"
  default     = ""
}

variable "step_function_name" {
  description = "stepfunc1"
  type = string
  default = "Firehose_step_function"
}
