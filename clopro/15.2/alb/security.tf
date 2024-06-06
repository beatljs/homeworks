resource "yandex_iam_service_account" "beatl-ig-sa" {
  name        = "beatl-ig-sa"
  description = "Сервисный аккаунт для управления группой ВМ."
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id  = var.folder_id
  role       = "editor"
  member     = "serviceAccount:${yandex_iam_service_account.beatl-ig-sa.id}"
  depends_on = [
    yandex_iam_service_account.beatl-ig-sa,
  ]
}

// Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.beatl-ig-sa.id
  description        = "static access key for object storage"
}

resource "yandex_vpc_security_group" "beatl-web-sg" {

  network_id = "${yandex_vpc_network.beatl-net.id}"

  ingress {
    description    = "Allow HTTP protocol"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow HTTPS protocol"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Health checks from NLB"
    protocol = "TCP"
    predefined_target = "loadbalancer_healthchecks" # [198.18.235.0/24, 198.18.248.0/24]
  }

  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

