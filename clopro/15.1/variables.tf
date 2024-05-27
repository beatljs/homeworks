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

variable "vpc_name" {
  type        = string
  default     = "beatl-vpc"
  description = "VPC network name"
}

variable "subnet-props" {
  default = {
    public = {
      name = "public"
      cidr = ["192.168.10.0/24"]
      route_table = false
    }
    private = {
      name = "private"
      cidr = ["192.168.20.0/24"]
      route_table = true
    }
  }
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vms_resources" {
   default = {
      beatl-nat-instance = {
        image_id = "fd80mrhj8fl2oe87o4e1"
        name = "beatl-nat-instance"
        cores = 2
        mem = 2
        core_fraction = 20
        disk_size = 50
        nat = true
        subnet = "public"
        ip_addr = "192.168.10.254"
      }
      private-node = {
        image_id = "fd8ris7enkv1ft2gp7fg"
        name = "private-node"
        cores = 2
        mem = 2
        core_fraction = 20
        disk_size = 50
        nat = false
        subnet = "private"
        ip_addr = ""
      }
   }
  nullable = false
}


