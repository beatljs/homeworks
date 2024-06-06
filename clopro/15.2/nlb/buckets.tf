resource "yandex_storage_bucket" "beatl-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "beatl-bucket"
  force_destroy = true
}

resource "yandex_storage_object" "beatl-buck-img" {
  depends_on          = [ yandex_storage_bucket.beatl-bucket ]
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = "beatl-bucket"
  key    = "image-1"
  acl    = "public-read"
  source = "../images/7afbf86ade2cbd9fa149ef54efd4d954.jpg" // https://storage.yandexcloud.net/beatl-bucket/image-1
  tags = {
    test = true
  }
}