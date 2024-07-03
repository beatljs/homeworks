resource "yandex_vpc_network" "beatl-net" {
  name = var.vpc_name
}

resource "yandex_dns_zone" "beatl-dns-zone" {
  name        = "beatl-dns-zone"
  description = "desc"

  labels = {
    label1 = "label-1-value"
  }

  zone             = "beatljs.ru."
  public           = true
//  private_networks = [yandex_vpc_network.foo.id]

  deletion_protection = false
}

/*
resource "yandex_dns_recordset" "k8s-ingress" {
  zone_id = yandex_dns_zone.beatl-dns-zone.id
  name    = "k8s.beatljs.ru."
  type    = "A"
  ttl     = 400
  data = [158.160.158.49]

}

 */