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

variable "vpc_name" {
  type        = string
  default     = "beatl-vpc"
  description = "VPC network name"
}

variable "mysql_selected_zones" {
  type = list(map(any))
  default  =   [
      {
        name = "ru-central1-a"
        used = true
      },
      {
        name = "ru-central1-b"
        used = true
      },
      {
        name = "ru-central1-c"
        used = false
      },
      {
        name = "ru-central1-d"
        used = false
      }
    ]
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "subnet-props" {
  default = {
    private = {
      cidr_prefix = "192.168.1"
      cidr_suffix = "/24"
      route_table = false
    }
  }
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "k8s-subnets" {
  default = {
    name = "public"
    selected-zones = [
      {
        name = "ru-central1-a"
        used = true
      },
      {
        name = "ru-central1-b"
        used = true
      },
      {
        name = "ru-central1-c"
        used = false
      },
      {
        name = "ru-central1-d"
        used = true
      }
    ]
    subnet-data = {
      cidr_prefix = "192.168.2"
      cidr_suffix = "/24"
      route_table = false
    }
  }
}

variable "mysql-db-user" {
  type = string
  sensitive = true
}

variable "mysql-db-password" {
  type = string
  sensitive = true
}

variable "pods_cidr" {
  type = string
  default = "10.144.0.0/16"
}

variable "services_cidr" {
  type = string
  default = "10.145.0.0/16"
}

variable "ca_cert" {
  type = string
  sensitive = true
}

variable "nlbaddr-filename" {
  type = string
  default = "nlb-addr.dat"
}

variable "vms_resources" {
   default = {
        group_size = 3
        platform_id = "standard-v3"
        image_id = "fd827b91d99psvq5fjit"
        name = "public-node"
        cores = 2
        mem = 2
        core_fraction = 20
        disk_size = 50
        subnet = "public"
        nat = false
   }
  nullable = false
}


