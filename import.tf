# import {
  # for_each = toset(var.teams.plc)
  # to       = module.github.github_team_membership.plc_membership[each.key]
  # id       = "3120238:${each.key}"
# }

import {
  for_each = toset(var.teams.maintainers.tsc)
  to       = module.github.github_team_membership.tsc_membership[each.key]
  id       = "3120240:${each.key}"
}

import {
  for_each = toset(var.teams.maintainers.ops)
  to       = module.github.github_team_membership.ops_membership[each.key]
  id       = "3769017:${each.key}"
}

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

import {
  for_each = toset([for member in local.members : member if !contains(local.unmanagable_members, member)])
  to       = module.github.github_membership.general[each.key]
  id       = "Homebrew:${each.key}"
}

import {
  for_each = { for team in keys(var.teams) : team => team if !contains(["bots", "taps", "plc"], team) }
  to       = module.github.github_team.main[each.key]
  id       = each.key
}

import {
  for_each = { for team in keys(var.teams.taps) : team => team }
  to       = module.github.github_team.taps[each.key]
  id       = replace(each.key, "_", "-")
}

import {
  for_each = { for team in keys(var.teams.maintainers) : team => team }
  to       = module.github.github_team.maintainers[each.key]
  id       = replace(each.key, "_", "-")
}

import {
  to = module.dnsimple.dnsimple_contact.ocf
  id = 52414
}

import {
  to = module.aws.aws_iam_openid_connect_provider.github_actions
  id = "arn:aws:iam::765021812025:oidc-provider/token.actions.githubusercontent.com"
}

import {
  to = module.aws.aws_iam_role.github_tf
  id = "GitHubActionsS3Role"
}