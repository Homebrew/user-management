variable "teams" {
  type = object({
    plc      = list(string)
    security = list(string)
    ops      = list(string)
    bots     = list(string)
    maintainers = object({
      brew = list(string)
      cask  = list(string)
      core  = list(string)
      tsc   = list(string)
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