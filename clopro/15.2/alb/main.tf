resource "yandex_vpc_network" "beatl-net" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "beatl-subnet" {
  for_each       = var.subnet-props
  name           = each.value.name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.beatl-net.id
  v4_cidr_blocks = each.value.cidr
 }


