locals {
  teams = concat(
    [for team in keys(var.teams) : team if !contains(["bots", "plc"], team)],
    keys(tomap(var.teams.maintainers))
  )
}

resource "github_team" "main" {
  name    = each.key
  privacy = "closed"

  for_each = { for team in keys(var.teams) : team => team if !contains(["bots", "ops", "plc", "security"], team) }

  lifecycle {
    ignore_changes = [description]
  }
}

resource "github_team" "maintainers" {
  name           = replace(each.key, "_", ".")
  privacy        = "closed"
  parent_team_id = github_team.main["maintainers"].id

  for_each = { for team in keys(var.teams.maintainers) : team => team if !contains(["other"], team) }

  lifecycle {
    ignore_changes = [description]
  }
}

resource "github_team_membership" "maintainer_membership" {
  for_each = toset(var.teams.maintainers.other)
  team_id  = github_team.main["maintainers"].id
  username = each.key
  role     = contains(var.admins, each.key) ? "maintainer" : "member"
}

resource "github_team_membership" "tsc_membership" {
  for_each = toset(var.teams.maintainers.tsc)
  team_id  = github_team.maintainers["tsc"].id
  username = each.key
  role     = contains(var.admins, each.key) ? "maintainer" : "member"
}