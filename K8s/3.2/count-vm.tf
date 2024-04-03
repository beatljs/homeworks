resource "yandex_compute_instance" "control_plane_vm" {
  name        = "${var.vms_resources.control_plane.name}-${count.index+1}"
  hostname    = "${var.vms_resources.control_plane.name}-${count.index+1}"
  platform_id = "standard-v1"
  
  # count = var.control-plane-count
  count = (var.enable_ha == false ? 1 : 3)

  resources {
    cores  = var.vms_resources.control_plane.cores
    memory = var.vms_resources.control_plane.mem
    core_fraction = var.vms_resources.control_plane.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2004-lts.image_id
      type = "network-hdd"
      size = var.vms_resources.control_plane.disk_size
    }   
  }

  metadata = {
    ssh-keys = local.ssh-key
  }

  scheduling_policy { preemptible = true }

  network_interface { 
    subnet_id = yandex_vpc_subnet.kuber-subnet.id
    nat       = true
  }
  allow_stopping_for_update = true
}

resource "yandex_compute_instance" "worker_node_vm" {
  name        = "${var.vms_resources.worker_node.name}-${count.index+1}"
  hostname    = "${var.vms_resources.worker_node.name}-${count.index+1}"
  platform_id = "standard-v1"

  count = var.worker-node-count

  resources {
    cores  = var.vms_resources.worker_node.cores
    memory = var.vms_resources.worker_node.mem
    core_fraction = var.vms_resources.worker_node.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2004-lts.image_id
      type = "network-hdd"
      size = var.vms_resources.worker_node.disk_size
    }
  }

  metadata = {
    ssh-keys = local.ssh-key
  }

  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id = yandex_vpc_subnet.kuber-subnet.id
    nat       = true
  }
  allow_stopping_for_update = true
}
