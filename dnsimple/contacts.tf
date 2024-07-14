resource "dnsimple_contact" "ocf" {
  label      = "Open Collective Foundation"
  first_name = "Homebrew"
  last_name  = "Maintainers"
  email      = "ops@brew.sh"

  phone          = "+1 555 1234"
  address1       = "123 Homebrew Street"
  city           = "Homebrew"
  state_province = "HB"
  postal_code    = "00001"
  country        = "United States"

  lifecycle {
    ignore_changes = [address1, city, state_province, postal_code, phone]
  }

}
