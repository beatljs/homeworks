resource "local_file" "phpa-deploy" {
  depends_on = [yandex_mdb_mysql_cluster.mysql-cluster]
  content = templatefile("${path.module}/ingress.tfpl",
  {
    mysql_server_addr = yandex_mdb_mysql_cluster.mysql-cluster.host[0].fqdn
  })
  filename = "${abspath(path.module)}/ingress.yaml"
}

resource "local_file" "secrets-template" {
  content = templatefile("${path.module}/ext-secret.tfpl",
  {
    le-cert-id = var.ca_cert
  })
  filename = "${abspath(path.module)}/ext-secret.yaml"
}

resource "null_resource" "k8s-cluster-credentials" {
  depends_on = [yandex_kubernetes_cluster.k8s-regional,yandex_kubernetes_node_group.k8s-beatl-ng]
  provisioner "local-exec" {
    command = "yc managed-kubernetes cluster get-credentials --id ${yandex_kubernetes_cluster.k8s-regional.id} --external --force"
  }
}

resource "null_resource" "keyfile-for-sa" {
  depends_on = [yandex_iam_service_account.beatl-k8s-r-sa]
  provisioner "local-exec" {
    command = "yc iam key create --service-account-name ${yandex_iam_service_account.eso-service-account.name} --output authorized-key.json"
  }
}

resource "null_resource" "keyfile-bind" {
  depends_on = [yandex_iam_service_account.beatl-k8s-r-sa, null_resource.keyfile-for-sa]
  provisioner "local-exec" {
    command = "yc cm certificate add-access-binding --id ${var.ca_cert} --service-account-name ${yandex_iam_service_account.eso-service-account.name} --role certificate-manager.certificates.downloader"
  }
}

resource "null_resource" "ext-secret-oper" {
  depends_on = [yandex_kubernetes_cluster.k8s-regional,yandex_kubernetes_node_group.k8s-beatl-ng,null_resource.keyfile-for-sa,null_resource.k8s-cluster-credentials]
  provisioner "local-exec" {
    command = "helm repo add external-secrets https://charts.external-secrets.io && helm install external-secrets external-secrets/external-secrets --namespace external-secrets --create-namespace"
  }
}

resource "null_resource" "yc-auth-secret" {
  depends_on = [yandex_kubernetes_cluster.k8s-regional,yandex_kubernetes_node_group.k8s-beatl-ng,null_resource.keyfile-for-sa,null_resource.k8s-cluster-credentials]
  provisioner "local-exec" {
    command = "kubectl create namespace beatl-ns && kubectl --namespace beatl-ns create secret generic yc-auth --from-file=authorized-key=authorized-key.json"
  }
}

resource "null_resource" "deoloy-ext-secret-store" {
  depends_on = [yandex_kubernetes_cluster.k8s-regional, yandex_kubernetes_node_group.k8s-beatl-ng, local_file.secrets-template, null_resource.yc-auth-secret, null_resource.ext-secret-oper]
  provisioner "local-exec" {
    command = "sleep 180"
  }
  provisioner "local-exec" {
    command = "kubectl --namespace beatl-ns apply -f secret-store.yaml --wait=true"
  }
}

resource "null_resource" "deoloy-ext-secrets" {
  depends_on = [null_resource.deoloy-ext-secret-store]
  provisioner "local-exec" {
    command = "sleep 30"
  }
  provisioner "local-exec" {
    command = "kubectl --namespace beatl-ns apply -f ext-secret.yaml --wait=true"
  }
}

resource "null_resource" "helm-ingress-nginx" {
  depends_on = [yandex_kubernetes_cluster.k8s-regional,yandex_kubernetes_node_group.k8s-beatl-ng,null_resource.k8s-cluster-credentials, null_resource.deoloy-ext-secrets]
  provisioner "local-exec" {
    command = "helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && helm repo update && helm install ingress-nginx ingress-nginx/ingress-nginx"
  }
}

resource "null_resource" "deoloy-phpa-and-service" {
  depends_on = [yandex_mdb_mysql_cluster.mysql-cluster, yandex_kubernetes_cluster.k8s-regional, yandex_kubernetes_node_group.k8s-beatl-ng, local_file.phpa-deploy, null_resource.k8s-cluster-credentials, null_resource.helm-ingress-nginx]
  provisioner "local-exec" {
    command = "sleep 60"
  }
  provisioner "local-exec" {
    command = "kubectl --namespace beatl-ns apply -f ingress.yaml --wait=true"
  }
  provisioner "local-exec" {
    command = "sleep 60" // ждем адреса
  }
  provisioner "local-exec" {
    command = "kubectl get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}' > ${var.nlbaddr-filename}"
  }
}

