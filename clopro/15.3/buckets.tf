resource "yandex_storage_bucket" "beatl-bucket" {
  depends_on          = [ yandex_kms_symmetric_key.beatl-key ]
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "beatl-bucket"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.beatl-key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  anonymous_access_flags {
    read = true
    list = true
  }
  https {
    certificate_id = var.https-cert-id
  }

  force_destroy = true
}

resource "yandex_storage_object" "beatl-buck-img" {
  depends_on          = [ yandex_storage_bucket.beatl-bucket ]
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = "beatl-bucket"
  key    = "image-1"
  source = "./images/7afbf86ade2cbd9fa149ef54efd4d954.jpg"
}

resource "yandex_storage_object" "beatl-buck-index" {
  depends_on          = [ yandex_storage_bucket.beatl-bucket ]
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = "beatl-bucket"
  key    = "index.html"
  source = "./files/index.html"
}

resource "yandex_storage_object" "beatl-buck-err" {
  depends_on          = [ yandex_storage_bucket.beatl-bucket ]
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = "beatl-bucket"
  key    = "error.html"
  source = "./files/error.html"
}

