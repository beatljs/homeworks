resource "yandex_vpc_subnet" "private-subnet" {
  count = length(local.musql_used_zones)
  name           = "priv-subnet-${count.index}"
  zone           = local.musql_used_zones[count.index]
  network_id     = yandex_vpc_network.beatl-net.id
  v4_cidr_blocks = ["${var.subnet-props.private.cidr_prefix}${count.index}.0${var.subnet-props.private.cidr_suffix}"]
 }

resource "yandex_mdb_mysql_cluster" "mysql-cluster" {
  name        = "beatl-mysql-cluster"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.beatl-net.id
  version     = "8.0"

  resources {
    resource_preset_id = "b1.medium"
    disk_type_id       = "network-ssd"
    disk_size          = 20
  }

  maintenance_window {
    type = "ANYTIME"
  }

  backup_window_start {
    hours   = 23
    minutes = 59
  }

  dynamic "host" {
    for_each = yandex_vpc_subnet.private-subnet
    content {
      zone      = host.value.zone
      subnet_id = host.value.id
    }
  }
  deletion_protection = false
}

resource "yandex_mdb_mysql_database" "netology_db" {
  cluster_id = yandex_mdb_mysql_cluster.mysql-cluster.id
  name       = "netology_db"
}

resource "yandex_mdb_mysql_user" "db_users" {
  cluster_id = yandex_mdb_mysql_cluster.mysql-cluster.id
  name       = var.mysql-db-user
  password   = var.mysql-db-password
  permission {
    database_name = yandex_mdb_mysql_database.netology_db.name
    roles = ["ALL"]
  }
  global_permissions = ["PROCESS"]

  authentication_plugin = "MYSQL_NATIVE_PASSWORD"

}