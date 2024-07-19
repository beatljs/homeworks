resource "yandex_vpc_network" "beatl-net" {
  name = var.vpc_name
}

resource "yandex_dns_zone" "beatl-dns-zone" {
  name        = "beatl-dns-zone"
  description = "Test DNS zone"

  labels = {
    label1 = "label-1-value"
  }

  zone             = "beatljs.ru."
  public           = true

  deletion_protection = false
}


resource "yandex_dns_recordset" "k8s-ingress" {
  depends_on = [null_resource.deoloy-phpa-and-service]
  zone_id = yandex_dns_zone.beatl-dns-zone.id
  name    = "k8s.beatljs.ru."
  type    = "A"
  ttl     = 600
  data = ["${file(var.nlbaddr-filename)}"]

}

