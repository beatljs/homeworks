output "k8s_used_zones" {
  value = local.k8s_used_zones
}

output "ttt" {
  value = join(", ", flatten(yandex_vpc_subnet.k8s-subnet[*].v4_cidr_blocks))
}

output "mysqlhost" {
  value = yandex_mdb_mysql_cluster.mysql-cluster.host
}