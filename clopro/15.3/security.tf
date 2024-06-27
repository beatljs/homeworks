
resource "yandex_kms_symmetric_key" "beatl-key" {
  name              = "lesson-15-3-key"
  description       = "netology learning"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" // equal to 1 year
}

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

