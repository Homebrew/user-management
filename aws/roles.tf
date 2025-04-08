data "aws_iam_policy_document" "codebuild_policy_document" {
  statement {
    actions   = ["logs:*"]
    resources = ["arn:aws:logs:*:*:*"]
    effect    = "Allow"
  }
  statement {
    actions = [
      "s3:List*",
      "s3:Get*",
      "s3:Put*",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "ecs:*",
      "ecr:*",
      "apigateway:*",
      "elasticloadbalancing:*",
      "iam:DeleteGroupMembership",
      "iam:DetachRolePolicy",
      "iam:DeletePolicy",
      "sso:TagResource"
    ]
    resources = [
      "arn:aws:s3:::homebrew-terraform-state/*",
      "arn:aws:s3:::homebrew-terraform-state"
    ]
    effect = "Allow"
  }
  statement {
    effect = "Allow"
    actions = [
      "iam:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "opentofu_policy" {
  name        = "OpentofuPolicy"
  path        = "/"
  description = "Policy to allow Opentofu to do it's thing"

  policy = data.aws_iam_policy_document.codebuild_policy_document.json
}

resource "aws_iam_role" "github_tf" {
  name        = "GitHubActionsRole"
  description = "Allow GitHub actions access"
  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:Homebrew/user-management:*"
          }
        }
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
      },
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:Homebrew/private:*"
          }
        }
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
      }
    ]
    Version = "2012-10-17"
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AWSSSOReadOnly",
    "arn:aws:iam::aws:policy/IAMReadOnlyAccess",
    aws_iam_policy.opentofu_policy.arn
  ]
}
