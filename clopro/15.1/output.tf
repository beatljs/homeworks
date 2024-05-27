output "NAT_public_IP" {
  value = yandex_compute_instance.beatl_vm["beatl-nat-instance"].network_interface.0.nat_ip_address
}

output "Private_VM_IP" {
  value = yandex_compute_instance.beatl_vm["private-node"].network_interface.0.ip_address
}