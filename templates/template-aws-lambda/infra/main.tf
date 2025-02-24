# locals {
#   app_name = "sample-app"
#   app_version = "0.0.2"
# }

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.app_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


resource "aws_lambda_function" "this" {
  function_name = var.app_name
  role          = aws_iam_role.this.arn

  package_type = "Image"
  image_uri = "${var.ecr_uri}/${var.app_name}:${var.app_version}"
}
