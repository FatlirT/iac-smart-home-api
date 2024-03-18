resource "aws_iam_instance_profile" "secrets_profile" {
  name = "secrets_profile"
  role = aws_iam_role.role.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]

  }
}


data "aws_iam_policy_document" "get_secrets" {
  statement {
    effect = "Allow"

    actions = ["secretsmanager:GetSecretValue"]

    resources = ["arn:aws:secretsmanager:eu-west-2:471112824706:secret:*"]

    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "aws:ResourceTag/App"

      values = [
        "ce-smart-home"
      ]
    }
  }
}

resource "aws_iam_role" "role" {
  name               = "secrets_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  inline_policy {
    name = "get-secrets"
    policy = data.aws_iam_policy_document.get_secrets.json
  }
}