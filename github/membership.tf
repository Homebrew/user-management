locals {
  members = concat(
    var.teams.bots,
    var.teams.plc,
    var.teams.security,
    var.teams.security,
    var.teams.members,
    flatten(values(tomap(var.teams.maintainers))),
    flatten(values(tomap(var.teams.taps)))
  )
}

resource "github_membership" "general" {
  for_each = toset([for member in local.members : member if !contains(var.unmanagable_members, member)])
  username = each.key
  role     = contains(var.admins, each.key) ? "admin" : "member"
}

resource "github_team_repository" "brew" {
  team_id    = github_team.maintainers["brew"].id
  repository = "brew"
  permission = "maintain"
}

resource "github_team_repository" "cask" {
  team_id    = github_team.maintainers["cask"].id
  repository = "homebrew-cask"
  permission = "maintain"
}

resource "github_team_repository" "core" {
  team_id    = github_team.maintainers["core"].id
  repository = "homebrew-core"
  permission = "maintain"
}

resource "github_team_repository" "formulae-brew-sh" {
  team_id = github_team.maintainers["formulae_brew_sh"].id
  repository = "formulae.brew.sh"
  permission = "maintain"
}

resource "github_team_repository" "ci-orchestrator" {
  team_id    = github_team.maintainers["ci-orchestrator"].id
  repository = "ci-orchestrator"
  permission = "write"
}

resource "github_team_repository" "ops" {
  team_id    = github_team.maintainers["ops"].id
  repository = "ops"
  permission = "maintain"
}

resource "github_team_repository" "actions" {
  team_id    = github_team.maintainers["ops"].id
  repository = "actions"
  permission = "maintain"
}

data "github_organization" "homebrew" {
  name = "Homebrew"
}

locals {
  member_emails = tomap({ for key, value in data.github_organization.homebrew.users : value.login => sensitive(value.email) })
}

output "member_emails" {
  value = local.member_emails
}

output "ops" {
  value = { for username in var.teams.maintainers.ops : username => local.member_emails[username] if lookup(local.member_emails, username, null) != null }
}

output "tsc" {
  value = { for username in var.teams.maintainers.tsc : username => local.member_emails[username] if lookup(local.member_emails, username, null) != null }
}

output "plc" {
  value = { for username in var.teams.plc : username => local.member_emails[username] if lookup(local.member_emails, username, null) != null }
}
