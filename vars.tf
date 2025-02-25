variable "teams" {
  type = object({
    plc      = list(string)
    security = list(string)
    bots     = list(string)
    maintainers = object({
      cask             = list(string)
      brew             = list(string)
      core             = list(string)
      tsc              = list(string)
      ops              = list(string)
      formulae_brew_sh = list(string)
      ci-orchestrator  = list(string)
      analytics        = list(string)
    })
    taps = object({
      bundle               = list(string)
      brew-pip-audit       = list(string)
      homebrew-linux-fonts = list(string)
      services             = list(string)
    })
  })
}

variable "github_admins" {
  type = list(string)
}

variable "email_overrides" {
  type      = map(string)
  sensitive = true
  default   = {}
}