resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/hosts.tftpl", 
  {
    config = {
      control_planes =  yandex_compute_instance.control_plane_vm
      worker_nodes = yandex_compute_instance.worker_node_vm
    }
 //   cluster_addr = yandex_vpc_address.addr
    cluster_addr = "192.158.218.189"
    ha = var.enable_ha
  })
  filename = "${abspath(path.module)}/hosts.cfg"
}

resource "null_resource" "web_hosts_provision" {
#Ждем создания инстанса
depends_on = [yandex_compute_instance.worker_node_vm,yandex_compute_instance.control_plane_vm]

#Добавление ПРИВАТНОГО ssh ключа в ssh-agent
  provisioner "local-exec" {
    command = "cat ~/.ssh/id_ed25519  | ssh-add -"
  }


#Запуск ansible-playbook
  provisioner "local-exec" {
    command  = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ${abspath(path.module)}/hosts.cfg ${abspath(path.module)}/kubeinst.yml"
    on_failure = continue #Продолжить выполнение terraform pipeline в случае ошибок
    environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
    #срабатывание триггера при изменении переменных
  }
    triggers = {
      always_run         = "${timestamp()}" #всегда т.к. дата и время постоянно изменяются
      playbook_src_hash  = file("${abspath(path.module)}/kubeinst.yml") # при изменении содержимого playbook файла
      ssh_public_key     = local.ssh-key # при изменении переменной
    }
}