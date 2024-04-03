###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
  sensitive = true
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
  sensitive = true
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
  sensitive = true
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "kuber-vpc"
  description = "VPC network&subnet name"
}

variable "vms_metadata" {
  default = {
    serial-port-enable = 1
    ssh-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFzIYA9F1G3dSQ6Ngnk+XSFESJgTn1Rx4ghJ0wv6WSvN beatl@OWEN"
  }
  sensitive = true
}

variable "vms_resources" {
   default = {
      control_plane = {
        name = "beatl-control-plane"
        cores = 4
        mem = 8
        core_fraction=20
        disk_size = 50
      }
      worker_node = {
        name = "beatl-worker-node"
        cores = 2
        mem = 2
        core_fraction=5
        disk_size = 100
      }
   }
  nullable = false
}

variable "enable_ha" {
  type = bool
  default = true
  description = "If true keepalived HA cluster will be created"
  nullable = false
}

variable "worker-node-count" {
  type = number
  default = 4
  description = "The number of worker nodes in the cluster"
  nullable = false
}

/* variable "control-plane-count" {
  type = number
  default = (var.enable_ha == true ? 3 : 1)
  description = "The number of control planes in the cluster"
} */

