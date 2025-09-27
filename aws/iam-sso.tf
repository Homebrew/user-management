data "aws_ssoadmin_instances" "main" {}

resource "aws_identitystore_group" "group" {
  for_each          = var.teams
  display_name      = each.key
  identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]
}

resource "aws_identitystore_user" "main" {
  for_each          = merge(nonsensitive(var.teams.PLC), nonsensitive(var.teams.Ops), nonsensitive(var.teams.Security))
  identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]

  display_name = each.key
  user_name    = each.key
  nickname     = each.key

  name {
    given_name  = each.key
    family_name = "Brew"
  }

  emails {
    value = sensitive(each.value)
  }

  lifecycle {
    ignore_changes = [name, display_name]
  }
}

resource "aws_identitystore_group_membership" "plc" {
  for_each = nonsensitive(var.teams.PLC)

  identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]
  group_id          = aws_identitystore_group.group["PLC"].group_id
  member_id         = aws_identitystore_user.main[each.key].user_id
}

resource "aws_identitystore_group_membership" "ops" {
  for_each = nonsensitive(var.teams.Ops)

  identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]
  group_id          = aws_identitystore_group.group["Ops"].group_id
  member_id         = aws_identitystore_user.main[each.key].user_id
}

resource "aws_identitystore_group_membership" "security" {
  for_each = nonsensitive(var.teams.Security)

  identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]
  group_id          = aws_identitystore_group.group["Security"].group_id
  member_id         = aws_identitystore_user.main[each.key].user_id
}

resource "aws_ssoadmin_permission_set" "OpsAccess" {
  name         = "OpsAccess"
  description  = "Access for Ops"
  instance_arn = tolist(data.aws_ssoadmin_instances.main.arns)[0]
}
resource "aws_ssoadmin_managed_policy_attachment" "OpsAccess" {
  depends_on = [aws_ssoadmin_account_assignment.Ops]

  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.OpsAccess.arn
}

resource "aws_ssoadmin_permission_set" "SecurityTeam" {
  name         = "SecurityTeam"
  description  = "Access for the security team"
  instance_arn = tolist(data.aws_ssoadmin_instances.main.arns)[0]
}
resource "aws_ssoadmin_managed_policy_attachment" "SecurityTeam" {
  depends_on = [aws_ssoadmin_account_assignment.security]

  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.SecurityTeam.arn
}

resource "aws_ssoadmin_permission_set" "Billing" {
  name         = "Billing"
  description  = "Access for the PLC"
  instance_arn = tolist(data.aws_ssoadmin_instances.main.arns)[0]
}
resource "aws_ssoadmin_managed_policy_attachment" "Billing" {
  depends_on = [aws_ssoadmin_account_assignment.billing]

  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
  permission_set_arn = aws_ssoadmin_permission_set.Billing.arn
}

resource "aws_ssoadmin_account_assignment" "billing" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.Billing.arn

  principal_id   = aws_identitystore_group.group["PLC"].group_id
  principal_type = "GROUP"

  target_id   = local.account_id
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "security" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.SecurityTeam.arn

  principal_id   = aws_identitystore_group.group["Security"].group_id
  principal_type = "GROUP"

  target_id   = local.account_id
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "Ops" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.OpsAccess.arn

  principal_id   = aws_identitystore_group.group["Ops"].group_id
  principal_type = "GROUP"

  target_id   = local.account_id
  target_type = "AWS_ACCOUNT"
}