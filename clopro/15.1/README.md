
---
<img src="../Netology.png" height="24px"/>

### Учебная группа DevOps-32

---

## Решение по домашнему заданию к занятию 15.1 «Организация сети»

Домашнее задание выполнялось в облаке Yandex Cloud

### Содержание

- [Общее описание](#description) 
- [Описание конфигурационных переменных](#variablesd)
- [Результат выполнения задания 1: Yandex cloud](#task1)
- [Исполнитель](#student)


---

###### #description
### Общее описание

Для выполнения домашнего задания создан сценарий terraform.

Сценарий Terraform создает в облаке ресурсы в соответствии с домашним заданием.

Конфигурирование ресурсов осуществляется через определение переменных.

[Репозиторий со сценарием `terraform`](./)

---

###### #variablesd
### Описание конфигурационных переменных

Перед запуском сценария нужно откорректировать значения переменных в файле [variables.tf](./variables.tf) 

##### Конфигурируемые переменные

| Name | Description                                                                                                                       | Type | Default | Required |
|------|-----------------------------------------------------------------------------------------------------------------------------------|------|---------|:--------:|
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | VPC network name                                                                                                                  | `string` | `"beatl-vpc"` |   yes    |
| <a name="input_subnet-props"></a> [subnet-props](#input\_subnet-props) | Параметры создаваемых подсетей. <br> <br> Для каждой подсети задается имя, cidr <br> и требуется ли привязывать к ней route_table | `map` | <pre>{<br>  "private": {<br>    "cidr": [<br>      "192.168.20.0/24"<br>    ],<br>    "name": "private",<br>    "route_table": true<br>  },<br>  "public": {<br>    "cidr": [<br>      "192.168.10.0/24"<br>    ],<br>    "name": "public",<br>    "route_table": false<br>  }<br>}</pre> |   yes    |
| <a name="input_vms_resources"></a> [vms\_resources](#input\_vms\_resources) | Параметры создаваемых виртуальных машин.                                                                                          | `map` | <pre>{<br>  "beatl-nat-instance": {<br>    "core_fraction": 20,<br>    "cores": 2,<br>    "disk_size": 50,<br>    "image_id": "fd80mrhj8fl2oe87o4e1",<br>    "ip_addr": "192.168.10.254",<br>    "mem": 2,<br>    "name": "beatl-nat-instance",<br>    "nat": true,<br>    "subnet": "public"<br>  },<br>  "private-node": {<br>    "core_fraction": 20,<br>    "cores": 2,<br>    "disk_size": 50,<br>    "image_id": "fd8ris7enkv1ft2gp7fg",<br>    "ip_addr": "",<br>    "mem": 2,<br>    "name": "private-node",<br>    "nat": false,<br>    "subnet": "private"<br>  }<br>}</pre> |   yes    |

---

###### #task1
### Результат выполнения задания 1: Yandex Cloud

<details>
    <summary> Вывод terraform-apply...  </summary>

```
beatl@Sirius:~/homeworks/clopro/15.1$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.beatl_vm["beatl-nat-instance"] will be created
  + resource "yandex_compute_instance" "beatl_vm" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "beatl-nat-instance"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-ed25519 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            EOT
        }
      + name                      = "beatl-nat-instance"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd80mrhj8fl2oe87o4e1"
              + name        = (known after apply)
              + size        = 50
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = "192.168.10.254"
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + resources {
          + core_fraction = 20
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_compute_instance.beatl_vm["private-node"] will be created
  + resource "yandex_compute_instance" "beatl_vm" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "private-node"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-ed25519 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            EOT
        }
      + name                      = "private-node"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8ris7enkv1ft2gp7fg"
              + name        = (known after apply)
              + size        = 50
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + resources {
          + core_fraction = 20
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_vpc_network.beatl-net will be created
  + resource "yandex_vpc_network" "beatl-net" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "beatl-vpc"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_route_table.nat-instance-route will be created
  + resource "yandex_vpc_route_table" "nat-instance-route" {
      + created_at = (known after apply)
      + folder_id  = (known after apply)
      + id         = (known after apply)
      + labels     = (known after apply)
      + name       = "nat-instance-route"
      + network_id = (known after apply)

      + static_route {
          + destination_prefix = "0.0.0.0/0"
          + next_hop_address   = "192.168.10.254"
            # (1 unchanged attribute hidden)
        }
    }

  # yandex_vpc_subnet.beatl-subnet["private"] will be created
  + resource "yandex_vpc_subnet" "beatl-subnet" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "private"
      + network_id     = (known after apply)
      + route_table_id = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.20.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

  # yandex_vpc_subnet.beatl-subnet["public"] will be created
  + resource "yandex_vpc_subnet" "beatl-subnet" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "public"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.10.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

Plan: 6 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + NAT_public_IP = (known after apply)
  + Private_VM_IP = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

yandex_vpc_network.beatl-net: Creating...
yandex_vpc_network.beatl-net: Creation complete after 1s [id=enpirq0msb12cbv6aim5]
yandex_vpc_route_table.nat-instance-route: Creating...
yandex_vpc_route_table.nat-instance-route: Creation complete after 1s [id=enpe3vmi7p86eu11ii4m]
yandex_vpc_subnet.beatl-subnet["private"]: Creating...
yandex_vpc_subnet.beatl-subnet["public"]: Creating...
yandex_vpc_subnet.beatl-subnet["private"]: Creation complete after 1s [id=e9b52a6nbqr2p32e3j0a]
yandex_vpc_subnet.beatl-subnet["public"]: Creation complete after 2s [id=e9bqlhp0ag6mgclroo80]
yandex_compute_instance.beatl_vm["beatl-nat-instance"]: Creating...
yandex_compute_instance.beatl_vm["private-node"]: Creating...
yandex_compute_instance.beatl_vm["private-node"]: Still creating... [10s elapsed]
yandex_compute_instance.beatl_vm["beatl-nat-instance"]: Still creating... [10s elapsed]
yandex_compute_instance.beatl_vm["private-node"]: Still creating... [20s elapsed]
yandex_compute_instance.beatl_vm["beatl-nat-instance"]: Still creating... [20s elapsed]
yandex_compute_instance.beatl_vm["private-node"]: Still creating... [30s elapsed]
yandex_compute_instance.beatl_vm["beatl-nat-instance"]: Still creating... [30s elapsed]
yandex_compute_instance.beatl_vm["private-node"]: Creation complete after 31s [id=fhmb76i957ol1efdb15k]
yandex_compute_instance.beatl_vm["beatl-nat-instance"]: Still creating... [40s elapsed]
yandex_compute_instance.beatl_vm["beatl-nat-instance"]: Still creating... [50s elapsed]
yandex_compute_instance.beatl_vm["beatl-nat-instance"]: Still creating... [1m0s elapsed]
yandex_compute_instance.beatl_vm["beatl-nat-instance"]: Creation complete after 1m2s [id=fhml0iu3d17tubfdrbek]

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

NAT_public_IP = "84.201.135.160"
Private_VM_IP = "192.168.20.25"
```

</details>

<details>
    <summary> Вывод консоли при проверке созданных VMs ...  </summary>

```
beatl@Sirius:~/homeworks/clopro/15.1$ yc compute instance list
+----------------------+--------------------+---------------+---------+----------------+----------------+
|          ID          |        NAME        |    ZONE ID    | STATUS  |  EXTERNAL IP   |  INTERNAL IP   |
+----------------------+--------------------+---------------+---------+----------------+----------------+
| fhmb76i957ol1efdb15k | private-node       | ru-central1-a | RUNNING |                | 192.168.20.25  |
| fhml0iu3d17tubfdrbek | beatl-nat-instance | ru-central1-a | RUNNING | 84.201.135.160 | 192.168.10.254 |
+----------------------+--------------------+---------------+---------+----------------+----------------+

There is a new yc version '0.125.0' available. Current version: '0.121.0'.
See release notes at https://cloud.yandex.ru/docs/cli/release-notes
You can install it by running the following command in your shell:
        $ yc components update
```
</details>

<details>
    <summary> Вывод консоли при проверке доступа в Интернет VM из private подсети...  </summary>

```
beatl@Sirius:~/homeworks/clopro/15.1$ ssh -J ubuntu@84.201.135.160 ubuntu@192.168.20.25

The authenticity of host '84.201.135.160 (84.201.135.160)' can't be established.
ED25519 key fingerprint is SHA256:KYzvfCqW7Kj+ZBH/7WF+FCYMCaoKgdrrzrrX61968cQ.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '84.201.135.160' (ED25519) to the list of known hosts.
The authenticity of host '192.168.20.25 (<no hostip for proxy command>)' can't be established.
ED25519 key fingerprint is SHA256:FcNWtvM2oFg0iKBPSQ8HCFFrj0cCHsuvy1GCWXhEziw.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.20.25' (ED25519) to the list of known hosts.
Welcome to Ubuntu 18.04.6 LTS (GNU/Linux 4.15.0-112-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@private-node:~$ ping aliexpress.com

PING aliexpress.com (47.246.173.237) 56(84) bytes of data.
64 bytes from 47.246.173.237 (47.246.173.237): icmp_seq=1 ttl=78 time=291 ms
64 bytes from 47.246.173.237 (47.246.173.237): icmp_seq=2 ttl=78 time=289 ms
64 bytes from 47.246.173.237 (47.246.173.237): icmp_seq=3 ttl=78 time=290 ms
64 bytes from 47.246.173.237 (47.246.173.237): icmp_seq=4 ttl=78 time=291 ms
64 bytes from 47.246.173.237 (47.246.173.237): icmp_seq=5 ttl=78 time=290 ms
^C
--- aliexpress.com ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4005ms
rtt min/avg/max/mdev = 289.892/290.563/291.176/0.692 ms

ubuntu@private-node:~$ nslookup google.com

Server:         127.0.0.53
Address:        127.0.0.53#53

Non-authoritative answer:
Name:   google.com
Address: 209.85.233.113
Name:   google.com
Address: 209.85.233.139
Name:   google.com
Address: 209.85.233.138
Name:   google.com
Address: 209.85.233.100
Name:   google.com
Address: 209.85.233.102
Name:   google.com
Address: 209.85.233.101
Name:   google.com
Address: 2a00:1450:4010:c0e::8a
Name:   google.com
Address: 2a00:1450:4010:c0e::8b
Name:   google.com
Address: 2a00:1450:4010:c0e::71
Name:   google.com
Address: 2a00:1450:4010:c0e::66

ubuntu@private-node:~$ curl -I ozon.ru

HTTP/1.1 301 Moved Permanently
Date: Mon, 27 May 2024 16:17:54 GMT
Content-Type: text/html
Content-Length: 167
Connection: keep-alive
Cache-Control: max-age=3600
Expires: Mon, 27 May 2024 17:17:54 GMT
Location: https://ozon.ru/
Set-Cookie: __cf_bm=OlOEECQnUonozzLXqRQtnV9fLgTykT_2WD.y7Y6iFr4-1716826674-1.0.1.1-dnTMH4TVUG7bASE9iJGHtHg7LYCh4krgfnmcfdXABcWcpjzBa8pkY7hEHgiIZh8EUiCpZWod6MsRGtBVzW14cw; path=/; expires=Mon, 27-May-24 16:47:54 GMT; domain=.ozon.ru; HttpOnly
Server: cloudflare
CF-RAY: 88a75159eed29e27-DME
alt-svc: h3=":443"; ma=86400

ubuntu@private-node:~$ exit
logout
Connection to 192.168.20.25 closed.
```
</details>

---

###### student
### Исполнитель

Сергей Жуков DevOps-32

---