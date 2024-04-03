
---
<img src="../Netology.png" height="24px"/>

### Учебная группа DevOps-32

---

## Решение по домашнему заданию к занятию «Установка Kubernetes»

Домашнее задание выполнялось в облаке Yandex Cloud

### Содержание

- [Общее описание](#description) 
- [Описание конфигурационных переменных](#variablesd)
- [Результат выполнения задания 1: Установить кластер k8s с 1 master node](#task1)
- [Результат выполнения задания 2*: Установить HA кластер](#task2)
- [Исполнитель](#student)


---

###### #description
### Общее описание

Для выполнения домашних заданий №1 и №2* созданы сценарии terraform и Ansible.

Сценарий Terraform создает в облаке в соответствии с заданием необходимое количество VM для control planes и worker nodes, далее формирует динамический inventory для Ansible и запускает ansible-playbook.

Сценарий Ansible в зависимости от конфигурации производит установку на VM необходимые зависимости и kubeadm. Далее производится установка кластера посредством kubeadm. 

В случае, когда требуется установить кластер в режиме HA на control planes устанавливаются и конфигурируются keepalived и haproxy.

[Репозиторий со сценариями `terraform` и `Ansible` ](./)

---

###### #variablesd
### Описание конфигурационных переменных

Перед установкой кластера нужно откорректировать значения переменных в файле [variables.tf](./variables.tf) 

В зависимости от `enable_ha` - false или true создается соответственно 1 или 3 control plane 

##### Конфигурируемые переменные

| Name | Description                                   | Type | Default | Required |
|------|-----------------------------------------------|------|---------|:--------:|
| <a name="input_enable_ha"></a> [enable\_ha](#input\_enable\_ha) | If true keepalived HA cluster will be created | `bool` | `false` |   yes    |
| <a name="input_worker-node-count"></a> [worker-node-count](#input\_worker-node-count) | The number of worker nodes in the cluster     | `number` | `4` |   yes    |
| <a name="input_vms_resources"></a> [vms\_resources](#input\_vms\_resources) | Name and configuration of VMs to be created   | `map` | <pre>{<br>  "control_plane": {<br>    "core_fraction": 20,<br>    "cores": 4,<br>    "disk_size": 50,<br>    "mem": 8,<br>    "name": "beatl-control-plane"<br>  },<br>  "worker_node": {<br>    "core_fraction": 5,<br>    "cores": 2,<br>    "disk_size": 100,<br>    "mem": 2,<br>    "name": "beatl-worker-node"<br>  }<br>}</pre> |   yes    |

---

###### #task1
### Результат выполнения задания 1: Установить кластер k8s с 1 master node

<details>
    <summary> Вывод terraform-apply...  </summary>

```
beatl@Sirius:~/homeworks/K8s/3.2$ terraform apply
data.yandex_compute_image.ubuntu-2004-lts: Reading...
data.yandex_compute_image.ubuntu-2004-lts: Read complete after 0s [id=fd8dmgc8d3slc0q9pjvv]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # local_file.hosts_cfg will be created
  + resource "local_file" "hosts_cfg" {
      + content              = (known after apply)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "/home/beatl/homeworks/K8s/3.2/hosts.cfg"
      + id                   = (known after apply)
    }

  # null_resource.web_hosts_provision will be created
  + resource "null_resource" "web_hosts_provision" {
      + id       = (known after apply)
      + triggers = {
          + "always_run"        = (known after apply)
          + "playbook_src_hash" = <<-EOT
                ---
                
                - name: kubeinst
                  gather_facts: false
                  hosts: all
                  vars:
                    ansible_user: ubuntu
                  become: yes
                  become_user: root
                  remote_user: ubuntu
                  tasks:
                  - name: Wait for system to become reachable
                    ansible.builtin.wait_for_connection:
                
                  - name: Create directory for ssh-keys
                    file: state=directory mode=0700 dest=/root/.ssh/
                
                  - name: Adding rsa-key in /root/.ssh/authorized_keys
                    copy: src=~/.ssh/id_ed25519.pub dest=/root/.ssh/authorized_keys owner=root mode=0600
                    ignore_errors: yes
                  - name: Installing dependencies
                    ansible.builtin.apt:
                      pkg:
                        - apt-transport-https
                        - ca-certificates
                        - curl
                        - gpg
                        # - containerd
                      state: latest
                      update_cache: yes
                
                  - name: Add kubernetes apt key
                    apt_key:
                      url: https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key
                
                  - name: Create temporary file for worker node join command.
                    ansible.builtin.tempfile:
                      state: file
                    register: cmd_tempfile
                
                  - name: Create directory for GPG key
                    file:
                      path: "/etc/apt/keyrings"
                      state: directory
                      owner: root
                      group: root
                      mode: 0755
                
                  - name: Add kubernetes GPG key.
                    block:
                      - name: Create temporary file for kubernetes-apt-keyring.gpg
                        ansible.builtin.tempfile:
                          state: file
                        register: gpg_tempfile
                
                      - name: Create temporary file for armored Release.key.
                        ansible.builtin.tempfile:
                          state: file
                        register: asc_tempfile
                
                      - name: Download GPG key.
                        ansible.builtin.get_url:
                          url: https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key
                          dest: "{{ asc_tempfile.path }}"
                          force: true
                
                      - name: Dearmor GPG key.
                        ansible.builtin.command:
                          argv:
                            - gpg
                            - --yes
                            - -o
                            - "{{ gpg_tempfile.path }}"
                            - --dearmor
                            - "{{ asc_tempfile.path }}"
                
                      - name: Copy GPG key to /etc/apt/keyrings.
                        become: true
                        ansible.builtin.copy:
                          remote_src: true
                          src: "{{ gpg_tempfile.path }}"
                          dest: "/etc/apt/keyrings/kubernetes-apt-keyring.gpg"
                          owner: root
                          group: root
                          mode: u=rw,g=r,o=r
                    always:
                      - name: Remove temporary file for armored key.
                        ansible.builtin.file:
                          path: "{{ asc_tempfile.path }}"
                          state: absent
                
                      - name: Remove temporary file for GPG key.
                        ansible.builtin.file:
                          path: "{{ gpg_tempfile.path }}"
                          state: absent
                
                  - name: "Add kubernetes DEB repository"
                    apt_repository:
                      repo: deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /
                      filename: kubernetes
                
                  - name: Installing kubeadm
                    ansible.builtin.apt:
                      pkg:
                        - kubelet
                        - kubeadm
                        - kubectl
                        - containerd
                      state: latest
                      update_cache: yes
                
                  - name: Load module br_netfilter
                    modprobe:
                      name: br_netfilter
                
                  - name: Set Sysctl fo enable forwarding
                    sysctl:
                      name: "{{ item.name }}"
                      value: "{{ item.value }}"
                      state: present
                    with_items:
                      - name: net.ipv4.ip_forward
                        value: 1
                      - name: net.bridge.bridge-nf-call-iptables
                        value: 1
                      - name: net.bridge.bridge-nf-call-ip6tables
                        value: 1
                      - name: net.bridge.bridge-nf-call-arptables
                        value: 1
                
                - name: Start control plane
                  gather_facts: false
                  hosts: control_planes
                  vars:
                    ansible_user: ubuntu
                  become: yes
                  become_user: root
                  remote_user: ubuntu
                  tasks:
                  - name: Check if kubeadm has already run
                    stat:
                      path: "/etc/kubernetes/pki/ca.key"
                    register: kubeadm_ca
                
                  - name: Starting kubeadm init...
                    when: kubeadm_ca.stat.exists == False
                    ansible.builtin.command:
                      argv:
                        - kubeadm
                        - init
                        - --apiserver-advertise-address={{ advertise_address }}
                        - --pod-network-cidr=10.244.0.0/16
                        - --apiserver-cert-extra-sans={{ cert_extra_sans }}
                
                  - name: Wait for kubeadm init complete
                    wait_for:
                      path: /etc/kubernetes/pki/ca.key
                
                
                  - name: Create .kube directory...
                    file:
                      path: "/root/.kube"
                      state: directory
                      owner: root
                      group: root
                      mode: 0755
                
                  - name: Copy cubectl config file to home direcrory.
                    become: true
                    ansible.builtin.copy:
                      remote_src: true
                      src: "/etc/kubernetes/admin.conf"
                      dest: "/root/.kube/config"
                      owner: root
                      group: root
                      mode: u=rw,g=r,o=r
                
                  - name: Install flanel...
                    ansible.builtin.command:
                      argv:
                        - kubectl
                        - apply
                        - -f
                        - https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
                #        - --validate=false
                
                  - name: Get worker node join command...
                    ansible.builtin.command:
                      argv:
                        - kubeadm
                        - token
                        - create
                        - --print-join-command
                    register: node_join_cmd
                
                  - name: Copy join command to file.
                    become: false
                    ansible.builtin.copy:
                      content: "{{ node_join_cmd.stdout }}"
                      dest: ~/cmd_file.txt
                      mode: u=rw,g=r,o=r
                    delegate_to: localhost
                
                - name: Join nodes
                  gather_facts: false
                  hosts: worker_nodes
                  vars:
                    ansible_user: ubuntu
                  become: yes
                  become_user: root
                  remote_user: ubuntu
                  tasks:
                  - name: Check if kubeadm has already run
                    stat:
                      path: "/etc/kubernetes/pki/ca.crt"
                    register: kubeadm_ca
                
                  - name: Execute kubeadm join...
                    when: kubeadm_ca.stat.exists == False
                    shell: "{{ lookup('file', '~/cmd_file.txt') }}"
            EOT
          + "ssh_public_key"    = <<-EOT
                ubuntu:ssh-ed25519 ****************************************************************************
            EOT
        }
    }

  # yandex_compute_instance.control_plane_vm[0] will be created
  + resource "yandex_compute_instance" "control_plane_vm" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "beatl-control-plane-1"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-ed25519 ****************************************************************************
            EOT
        }
      + name                      = "beatl-control-plane-1"
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
              + image_id    = "fd8dmgc8d3slc0q9pjvv"
              + name        = (known after apply)
              + size        = 100
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
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + resources {
          + core_fraction = 20
          + cores         = 4
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_compute_instance.worker_node_vm[0] will be created
  + resource "yandex_compute_instance" "worker_node_vm" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "beatl-worker-node-1"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-ed25519 *****************************************************************************
            EOT
        }
      + name                      = "beatl-worker-node-1"
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
              + image_id    = "fd8dmgc8d3slc0q9pjvv"
              + name        = (known after apply)
              + size        = 100
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
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + resources {
          + core_fraction = 5
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_compute_instance.worker_node_vm[1] will be created
  + resource "yandex_compute_instance" "worker_node_vm" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "beatl-worker-node-2"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-ed25519 *****************************************************************************
            EOT
        }
      + name                      = "beatl-worker-node-2"
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
              + image_id    = "fd8dmgc8d3slc0q9pjvv"
              + name        = (known after apply)
              + size        = 100
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
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + resources {
          + core_fraction = 5
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_compute_instance.worker_node_vm[2] will be created
  + resource "yandex_compute_instance" "worker_node_vm" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "beatl-worker-node-3"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-ed25519 *****************************************************************************
            EOT
        }
      + name                      = "beatl-worker-node-3"
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
              + image_id    = "fd8dmgc8d3slc0q9pjvv"
              + name        = (known after apply)
              + size        = 100
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
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + resources {
          + core_fraction = 5
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_compute_instance.worker_node_vm[3] will be created
  + resource "yandex_compute_instance" "worker_node_vm" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "beatl-worker-node-4"
      + id                        = (known after apply)
      + maintenance_grace_period  = (known after apply)
      + maintenance_policy        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-ed25519 *****************************************************************************
            EOT
        }
      + name                      = "beatl-worker-node-4"
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
              + image_id    = "fd8dmgc8d3slc0q9pjvv"
              + name        = (known after apply)
              + size        = 100
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
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + resources {
          + core_fraction = 5
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = true
        }
    }

  # yandex_vpc_network.kuber-net will be created
  + resource "yandex_vpc_network" "kuber-net" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "kuber-vpc"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_security_group.my_sec_grp will be created
  + resource "yandex_vpc_security_group" "my_sec_grp" {
      + created_at = (known after apply)
      + folder_id  = "b1ggopu0i05k9eac2102"
      + id         = (known after apply)
      + labels     = (known after apply)
      + name       = "example_dynamic"
      + network_id = (known after apply)
      + status     = (known after apply)

      + egress {
          + description    = "разрешить весь исходящий трафик"
          + from_port      = 0
          + id             = (known after apply)
          + labels         = (known after apply)
          + port           = -1
          + protocol       = "TCP"
          + to_port        = 65365
          + v4_cidr_blocks = [
              + "0.0.0.0/0",
            ]
          + v6_cidr_blocks = []
        }

      + ingress {
          + description    = "разрешить входящий  http"
          + from_port      = -1
          + id             = (known after apply)
          + labels         = (known after apply)
          + port           = 80
          + protocol       = "TCP"
          + to_port        = -1
          + v4_cidr_blocks = [
              + "0.0.0.0/0",
            ]
          + v6_cidr_blocks = []
        }
      + ingress {
          + description    = "разрешить входящий https"
          + from_port      = -1
          + id             = (known after apply)
          + labels         = (known after apply)
          + port           = 443
          + protocol       = "TCP"
          + to_port        = -1
          + v4_cidr_blocks = [
              + "0.0.0.0/0",
            ]
          + v6_cidr_blocks = []
        }
      + ingress {
          + description    = "разрешить входящий ssh"
          + from_port      = -1
          + id             = (known after apply)
          + labels         = (known after apply)
          + port           = 22
          + protocol       = "TCP"
          + to_port        = -1
          + v4_cidr_blocks = [
              + "0.0.0.0/0",
            ]
          + v6_cidr_blocks = []
        }
    }

  # yandex_vpc_subnet.kuber-subnet will be created
  + resource "yandex_vpc_subnet" "kuber-subnet" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "kuber-vpc"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "10.0.1.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

Plan: 10 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

yandex_vpc_network.kuber-net: Creating...
yandex_vpc_network.kuber-net: Creation complete after 2s [id=enp4oaq0ua1cvkkj2r0g]
yandex_vpc_subnet.kuber-subnet: Creating...
yandex_vpc_security_group.my_sec_grp: Creating...
yandex_vpc_subnet.kuber-subnet: Creation complete after 0s [id=e9bvqaqcd87d0480kce3]
yandex_compute_instance.worker_node_vm[3]: Creating...
yandex_compute_instance.worker_node_vm[0]: Creating...
yandex_compute_instance.worker_node_vm[2]: Creating...
yandex_compute_instance.worker_node_vm[1]: Creating...
yandex_compute_instance.control_plane_vm[0]: Creating...
yandex_vpc_security_group.my_sec_grp: Creation complete after 2s [id=enpi4ra6ave2cq7s38gp]
yandex_compute_instance.worker_node_vm[3]: Still creating... [10s elapsed]
yandex_compute_instance.worker_node_vm[0]: Still creating... [11s elapsed]
yandex_compute_instance.worker_node_vm[2]: Still creating... [11s elapsed]
yandex_compute_instance.worker_node_vm[1]: Still creating... [10s elapsed]
yandex_compute_instance.control_plane_vm[0]: Still creating... [10s elapsed]
yandex_compute_instance.worker_node_vm[3]: Still creating... [21s elapsed]
yandex_compute_instance.worker_node_vm[1]: Still creating... [20s elapsed]
yandex_compute_instance.worker_node_vm[2]: Still creating... [21s elapsed]
yandex_compute_instance.worker_node_vm[0]: Still creating... [21s elapsed]
yandex_compute_instance.control_plane_vm[0]: Still creating... [20s elapsed]
yandex_compute_instance.worker_node_vm[3]: Still creating... [31s elapsed]
yandex_compute_instance.worker_node_vm[0]: Still creating... [31s elapsed]
yandex_compute_instance.worker_node_vm[1]: Still creating... [30s elapsed]
yandex_compute_instance.worker_node_vm[2]: Still creating... [31s elapsed]
yandex_compute_instance.control_plane_vm[0]: Still creating... [30s elapsed]
yandex_compute_instance.control_plane_vm[0]: Creation complete after 30s [id=fhmtqkqr69kioqpmc104]
yandex_compute_instance.worker_node_vm[3]: Creation complete after 31s [id=fhmq6euj32fafjv1a8dh]
yandex_compute_instance.worker_node_vm[2]: Creation complete after 38s [id=fhmsb109ijsgv2kiqo50]
yandex_compute_instance.worker_node_vm[1]: Creation complete after 38s [id=fhml1iimpn41c9rj55ma]
yandex_compute_instance.worker_node_vm[0]: Still creating... [41s elapsed]
yandex_compute_instance.worker_node_vm[0]: Creation complete after 41s [id=fhmaniefr01heuuts10t]
null_resource.web_hosts_provision: Creating...
null_resource.web_hosts_provision: Provisioning with 'local-exec'...
null_resource.web_hosts_provision (local-exec): Executing: ["/bin/sh" "-c" "cat ~/.ssh/id_ed25519  | ssh-add -"]
null_resource.web_hosts_provision (local-exec): Identity added: (stdin) (beatl@OWEN)
null_resource.web_hosts_provision: Provisioning with 'local-exec'...
null_resource.web_hosts_provision (local-exec): Executing: ["/bin/sh" "-c" "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i /home/beatl/homeworks/K8s/3.2/hosts.cfg /home/beatl/homeworks/K8s/3.2/kubeinst.yml"]
local_file.hosts_cfg: Creating...
local_file.hosts_cfg: Creation complete after 0s [id=688ca885a2bb0673fcf9ef3250cf75816f829c34]

null_resource.web_hosts_provision (local-exec): PLAY [kubeinst] ****************************************************************

null_resource.web_hosts_provision (local-exec): TASK [Wait for system to become reachable] *************************************
null_resource.web_hosts_provision: Still creating... [10s elapsed]
null_resource.web_hosts_provision: Still creating... [20s elapsed]
null_resource.web_hosts_provision: Still creating... [30s elapsed]
null_resource.web_hosts_provision (local-exec): ok: [beatl-control-plane-1]
null_resource.web_hosts_provision (local-exec): ok: [beatl-worker-node-2]
null_resource.web_hosts_provision (local-exec): ok: [beatl-worker-node-4]
null_resource.web_hosts_provision (local-exec): ok: [beatl-worker-node-1]
null_resource.web_hosts_provision (local-exec): ok: [beatl-worker-node-3]

null_resource.web_hosts_provision (local-exec): TASK [Create directory for ssh-keys] *******************************************
null_resource.web_hosts_provision (local-exec): ok: [beatl-control-plane-1]
null_resource.web_hosts_provision (local-exec): ok: [beatl-worker-node-2]
null_resource.web_hosts_provision (local-exec): ok: [beatl-worker-node-1]
null_resource.web_hosts_provision (local-exec): ok: [beatl-worker-node-4]
null_resource.web_hosts_provision (local-exec): ok: [beatl-worker-node-3]

null_resource.web_hosts_provision (local-exec): TASK [Adding rsa-key in /root/.ssh/authorized_keys] ****************************
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-2]
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-3]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-4]

null_resource.web_hosts_provision (local-exec): TASK [Installing dependencies] *************************************************
null_resource.web_hosts_provision: Still creating... [40s elapsed]
null_resource.web_hosts_provision: Still creating... [50s elapsed]
null_resource.web_hosts_provision: Still creating... [1m0s elapsed]
null_resource.web_hosts_provision: Still creating... [1m10s elapsed]
null_resource.web_hosts_provision (local-exec): ok: [beatl-control-plane-1]
null_resource.web_hosts_provision (local-exec): ok: [beatl-worker-node-2]
null_resource.web_hosts_provision (local-exec): ok: [beatl-worker-node-1]
null_resource.web_hosts_provision (local-exec): ok: [beatl-worker-node-3]
null_resource.web_hosts_provision (local-exec): ok: [beatl-worker-node-4]

null_resource.web_hosts_provision (local-exec): TASK [Add kubernetes apt key] **************************************************
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-2]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-4]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-3]

null_resource.web_hosts_provision (local-exec): TASK [Create temporary file for worker node join command.] *********************
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-2]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-4]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-3]

null_resource.web_hosts_provision (local-exec): TASK [Create directory for GPG key] ********************************************
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-2]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-4]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-3]

null_resource.web_hosts_provision (local-exec): TASK [Create temporary file for kubernetes-apt-keyring.gpg] ********************
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-2]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-3]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-4]

null_resource.web_hosts_provision (local-exec): TASK [Create temporary file for armored Release.key.] **************************
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-2]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-3]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-4]

null_resource.web_hosts_provision (local-exec): TASK [Download GPG key.] *******************************************************
null_resource.web_hosts_provision: Still creating... [1m20s elapsed]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-2]
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-3]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-4]

null_resource.web_hosts_provision (local-exec): TASK [Dearmor GPG key.] ********************************************************
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-2]
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-3]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-4]

null_resource.web_hosts_provision (local-exec): TASK [Copy GPG key to /etc/apt/keyrings.] **************************************
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-2]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-3]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-4]

null_resource.web_hosts_provision (local-exec): TASK [Remove temporary file for armored key.] **********************************
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-3]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-4]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-2]

null_resource.web_hosts_provision (local-exec): TASK [Remove temporary file for GPG key.] **************************************
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-2]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-3]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-4]

null_resource.web_hosts_provision (local-exec): TASK [Add kubernetes DEB repository] *******************************************
null_resource.web_hosts_provision: Still creating... [1m30s elapsed]
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-2]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-3]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-4]

null_resource.web_hosts_provision (local-exec): TASK [Installing kubeadm] ******************************************************
null_resource.web_hosts_provision: Still creating... [1m40s elapsed]
null_resource.web_hosts_provision: Still creating... [1m50s elapsed]
null_resource.web_hosts_provision: Still creating... [2m0s elapsed]
null_resource.web_hosts_provision: Still creating... [2m10s elapsed]
null_resource.web_hosts_provision: Still creating... [2m20s elapsed]
null_resource.web_hosts_provision: Still creating... [2m30s elapsed]
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-2]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-3]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-4]

null_resource.web_hosts_provision (local-exec): TASK [Load module br_netfilter] ************************************************
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-2]
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-3]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-4]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-1]

null_resource.web_hosts_provision (local-exec): TASK [Set Sysctl fo enable forwarding] *****************************************
null_resource.web_hosts_provision: Still creating... [2m40s elapsed]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-2] => (item={'name': 'net.ipv4.ip_forward', 'value': 1})
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1] => (item={'name': 'net.ipv4.ip_forward', 'value': 1})
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-1] => (item={'name': 'net.ipv4.ip_forward', 'value': 1})
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-4] => (item={'name': 'net.ipv4.ip_forward', 'value': 1})
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-3] => (item={'name': 'net.ipv4.ip_forward', 'value': 1})
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-2] => (item={'name': 'net.bridge.bridge-nf-call-iptables', 'value': 1})
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1] => (item={'name': 'net.bridge.bridge-nf-call-iptables', 'value': 1})
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-1] => (item={'name': 'net.bridge.bridge-nf-call-iptables', 'value': 1})
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-4] => (item={'name': 'net.bridge.bridge-nf-call-iptables', 'value': 1})
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-3] => (item={'name': 'net.bridge.bridge-nf-call-iptables', 'value': 1})
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-2] => (item={'name': 'net.bridge.bridge-nf-call-ip6tables', 'value': 1})
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1] => (item={'name': 'net.bridge.bridge-nf-call-ip6tables', 'value': 1})
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-1] => (item={'name': 'net.bridge.bridge-nf-call-ip6tables', 'value': 1})
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1] => (item={'name': 'net.bridge.bridge-nf-call-arptables', 'value': 1})
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-2] => (item={'name': 'net.bridge.bridge-nf-call-arptables', 'value': 1})
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-1] => (item={'name': 'net.bridge.bridge-nf-call-arptables', 'value': 1})
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-4] => (item={'name': 'net.bridge.bridge-nf-call-ip6tables', 'value': 1})
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-3] => (item={'name': 'net.bridge.bridge-nf-call-ip6tables', 'value': 1})
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-3] => (item={'name': 'net.bridge.bridge-nf-call-arptables', 'value': 1})
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-4] => (item={'name': 'net.bridge.bridge-nf-call-arptables', 'value': 1})

null_resource.web_hosts_provision (local-exec): PLAY [Start control plane] *****************************************************

null_resource.web_hosts_provision (local-exec): TASK [Check if kubeadm has already run] ****************************************
null_resource.web_hosts_provision (local-exec): ok: [beatl-control-plane-1]

null_resource.web_hosts_provision (local-exec): TASK [Starting kubeadm init...] ************************************************
null_resource.web_hosts_provision: Still creating... [2m50s elapsed]
null_resource.web_hosts_provision: Still creating... [3m0s elapsed]
null_resource.web_hosts_provision: Still creating... [3m10s elapsed]
null_resource.web_hosts_provision: Still creating... [3m20s elapsed]
null_resource.web_hosts_provision: Still creating... [3m30s elapsed]
null_resource.web_hosts_provision: Still creating... [3m40s elapsed]
null_resource.web_hosts_provision: Still creating... [3m50s elapsed]
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1]

null_resource.web_hosts_provision (local-exec): TASK [Wait for kubeadm init complete] ******************************************
null_resource.web_hosts_provision (local-exec): ok: [beatl-control-plane-1]

null_resource.web_hosts_provision (local-exec): TASK [Create .kube directory...] ***********************************************
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1]

null_resource.web_hosts_provision (local-exec): TASK [Copy cubectl config file to home direcrory.] *****************************
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1]

null_resource.web_hosts_provision (local-exec): TASK [Install flanel...] *******************************************************
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1]

null_resource.web_hosts_provision (local-exec): TASK [Get worker node join command...] *****************************************
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1]

null_resource.web_hosts_provision (local-exec): TASK [Copy join command to file.] **********************************************
null_resource.web_hosts_provision (local-exec): changed: [beatl-control-plane-1 -> localhost]

null_resource.web_hosts_provision (local-exec): PLAY [Join nodes] **************************************************************

null_resource.web_hosts_provision (local-exec): TASK [Check if kubeadm has already run] ****************************************
null_resource.web_hosts_provision (local-exec): ok: [beatl-worker-node-1]
null_resource.web_hosts_provision (local-exec): ok: [beatl-worker-node-2]
null_resource.web_hosts_provision (local-exec): ok: [beatl-worker-node-4]
null_resource.web_hosts_provision (local-exec): ok: [beatl-worker-node-3]

null_resource.web_hosts_provision (local-exec): TASK [Execute kubeadm join...] *************************************************
null_resource.web_hosts_provision: Still creating... [4m0s elapsed]
null_resource.web_hosts_provision: Still creating... [4m10s elapsed]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-2]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-3]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-1]
null_resource.web_hosts_provision (local-exec): changed: [beatl-worker-node-4]

null_resource.web_hosts_provision (local-exec): PLAY RECAP *********************************************************************
null_resource.web_hosts_provision (local-exec): beatl-control-plane-1      : ok=26   changed=21   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
null_resource.web_hosts_provision (local-exec): beatl-worker-node-1        : ok=20   changed=16   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
null_resource.web_hosts_provision (local-exec): beatl-worker-node-2        : ok=20   changed=16   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
null_resource.web_hosts_provision (local-exec): beatl-worker-node-3        : ok=20   changed=16   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
null_resource.web_hosts_provision (local-exec): beatl-worker-node-4        : ok=20   changed=16   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

null_resource.web_hosts_provision: Creation complete after 4m12s [id=5755936465662263566]

Apply complete! Resources: 10 added, 0 changed, 0 destroyed.
```

</details>

<details>
    <summary> Вывод консоли при проверке созданного кластера ...  </summary>

```
beatl@Sirius:~/homeworks/K8s/3.2$ ssh -A ubuntu@84.201.134.135
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0-173-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro
New release '22.04.3 LTS' available.
Run 'do-release-upgrade' to upgrade to it.

Last login: Fri Mar 22 20:52:02 2024 from 176.122.66.162

ubuntu@beatl-control-plane-1:~$ sudo kubectl get nodes -o wide
NAME                    STATUS   ROLES           AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
beatl-control-plane-1   Ready    control-plane   107s   v1.29.3   10.0.1.11     <none>        Ubuntu 20.04.6 LTS   5.4.0-173-generic   containerd://1.7.2
beatl-worker-node-1     Ready    <none>          82s    v1.29.3   10.0.1.12     <none>        Ubuntu 20.04.6 LTS   5.4.0-173-generic   containerd://1.7.2
beatl-worker-node-2     Ready    <none>          84s    v1.29.3   10.0.1.31     <none>        Ubuntu 20.04.6 LTS   5.4.0-173-generic   containerd://1.7.2
beatl-worker-node-3     Ready    <none>          82s    v1.29.3   10.0.1.5      <none>        Ubuntu 20.04.6 LTS   5.4.0-173-generic   containerd://1.7.2
beatl-worker-node-4     Ready    <none>          82s    v1.29.3   10.0.1.22     <none>        Ubuntu 20.04.6 LTS   5.4.0-173-generic   containerd://1.7.2

ubuntu@beatl-control-plane-1:~$ sudo kubectl describe node beatl-control-plane-1
Name:               beatl-control-plane-1
Roles:              control-plane
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=beatl-control-plane-1
                    kubernetes.io/os=linux
                    node-role.kubernetes.io/control-plane=
                    node.kubernetes.io/exclude-from-external-load-balancers=
Annotations:        flannel.alpha.coreos.com/backend-data: {"VNI":1,"VtepMAC":"ea:3f:dc:d9:8e:60"}
                    flannel.alpha.coreos.com/backend-type: vxlan
                    flannel.alpha.coreos.com/kube-subnet-manager: true
                    flannel.alpha.coreos.com/public-ip: 10.0.1.11
                    kubeadm.alpha.kubernetes.io/cri-socket: unix:///var/run/containerd/containerd.sock
                    node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Fri, 22 Mar 2024 20:51:53 +0000
Taints:             node-role.kubernetes.io/control-plane:NoSchedule
Unschedulable:      false
Lease:
  HolderIdentity:  beatl-control-plane-1
  AcquireTime:     <unset>
  RenewTime:       Fri, 22 Mar 2024 20:55:01 +0000
Conditions:
  Type                 Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----                 ------  -----------------                 ------------------                ------                       -------
  NetworkUnavailable   False   Fri, 22 Mar 2024 20:52:27 +0000   Fri, 22 Mar 2024 20:52:27 +0000   FlannelIsUp                  Flannel is running on this node
  MemoryPressure       False   Fri, 22 Mar 2024 20:52:28 +0000   Fri, 22 Mar 2024 20:51:53 +0000   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure         False   Fri, 22 Mar 2024 20:52:28 +0000   Fri, 22 Mar 2024 20:51:53 +0000   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure          False   Fri, 22 Mar 2024 20:52:28 +0000   Fri, 22 Mar 2024 20:51:53 +0000   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready                True    Fri, 22 Mar 2024 20:52:28 +0000   Fri, 22 Mar 2024 20:52:24 +0000   KubeletReady                 kubelet is posting ready status. AppArmor enabled
Addresses:
  InternalIP:  10.0.1.11
  Hostname:    beatl-control-plane-1
Capacity:
  cpu:                4
  ephemeral-storage:  103106736Ki
  hugepages-2Mi:      0
  memory:             4013492Ki
  pods:               110
Allocatable:
  cpu:                4
  ephemeral-storage:  95023167741
  hugepages-2Mi:      0
  memory:             3911092Ki
  pods:               110
System Info:
  Machine ID:                 23000007c6ddd535b32692c6b3660404
  System UUID:                23000007-c6dd-d535-b326-92c6b3660404
  Boot ID:                    2db14876-2d71-46d7-a589-5d031eb91b27
  Kernel Version:             5.4.0-173-generic
  OS Image:                   Ubuntu 20.04.6 LTS
  Operating System:           linux
  Architecture:               amd64
  Container Runtime Version:  containerd://1.7.2
  Kubelet Version:            v1.29.3
  Kube-Proxy Version:         v1.29.3
PodCIDR:                      10.244.0.0/24
PodCIDRs:                     10.244.0.0/24
Non-terminated Pods:          (8 in total)
  Namespace                   Name                                             CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                                             ------------  ----------  ---------------  -------------  ---
  kube-flannel                kube-flannel-ds-gl6lf                            100m (2%)     0 (0%)      50Mi (1%)        0 (0%)         2m59s
  kube-system                 coredns-76f75df574-9zcb2                         100m (2%)     0 (0%)      70Mi (1%)        170Mi (4%)     2m59s
  kube-system                 coredns-76f75df574-g567v                         100m (2%)     0 (0%)      70Mi (1%)        170Mi (4%)     2m59s
  kube-system                 etcd-beatl-control-plane-1                       100m (2%)     0 (0%)      100Mi (2%)       0 (0%)         3m12s
  kube-system                 kube-apiserver-beatl-control-plane-1             250m (6%)     0 (0%)      0 (0%)           0 (0%)         3m16s
  kube-system                 kube-controller-manager-beatl-control-plane-1    200m (5%)     0 (0%)      0 (0%)           0 (0%)         3m12s
  kube-system                 kube-proxy-tnpmv                                 0 (0%)        0 (0%)      0 (0%)           0 (0%)         2m59s
  kube-system                 kube-scheduler-beatl-control-plane-1             100m (2%)     0 (0%)      0 (0%)           0 (0%)         3m12s
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests    Limits
  --------           --------    ------
  cpu                950m (23%)  0 (0%)
  memory             290Mi (7%)  340Mi (8%)
  ephemeral-storage  0 (0%)      0 (0%)
  hugepages-2Mi      0 (0%)      0 (0%)
Events:
  Type     Reason                   Age                    From             Message
  ----     ------                   ----                   ----             -------
  Normal   Starting                 2m58s                  kube-proxy       
  Normal   Starting                 3m24s                  kubelet          Starting kubelet.
  Warning  InvalidDiskCapacity      3m24s                  kubelet          invalid capacity 0 on image filesystem
  Normal   NodeAllocatableEnforced  3m23s                  kubelet          Updated Node Allocatable limit across pods
  Normal   NodeHasNoDiskPressure    3m23s (x7 over 3m23s)  kubelet          Node beatl-control-plane-1 status is now: NodeHasNoDiskPressure
  Normal   NodeHasSufficientPID     3m23s (x7 over 3m23s)  kubelet          Node beatl-control-plane-1 status is now: NodeHasSufficientPID
  Normal   NodeHasSufficientMemory  3m23s (x8 over 3m23s)  kubelet          Node beatl-control-plane-1 status is now: NodeHasSufficientMemory
  Normal   Starting                 3m13s                  kubelet          Starting kubelet.
  Warning  InvalidDiskCapacity      3m13s                  kubelet          invalid capacity 0 on image filesystem
  Normal   NodeHasSufficientMemory  3m12s                  kubelet          Node beatl-control-plane-1 status is now: NodeHasSufficientMemory
  Normal   NodeHasNoDiskPressure    3m12s                  kubelet          Node beatl-control-plane-1 status is now: NodeHasNoDiskPressure
  Normal   NodeHasSufficientPID     3m12s                  kubelet          Node beatl-control-plane-1 status is now: NodeHasSufficientPID
  Normal   NodeAllocatableEnforced  3m12s                  kubelet          Updated Node Allocatable limit across pods
  Normal   RegisteredNode           2m59s                  node-controller  Node beatl-control-plane-1 event: Registered Node beatl-control-plane-1 in Controller
  Normal   NodeReady                2m46s                  kubelet          Node beatl-control-plane-1 status is now: NodeReady
  
ubuntu@beatl-control-plane-1:~$ exit
logout
Connection to 84.201.134.135 closed.
```
</details>

---

###### #task2
### Результат выполнения задания 2*: Установить HA кластер

К сожалению попытка создать НА кластер оказалась неудачной.

Выполнение скрипта Ansible происходит успешно, успешно поднимается и конфигурируется master нода, но дальше в при попытке подключения второй control ноды возникает ошибка и скрипт далее работает некорректно.

Пытался победить это несколько дней, пробовал разные адреса, порты, вообще без указания портов, создал статический IP в качестве адреса кластера - все безуспешно.

Для чистоты эксперимента пробовал вообще без Ansible из консоли 2-й ноды. Результат ниже...

<details>
    <summary> Вывод консоли kubeadm join ...  </summary>

```
beatl@Sirius:~/homeworks/K8s/3.2$ ssh -A ubuntu@51.250.6.200
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0-174-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro
New release '22.04.3 LTS' available.
Run 'do-release-upgrade' to upgrade to it.

Last login: Wed Apr  3 11:16:43 2024 from 176.122.66.162

ubuntu@beatl-control-plane-2:~$ sudo kubeadm join 192.158.218.189:6443 --token=bhrglb.mc86hhtc7tqm80az --discovery-token-ca-cert-hash=sha256:b8411044165200a2c31e852f128dad79cc6298467ee73506d8b20acb8c390fbf --control-plane --certificate-key=0f0e9293bf49653b5c6930f7e44b6c3f4fc7b7e82f1f7e02a39d38f9dfb4a541 -v=5
I0403 11:34:39.533624    5902 join.go:413] [preflight] found NodeName empty; using OS hostname as NodeName
I0403 11:34:39.533699    5902 join.go:417] [preflight] found advertiseAddress empty; using default interface's IP address as advertiseAddress
I0403 11:34:39.533907    5902 initconfiguration.go:122] detected and using CRI socket: unix:///var/run/containerd/containerd.sock
I0403 11:34:39.534140    5902 interface.go:432] Looking for default routes with IPv4 addresses
I0403 11:34:39.534155    5902 interface.go:437] Default route transits interface "eth0"
I0403 11:34:39.534288    5902 interface.go:209] Interface eth0 is up
I0403 11:34:39.534368    5902 interface.go:257] Interface "eth0" has 3 addresses :[10.0.1.31/24 192.158.218.189/24 fe80::d20d:c4ff:fea7:a298/64].
I0403 11:34:39.534396    5902 interface.go:224] Checking addr  10.0.1.31/24.
I0403 11:34:39.534411    5902 interface.go:231] IP found 10.0.1.31
I0403 11:34:39.534437    5902 interface.go:263] Found valid IPv4 address 10.0.1.31 for interface "eth0".
I0403 11:34:39.534458    5902 interface.go:443] Found active IP 10.0.1.31 
[preflight] Running pre-flight checks
I0403 11:34:39.534587    5902 preflight.go:93] [preflight] Running general checks
I0403 11:34:39.534669    5902 checks.go:280] validating the existence of file /etc/kubernetes/kubelet.conf
I0403 11:34:39.534702    5902 checks.go:280] validating the existence of file /etc/kubernetes/bootstrap-kubelet.conf
I0403 11:34:39.534722    5902 checks.go:104] validating the container runtime
I0403 11:34:39.562233    5902 checks.go:639] validating whether swap is enabled or not
I0403 11:34:39.562337    5902 checks.go:370] validating the presence of executable crictl
I0403 11:34:39.562408    5902 checks.go:370] validating the presence of executable conntrack
I0403 11:34:39.562768    5902 checks.go:370] validating the presence of executable ip
I0403 11:34:39.562808    5902 checks.go:370] validating the presence of executable iptables
I0403 11:34:39.562831    5902 checks.go:370] validating the presence of executable mount
I0403 11:34:39.562853    5902 checks.go:370] validating the presence of executable nsenter
I0403 11:34:39.562890    5902 checks.go:370] validating the presence of executable ebtables
I0403 11:34:39.562919    5902 checks.go:370] validating the presence of executable ethtool
I0403 11:34:39.563083    5902 checks.go:370] validating the presence of executable socat
I0403 11:34:39.563126    5902 checks.go:370] validating the presence of executable tc
I0403 11:34:39.563164    5902 checks.go:370] validating the presence of executable touch
I0403 11:34:39.563201    5902 checks.go:516] running all checks
I0403 11:34:39.578793    5902 checks.go:401] checking whether the given node name is valid and reachable using net.LookupHost
I0403 11:34:39.579022    5902 checks.go:605] validating kubelet version
I0403 11:34:39.651138    5902 checks.go:130] validating if the "kubelet" service is enabled and active
I0403 11:34:39.662845    5902 checks.go:203] validating availability of port 10250
I0403 11:34:39.663167    5902 checks.go:430] validating if the connectivity type is via proxy or direct
I0403 11:34:39.663266    5902 checks.go:329] validating the contents of file /proc/sys/net/bridge/bridge-nf-call-iptables
I0403 11:34:39.663363    5902 checks.go:329] validating the contents of file /proc/sys/net/ipv4/ip_forward
I0403 11:34:39.663429    5902 join.go:532] [preflight] Discovering cluster-info
I0403 11:34:39.663471    5902 token.go:80] [discovery] Created cluster-info discovery client, requesting info from "192.158.218.189:6443"
I0403 11:34:39.664463    5902 token.go:217] [discovery] Failed to request cluster-info, will try again: Get "https://192.158.218.189:6443/api/v1/namespaces/kube-public/configmaps/cluster-info?timeout=10s": dial tcp 192.158.218.189:6443: connect: connection refused
I0403 11:34:45.276625    5902 token.go:217] [discovery] Failed to request cluster-info, will try again: Get "https://192.158.218.189:6443/api/v1/namespaces/kube-public/configmaps/cluster-info?timeout=10s": dial tcp 192.158.218.189:6443: connect: connection refused

                                           ----- Skiped -----

I0403 11:39:29.692301    5902 token.go:217] [discovery] Failed to request cluster-info, will try again: Get "https://192.158.218.189:6443/api/v1/namespaces/kube-public/configmaps/cluster-info?timeout=10s": dial tcp 192.158.218.189:6443: connect: connection refused
I0403 11:39:34.922166    5902 token.go:217] [discovery] Failed to request cluster-info, will try again: Get "https://192.158.218.189:6443/api/v1/namespaces/kube-public/configmaps/cluster-info?timeout=10s": dial tcp 192.158.218.189:6443: connect: connection refused
Get "https://192.158.218.189:6443/api/v1/namespaces/kube-public/configmaps/cluster-info?timeout=10s": dial tcp 192.158.218.189:6443: connect: connection refused
couldn't validate the identity of the API Server
k8s.io/kubernetes/cmd/kubeadm/app/discovery.For
        cmd/kubeadm/app/discovery/discovery.go:45
k8s.io/kubernetes/cmd/kubeadm/app/cmd.(*joinData).TLSBootstrapCfg
        cmd/kubeadm/app/cmd/join.go:533
k8s.io/kubernetes/cmd/kubeadm/app/cmd.(*joinData).InitCfg
        cmd/kubeadm/app/cmd/join.go:543
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/join.runPreflight
        cmd/kubeadm/app/cmd/phases/join/preflight.go:98
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow.(*Runner).Run.func1
        cmd/kubeadm/app/cmd/phases/workflow/runner.go:259
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow.(*Runner).visitAll
        cmd/kubeadm/app/cmd/phases/workflow/runner.go:446
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow.(*Runner).Run
        cmd/kubeadm/app/cmd/phases/workflow/runner.go:232
k8s.io/kubernetes/cmd/kubeadm/app/cmd.newCmdJoin.func1
        cmd/kubeadm/app/cmd/join.go:180
github.com/spf13/cobra.(*Command).execute
        vendor/github.com/spf13/cobra/command.go:940
github.com/spf13/cobra.(*Command).ExecuteC
        vendor/github.com/spf13/cobra/command.go:1068
github.com/spf13/cobra.(*Command).Execute
        vendor/github.com/spf13/cobra/command.go:992
k8s.io/kubernetes/cmd/kubeadm/app.Run
        cmd/kubeadm/app/kubeadm.go:50
main.main
        cmd/kubeadm/kubeadm.go:25
runtime.main
        /usr/local/go/src/runtime/proc.go:267
runtime.goexit
        /usr/local/go/src/runtime/asm_amd64.s:1650
error execution phase preflight
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow.(*Runner).Run.func1
        cmd/kubeadm/app/cmd/phases/workflow/runner.go:260
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow.(*Runner).visitAll
        cmd/kubeadm/app/cmd/phases/workflow/runner.go:446
k8s.io/kubernetes/cmd/kubeadm/app/cmd/phases/workflow.(*Runner).Run
        cmd/kubeadm/app/cmd/phases/workflow/runner.go:232
k8s.io/kubernetes/cmd/kubeadm/app/cmd.newCmdJoin.func1
        cmd/kubeadm/app/cmd/join.go:180
github.com/spf13/cobra.(*Command).execute
        vendor/github.com/spf13/cobra/command.go:940
github.com/spf13/cobra.(*Command).ExecuteC
        vendor/github.com/spf13/cobra/command.go:1068
github.com/spf13/cobra.(*Command).Execute
        vendor/github.com/spf13/cobra/command.go:992
k8s.io/kubernetes/cmd/kubeadm/app.Run
        cmd/kubeadm/app/kubeadm.go:50
main.main
        cmd/kubeadm/kubeadm.go:25
runtime.main
        /usr/local/go/src/runtime/proc.go:267
runtime.goexit
        /usr/local/go/src/runtime/asm_amd64.s:1650
```
</details>

и нода не создается. Тот же результат при подключении worker нод.

<details>
    <summary> Вывод консоли `kubectl get nodes` на  master ноде  ...  </summary>

```
ubuntu@beatl-control-plane-1:~$ sudo kubectl get nodes -o wide
NAME                    STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
beatl-control-plane-1   Ready    control-plane   48m   v1.29.3   10.0.1.13     <none>        Ubuntu 20.04.6 LTS   5.4.0-174-generic   containerd://1.7.2
```
</details>

думаю что проблема в правах/ключах доступа или сертификатах.
Попробую еще позже.

---

###### student
### Исполнитель

Сергей Жуков DevOps-32

---