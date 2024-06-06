resource "yandex_alb_target_group" "beatl-alb-tg" {
  name = "my-target-group"

  target {
    subnet_id  = "${yandex_vpc_subnet.beatl-subnet["${var.vms_resources.subnet}"].id}"
    ip_address = yandex_compute_instance_group.beatl-ig.instances.0.network_interface.0.ip_address
  }
  target {
    subnet_id  = "${yandex_vpc_subnet.beatl-subnet["${var.vms_resources.subnet}"].id}"
    ip_address = yandex_compute_instance_group.beatl-ig.instances.1.network_interface.0.ip_address
  }
  target {
    subnet_id  = "${yandex_vpc_subnet.beatl-subnet["${var.vms_resources.subnet}"].id}"
    ip_address = yandex_compute_instance_group.beatl-ig.instances.2.network_interface.0.ip_address
  }
}

resource "yandex_alb_backend_group" "beatl-backend-group" {
  name      = "my-backend-group"

  http_backend {
    name = "beatl-http-backend"
    weight = 1
    port = 80
    target_group_ids = ["${yandex_alb_target_group.beatl-alb-tg.id}"]

    load_balancing_config {
      panic_threshold = 50
    }
    healthcheck {
      timeout = "30s"
      interval = "5s"
      http_healthcheck {
        path  = "/"
      }
    }
    http2 = "true"
  }
}

resource "yandex_alb_virtual_host" "beatl-virtual-host" {
  name      = "my-virtual-host"
  http_router_id = yandex_alb_http_router.beatl-router.id
  route {
    name = "my-route"
    http_route {
      http_match {
        path {
          exact = "/"
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.beatl-backend-group.id
        timeout = "10s"
        prefix_rewrite = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "beatl-router" {
  name      = "my-http-router"
  labels = {
    tf-label    = "tf-label-value"
    empty-label = "s"
  }
}

resource "yandex_alb_load_balancer" "beatl-alb-balancer" {
  name        = "my-load-balancer"

  network_id  = yandex_vpc_network.beatl-net.id
  security_group_ids = [ "${yandex_vpc_security_group.beatl-web-sg.id}" ]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = "${yandex_vpc_subnet.beatl-subnet["${var.vms_resources.subnet}"].id}"
    }
  }

  listener {
    name = "my-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.beatl-router.id
      }
    }
  }

  log_options {
    discard_rule {
      http_code_intervals = ["HTTP_2XX"]
      discard_percent = 75
    }
  }
}