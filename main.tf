terraform {
  backend "s3" {
    bucket = "homebrew-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

locals {
  # these people can't have their membership managed by OpenTofu becuase they are Billing Managers in GitHub
  unmanagable_members = ["p-linnane", "issyl0", "colindean", "MikeMcQuaid", "BrewSponsorsBot"]
}

module "github" {
  source              = "./github"
  teams               = var.teams
  admins              = var.github_admins
  unmanagable_members = local.unmanagable_members
}

module "google-cloud" {
  source = "./google-cloud"
  ops    = module.github.ops
  tsc    = module.github.tsc
  plc    = module.github.plc
}

module "google-mailinglists" {
  source = "./google-mailinglists"
  ops    = module.github.ops
  tsc    = module.github.tsc
  plc    = module.github.plc
}