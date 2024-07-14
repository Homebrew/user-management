locals {
  teams = concat(
    [for team in keys(var.teams) : team if !contains(["bots", "taps"], team)],
    keys(tomap(var.teams.maintainers)),
    keys(tomap(var.teams.taps))
  )
}

resource "github_team" "main" {
  name    = each.key
  privacy = "closed"

  for_each = { for team in keys(var.teams) : team => team if !contains(["bots", "taps"], team) }

  lifecycle {
    ignore_changes = [description]
  }
}

resource "github_team" "maintainers" {
  name           = replace(each.key, "_", ".")
  privacy        = "closed"
  parent_team_id = github_team.main["maintainers"].id

  for_each = { for team in keys(var.teams.maintainers) : team => team }

  lifecycle {
    ignore_changes = [description]
  }
}

resource "github_team" "taps" {
  name    = replace(each.key, "_", ".")
  privacy = "closed"

  for_each = { for team in keys(var.teams.taps) : team => team }

  lifecycle {
    ignore_changes = [description]
  }
}

resource "github_team_membership" "ops_membership" {
  for_each = toset(var.teams.maintainers.ops)
  team_id  = github_team.maintainers["ops"].id
  username = each.key
  role     = contains(var.admins, each.key) ? "maintainer" : "member"
}

resource "github_team_membership" "plc_membership" {
  for_each = toset(var.teams.plc)
  team_id  = github_team.main["plc"].id
  username = each.key
  role     = contains(var.admins, each.key) ? "maintainer" : "member"
}

resource "github_team_membership" "tsc_membership" {
  for_each = toset(var.teams.maintainers.tsc)
  team_id  = github_team.maintainers["tsc"].id
  username = each.key
  role     = contains(var.admins, each.key) ? "maintainer" : "member"
}