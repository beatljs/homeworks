resource "yandex_vpc_network" "kuber-net" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "kuber-subnet" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.kuber-net.id
  v4_cidr_blocks = var.default_cidr
}

resource "yandex_vpc_address" "addr" {
  name = "<BeatlClusterIP>"
  deletion_protection = true
  external_ipv4_address {
    zone_id = var.default_zone
  }
}

data "yandex_compute_image" "ubuntu-2004-lts" {
  family = "ubuntu-2004-lts"
}
