resource "yandex_vpc_network" "beatl-net" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "beatl-subnet" {
  for_each       = var.subnet-props
  name           = each.value.name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.beatl-net.id
  v4_cidr_blocks = each.value.cidr
  route_table_id = each.value.route_table ? yandex_vpc_route_table.nat-instance-route.id : null
}

# Создание таблицы маршрутизации и статического маршрута

resource "yandex_vpc_route_table" "nat-instance-route" {
  name       = "nat-instance-route"
  network_id = yandex_vpc_network.beatl-net.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = var.vms_resources["beatl-nat-instance"].ip_addr
  }
}

