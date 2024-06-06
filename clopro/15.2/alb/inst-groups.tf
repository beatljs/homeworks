resource "yandex_compute_instance_group" "beatl-ig" {
  name                = "beatl-fixed-ig"
  folder_id           = var.folder_id
  service_account_id  = "${yandex_iam_service_account.beatl-ig-sa.id}"
  deletion_protection = false
  depends_on          = [yandex_resourcemanager_folder_iam_member.editor]
  instance_template {
    platform_id = var.vms_resources.platform_id
    resources {
      memory = var.vms_resources.mem
      cores  = var.vms_resources.cores
      core_fraction = var.vms_resources.core_fraction
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = var.vms_resources.image_id
        type     = "network-hdd"
        size     = var.vms_resources.disk_size
      }
    }

    scheduling_policy { preemptible = true }

    network_interface {
      network_id         = "${yandex_vpc_network.beatl-net.id}"
      subnet_ids         = ["${yandex_vpc_subnet.beatl-subnet["${var.vms_resources.subnet}"].id}"]
      nat = var.vms_resources.nat
      security_group_ids = ["${yandex_vpc_security_group.beatl-web-sg.id}"]
    }

    metadata = {
      ssh-keys  = local.ssh-key
      user-data = "${file("cloudinit.yaml")}"
    }
  }

  scale_policy {
    fixed_scale {
      size = var.vms_resources.group_size
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

}


