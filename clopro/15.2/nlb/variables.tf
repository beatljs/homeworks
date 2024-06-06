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
  }
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
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


