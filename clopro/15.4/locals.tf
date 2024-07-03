locals {
  ssh-key = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  musql_used_zones = [
    for j in var.selected_zones : j.name if j.used
  ]
k8s_used_zones = [
    for j in var.k8s-subnets.selected-zones : j.name if j.used
  ]
}


