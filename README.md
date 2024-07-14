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

## TODO

- Google workspace management for brew.sh
- Google Cloud manangement for self-hosted workers
- Add DNSSimple
