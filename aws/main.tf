provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Origin = "Created by Terraform"
    }
  }
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = ["1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}