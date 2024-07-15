resource "dnsimple_contact" "ocf" {
  label      = "Open Collective Foundation"
  first_name = "Homebrew"
  last_name  = "Maintainers"
  email      = "ops@brew.sh"

  phone            = sensitive("+1 555 1234")
  address1         = sensitive("123 Homebrew Street")
  city             = sensitive("Homebrew")
  state_province   = sensitive("HB")
  postal_code      = sensitive("00001")
  country          = "US"

  lifecycle {
    ignore_changes = [address1, city, state_province, postal_code, phone]
  }

}
