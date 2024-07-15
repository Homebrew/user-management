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
  # these people can't have their membership managed by OpenTofu because they are Billing Managers in GitHub
  unmanagable_members = ["p-linnane", "issyl0", "colindean", "MikeMcQuaid", "BrewSponsorsBot"]
}

module "dnsimple" {
  source = "./dnsimple"
}

module "github" {
  source              = "./github"
  teams               = var.teams
  admins              = var.github_admins
  unmanagable_members = local.unmanagable_members
}

locals {
  emails = nonsensitive({ for username, email in module.github.member_emails : username => lookup(var.email_overrides, username, email) })
}

module "aws" {
  source = "./aws"
  teams = {
    Ops       = { for username in var.teams.maintainers.ops : username => local.emails[username] if lookup(local.emails, username, "") != "" }
    Security  = { for username in var.teams.security : username => local.emails[username] if lookup(local.emails, username, "") != "" }
    PLC       = { for username in var.teams.plc : username => local.emails[username] if lookup(local.emails, username, "") != "" }
    Analytics = { for username in var.teams.maintainers.analytics : username => local.emails[username] if lookup(local.emails, username, "") != "" }
  }
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
