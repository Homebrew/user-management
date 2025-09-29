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
      "sso:TagResource",
      "sso:Describe*",
      "sso:List*",
      "ecs:*",
      "ecr:*",
      "apigateway:*",
      "elasticloadbalancing:*",
      "identitystore:*",
      "kms:*",
      "ec2:*",
      "cloudwatch:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "opentofu_policy" {
  name        = "OpentofuApplyPolicy"
  path        = "/"
  description = "Policy to allow Opentofu to apply infrastructure changes"

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
}

resource "aws_iam_role_policy_attachment" "github_tf_opentofu_policy_attachment" {
  role       = aws_iam_role.github_tf.name
  policy_arn = aws_iam_policy.opentofu_policy.arn
}

data "aws_iam_policy_document" "ecr_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecr_policy" {
  name        = "ECRPushPolicy"
  path        = "/"
  description = "Policy to allow push to ECR"

  policy = data.aws_iam_policy_document.ecr_policy_document.json
}

resource "aws_iam_role" "github_ecr_push_role" {
  name        = "GithubActionsRoleECRPush"
  description = "Allow GitHub actions to push to ECR"
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
            "token.actions.githubusercontent.com:sub" = "repo:Homebrew/ci-orchestrator:*"
          }
        }
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "github_ecr_policy_attachment" {
  role       = aws_iam_role.github_ecr_push_role.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}

# Don't warn for iam:PassRole, we really need it (see the doc of the github action)
# https://github.com/aws-actions/amazon-ecs-deploy-task-definition
# trivy:ignore:AVD-AWS-0342
data "aws_iam_policy_document" "ecs_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
      "ecs:DescribeServices"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "iam:PassRole",
    ]
    resources = [
      "arn:aws:iam::${local.account_id}:role/ecs-host-execution-role",
      "arn:aws:iam::${local.account_id}:role/ecs-task-execution-role"
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "ecs_policy" {
  name        = "ECSDeployPolicy"
  path        = "/"
  description = "Policy to allow deploy a container to ECS"

  policy = data.aws_iam_policy_document.ecs_policy_document.json
}

resource "aws_iam_role" "github_ecs_deploy_role" {
  name        = "GithubActionsRoleECSDeploy"
  description = "Allow GitHub actions to deploy to ECS"
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
            "token.actions.githubusercontent.com:sub" = "repo:Homebrew/ci-orchestrator:*"
          }
        }
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "github_ecs_policy_attachment" {
  role       = aws_iam_role.github_ecs_deploy_role.name
  policy_arn = aws_iam_policy.ecs_policy.arn
}
