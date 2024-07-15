# homebrew-user-management

User management for the Homebrew organisation using OpenTofu

## Requirements

- This project uses OpenTofu, not Terraform

## Usage

- Set `GITHUB_TOKEN` to a token with sufficient permissions before usage.
- Use `aws configure sso` to log into the Homebrew AWS org.
- Set `AWS_PROFILE` to the resulting profile.
- `tofu init`
- `tofu plan -var-file .tfvars`

### Secrets

CI requires the following secrets:

- `amazon_role`: The ARN of the AWS role to use for OIDC auth.
- `email_overrides`: Map of GitHub usernames with emails for people who want a different email for tools from their GH email
- `TF_GH_TOKEN`: GitHub token with permissions to manage org teams, users and repo permissions
- `TF_DNSIMPLE_ACCOUNT`: Account ID for DNSimple
- `TF_DNSIMPLE_TOKEN`: Token to authenticate to DNSimple

## TODO

- Google workspace management for brew.sh
- Google Cloud manangement for self-hosted workers
- Add DNSSimple
