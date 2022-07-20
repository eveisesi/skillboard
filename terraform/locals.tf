locals {
  dmz_subnet_tags = {
    dmz = true
    app = false
    db  = false
  }

  app_subnet_tags = {
    dmz = false
    app = true
    db  = false
  }

  db_subnet_tags = {
    dmz = false
    app = false
    db  = true
  }

  vpc_cidr = "10.0.0.0/22"
}
