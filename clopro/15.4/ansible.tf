resource "local_file" "phpa-deploy" {
  depends_on = [yandex_mdb_mysql_cluster.mysql-cluster]
  content = templatefile("${path.module}/ingress.tfpl",
  {
    mysql_server_addr = yandex_mdb_mysql_cluster.mysql-cluster.host[0].fqdn
    alb_secgrps = "${yandex_vpc_security_group.regional-k8s-sg.id}, ${yandex_vpc_security_group.k8s-nodes-ssh-access.id}, ${yandex_vpc_security_group.k8s-public-services.id}, ${yandex_vpc_security_group.k8s-master-whitelist.id}"
    alb_subnets = "${yandex_vpc_subnet.k8s-subnet[0].id}"
    alb_cert = var.ca_cert
  })
  filename = "${abspath(path.module)}/ingress.yaml"
}

resource "null_resource" "k8s-cluster-credentials" {
#Ждем создания инстанса
depends_on = [yandex_kubernetes_cluster.k8s-regional,yandex_kubernetes_node_group.k8s-beatl-ng]
  provisioner "local-exec" {
    command = "yc managed-kubernetes cluster get-credentials --id ${yandex_kubernetes_cluster.k8s-regional.id} --external --force"
  }
}

resource "null_resource" "keyfile-for-sa" {
#Ждем создания инстанса
depends_on = [yandex_iam_service_account.beatl-regional-sa]
  provisioner "local-exec" {
    command = "yc iam key create --service-account-name ${yandex_iam_service_account.beatl-regional-sa.name} --output sa-key.json --folder-id ${var.folder_id}"
  }
}

resource "null_resource" "ext-secret-oper" {
#Ждем создания инстанса
depends_on = [yandex_kubernetes_cluster.k8s-regional,yandex_kubernetes_node_group.k8s-beatl-ng,null_resource.keyfile-for-sa,null_resource.k8s-cluster-credentials]
  provisioner "local-exec" {
    command = "helm repo add external-secrets https://charts.external-secrets.io && helm install external-secrets external-secrets/external-secrets --namespace external-secrets --create-namespace"
  }
}

resource "null_resource" "yc-auth-secret" {
#Ждем создания инстанса
depends_on = [yandex_kubernetes_cluster.k8s-regional,yandex_kubernetes_node_group.k8s-beatl-ng,null_resource.keyfile-for-sa,null_resource.k8s-cluster-credentials]
  provisioner "local-exec" {
    command = "kubectl create namespace ns-eso && kubectl --namespace ns-eso create secret generic yc-auth --from-file=sa-key=sa-key.json"
  }
}

resource "null_resource" "helm-external-dns" {
#Ждем создания инстанса
depends_on = [yandex_kubernetes_cluster.k8s-regional,yandex_kubernetes_node_group.k8s-beatl-ng,null_resource.keyfile-for-sa,null_resource.k8s-cluster-credentials]
  provisioner "local-exec" {
    command = "export HELM_EXPERIMENTAL_OCI=1 && helm pull oci://cr.yandex/yc-marketplace/yandex-cloud/externaldns/chart/externaldns --version 0.5.1 --untar && helm install --namespace default --create-namespace --set config.folder_id=${var.folder_id} --set-file config.auth.json=sa-key.json externaldns ./externaldns/"
  }
}

resource "null_resource" "helm-ingress-nginx-alb" {
#Ждем создания инстанса
depends_on = [yandex_kubernetes_cluster.k8s-regional,yandex_kubernetes_node_group.k8s-beatl-ng,null_resource.k8s-cluster-credentials]
  provisioner "local-exec" {
    command = "export HELM_EXPERIMENTAL_OCI=1 && cat key.json | helm registry login cr.yandex --username 'json_key' --password-stdin && helm pull oci://cr.yandex/yc-marketplace/yandex-cloud/yc-alb-ingress/yc-alb-ingress-controller-chart --version v0.2.3 --untar && helm install --namespace default --create-namespace --set folderId=${var.folder_id} --set clusterId=${yandex_kubernetes_cluster.k8s-regional.id} --set-file saKeySecretKey=sa-key.json yc-alb-ingress-controller ./yc-alb-ingress-controller-chart/"
  }
}


/*
resource "null_resource" "deoloy-acme-issuer" {
#Ждем создания инстанса
depends_on = [yandex_kubernetes_cluster.k8s-regional,yandex_kubernetes_node_group.k8s-beatl-ng,null_resource.k8s-cluster-credentials]
  provisioner "local-exec" {
    command = "kubectl apply -f acme-issuer.yaml --wait=true"
  }
}
*/
resource "null_resource" "deoloy-phpa-and-service" {
#Ждем создания инстанса
depends_on = [yandex_mdb_mysql_cluster.mysql-cluster, yandex_kubernetes_cluster.k8s-regional, yandex_kubernetes_node_group.k8s-beatl-ng, local_file.phpa-deploy, null_resource.k8s-cluster-credentials, null_resource.helm-ingress-nginx-alb]
  provisioner "local-exec" {
    command = "kubectl apply -f ingress.yaml --wait=true"
  }
}