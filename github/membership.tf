locals {
  members = concat(
    var.teams.bots,
    var.teams.plc,
    var.teams.security,
    var.teams.security,
    flatten(values(tomap(var.teams.maintainers))),
    flatten(values(tomap(var.teams.taps)))
  )
}

resource "github_membership" "general" {
  for_each = toset([for member in local.members : member if !contains(var.unmanagable_members, member)])
  username = each.key
  role     = contains(var.admins, each.key) ? "admin" : "member"
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