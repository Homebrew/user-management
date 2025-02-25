variable "teams" {
  type = object({
    plc      = list(string)
    security = list(string)
    bots     = list(string)
    ops      = list(string)
    maintainers = object({
      brew = list(string)
      cask  = list(string)
      core  = list(string)
      tsc   = list(string)
    })
  })
}

variable "unmanagable_members" {
  type = list(string)
}

variable "admins" {
  type = list(string)
}