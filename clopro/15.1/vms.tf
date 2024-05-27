
resource "yandex_compute_instance" "beatl_vm" {
  for_each    = var.vms_resources
  name        = each.value.name
  hostname   = each.value.name
  platform_id = "standard-v1"

  resources {
    cores         = each.value.cores
    memory        = each.value.mem
    core_fraction = each.value.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = each.value.image_id
      type     = "network-hdd"
      size     = each.value.disk_size
    }   
  }

  metadata = {
    ssh-keys = local.ssh-key
  }

  scheduling_policy { preemptible = true }

  network_interface { 
    subnet_id  = yandex_vpc_subnet.beatl-subnet["${each.value.subnet}"].id
    ip_address = each.value.ip_addr
    nat        = each.value.nat
  }
  allow_stopping_for_update = true
}

