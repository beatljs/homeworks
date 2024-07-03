resource "yandex_vpc_subnet" "k8s-subnet" {
  count = length(local.k8s_used_zones)
  name           = "pub-subnet-${count.index}"
  zone           = local.k8s_used_zones[count.index]
  network_id     = yandex_vpc_network.beatl-net.id
  v4_cidr_blocks = ["${var.k8s-subnets.subnet-data.cidr_prefix}${count.index}.0${var.k8s-subnets.subnet-data.cidr_suffix}"]
 }

resource "yandex_kubernetes_cluster" "k8s-regional" {
  name = "k8s-regional"
  network_id = yandex_vpc_network.beatl-net.id
  cluster_ipv4_range = "10.10.0.0/16"
  service_ipv4_range = "10.20.0.0/16"
  master {
    dynamic "master_location" {
      for_each = yandex_vpc_subnet.k8s-subnet
      content {
        zone      = master_location.value.zone
        subnet_id = master_location.value.id
      }
    }
    public_ip = true
    security_group_ids = [
      yandex_vpc_security_group.regional-k8s-sg.id,
      yandex_vpc_security_group.k8s-master-whitelist.id
    ]
  }
  service_account_id      = yandex_iam_service_account.beatl-regional-sa.id
  node_service_account_id = yandex_iam_service_account.beatl-regional-sa.id
  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_member.vpc-public-admin,
    yandex_resourcemanager_folder_iam_member.images-puller,
    yandex_resourcemanager_folder_iam_member.encrypterDecrypter
  ]
  kms_provider {
    key_id = yandex_kms_symmetric_key.k8s-kms-key.id
  }
}

resource "yandex_kubernetes_node_group" "k8s-beatl-ng" {
  name        = "k8s-beatl-ng"
  description = "Test node group"
  cluster_id  = yandex_kubernetes_cluster.k8s-regional.id
  version     = "1.27"
  instance_template {
    name = "test-{instance.short_id}-{instance_group.id}"
    platform_id = "standard-v3"
    resources {
      cores         = 2
      core_fraction = 50
      memory        = 2
    }
    boot_disk {
      size = 64
      type = "network-ssd"
    }
    network_acceleration_type = "standard"
    network_interface {
      security_group_ids = [
        yandex_vpc_security_group.regional-k8s-sg.id,
        yandex_vpc_security_group.k8s-nodes-ssh-access.id,
        yandex_vpc_security_group.k8s-public-services.id
      ]
      subnet_ids         = [ yandex_vpc_subnet.k8s-subnet[0].id ]
      nat                = true
    }
    metadata = {
      ssh-keys = local.ssh-key
    }
    scheduling_policy {
      preemptible = true
    }
  }
  scale_policy {
    auto_scale {
      min     = 3
      max     = 6
      initial = 3
    }
  }

  deploy_policy {
    max_expansion   = 3
    max_unavailable = 1
  }
  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true
    maintenance_window {
      start_time = "22:00"
      duration   = "10h"
    }
  }
  allocation_policy {
    location {
        zone = yandex_vpc_subnet.k8s-subnet[0].zone
      }
  }
  node_labels = {
    node-label1 = "node-value1"
  }

//  node_taints = ["taint1=taint-value1:NoSchedule"]

  labels = {
    "template-label1" = "template-value1"
  }
  allowed_unsafe_sysctls = ["kernel.msg*", "net.core.somaxconn"]
}

