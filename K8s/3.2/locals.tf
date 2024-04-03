locals {
  ssh-key = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  
#  for_hosts = {
#      control-planes = yandex_compute_instance.control-plane_vm
#      worker-nodes = yandex_compute_instance.worker-node_vm
#   }
}
