output "Balancer_public_IP" {
  value = yandex_lb_network_load_balancer.beatl-lb.listener
}
/*
output "Private_VM_IP" {
  value = yandex_compute_instance.beatl_vm["private-node"].network_interface.0.ip_address
}
*/