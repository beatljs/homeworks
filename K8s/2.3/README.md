
---
<img src="../Netology.png" height="24px"/>

### Учебная группа DevOps-32

---

## Решение по домашнему заданию к занятию «Конфигурация приложений» 

Домашнее задание выполнялось на локальной машине с ОС Ubuntu 22.04.3 LTS и MicroK8S

### Содержание

- [Решение задания 1: Создать Deployment приложения и решить возникшую проблему с помощью ConfigMap. Добавить веб-страницу](#task1) 
- [Решение задания 2: Создать приложение с вашей веб-страницей, доступной по HTTPS](#task2) 
- [Исполнитель](#student)


---

###### task1
### Решение задания 1: Создать Deployment приложения и решить возникшую проблему с помощью ConfigMap. Добавить веб-страницу

[Файл-манифест для Deployment `my-configmap-deployment` и сервиса `my-cm-service`](./my-cm-deploy.yaml)

<details>
    <summary> Содержимое файла с ConfigMap `my-configmap.yaml` ...  </summary>

```
piVersion: v1
kind: ConfigMap
metadata:
  name: my-configmap
  namespace: lesson2-3
data:
  http_port: "8080"
  index.html: |
    <!DOCTYPE html>
    <html>
      <head>
        <title>My test nginx page!</title>
      </head>
      <body>
        <h1>This test nginx page for NETOLOGY homework!</h1>
      </body>
    </html>
```

</details>

<br>

<details>
    <summary> Вывод консоли демонстрирующий, что все работает согласно заданию ...  </summary>

```
beatl@Sirius:~/homeworks/K8s/2.3$ kaf my-cm-deploy.yaml
deployment.apps/my-configmap-deployment created
service/my-cm-service created

beatl@Sirius:~/homeworks/K8s/2.3$ kgp
NAME                                       READY   STATUS                       RESTARTS   AGE
my-configmap-deployment-66c5bd9bf9-xr7cc   1/2     CreateContainerConfigError   0          16s

beatl@Sirius:~/homeworks/K8s/2.3$ kaf my-configmap.yaml
configmap/my-configmap created

beatl@Sirius:~/homeworks/K8s/2.3$ kgp -o wide
NAME                                       READY   STATUS    RESTARTS   AGE   IP             NODE     NOMINATED NODE   READINESS GATES
my-configmap-deployment-66c5bd9bf9-xr7cc   2/2     Running   0          56s   10.1.230.217   sirius   <none>           <none>

beatl@Sirius:~/homeworks/K8s/2.3$ curl 10.1.230.217
<!DOCTYPE html>
<html>
  <head>
    <title>My test nginx page!</title>
  </head>
  <body>
    <h1>This test nginx page for NETOLOGY homework!</h1>
  </body>
</html>

beatl@Sirius:~/homeworks/K8s/2.3$ curl 10.1.230.217:8080
WBITT Network MultiTool (with NGINX) - my-configmap-deployment-66c5bd9bf9-xr7cc - 10.1.230.217 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)

beatl@Sirius:~/homeworks/K8s/2.3$ k get svc
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
my-cm-service   ClusterIP   10.152.183.47   <none>        9000/TCP   90m

beatl@Sirius:~/homeworks/K8s/2.3$ curl 10.152.183.47:9000
<!DOCTYPE html>
<html>
  <head>
    <title>My test nginx page!</title>
  </head>
  <body>
    <h1>This test nginx page for NETOLOGY homework!</h1>
  </body>
</html>

```
</details>

---

###### task2
### Решение задания 2: Создать приложение с вашей веб-страницей, доступной по HTTPS

[Файл-манифест для Deployment `my-tls-deployment` и сервиса `my-tls-service`](./my-tls-deploy.yaml)

[Файл-манифест для ConfigMap `my-tls-configmap`](./my-tls-configmap.yaml)

[Файл-манифест для Ingress `my-tls-ingress`](./my-tls-ingress.yaml)

Для создания самоподписанного сертификата и секрета установил и использовал сервис k8s https://cert-manager.io/ 

<details>
    <summary> Вывод консоли подключения cert-manager...  </summary>

```
beatl@Sirius:~/homeworks/K8s/2.3$ microk8s enable cert-manager
Infer repository core for addon cert-manager
Enable DNS addon
Infer repository core for addon dns
Addon core/dns is already enabled
Enabling cert-manager
namespace/cert-manager created
customresourcedefinition.apiextensions.k8s.io/certificaterequests.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/certificates.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/challenges.acme.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/clusterissuers.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/issuers.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/orders.acme.cert-manager.io created
serviceaccount/cert-manager-cainjector created
serviceaccount/cert-manager created
serviceaccount/cert-manager-webhook created
configmap/cert-manager-webhook created
clusterrole.rbac.authorization.k8s.io/cert-manager-cainjector created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-issuers created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-clusterissuers created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-certificates created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-orders created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-challenges created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-ingress-shim created
clusterrole.rbac.authorization.k8s.io/cert-manager-view created
clusterrole.rbac.authorization.k8s.io/cert-manager-edit created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-approve:cert-manager-io created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-certificatesigningrequests created
clusterrole.rbac.authorization.k8s.io/cert-manager-webhook:subjectaccessreviews created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-cainjector created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-issuers created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-clusterissuers created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-certificates created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-orders created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-challenges created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-ingress-shim created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-approve:cert-manager-io created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-certificatesigningrequests created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-webhook:subjectaccessreviews created
role.rbac.authorization.k8s.io/cert-manager-cainjector:leaderelection created
role.rbac.authorization.k8s.io/cert-manager:leaderelection created
role.rbac.authorization.k8s.io/cert-manager-webhook:dynamic-serving created
rolebinding.rbac.authorization.k8s.io/cert-manager-cainjector:leaderelection created
rolebinding.rbac.authorization.k8s.io/cert-manager:leaderelection created
rolebinding.rbac.authorization.k8s.io/cert-manager-webhook:dynamic-serving created
service/cert-manager created
service/cert-manager-webhook created
deployment.apps/cert-manager-cainjector created
deployment.apps/cert-manager created
deployment.apps/cert-manager-webhook created
mutatingwebhookconfiguration.admissionregistration.k8s.io/cert-manager-webhook created
validatingwebhookconfiguration.admissionregistration.k8s.io/cert-manager-webhook created
Waiting for cert-manager to be ready.
...ready
Enabled cert-manager
```

</details>

[Файл-манифест для Issuer `selfsigned-issuer`](./my-issuer.yaml)

[Файл-манифест для сертификата `my-selfsigned-ca`](./my-selfsign-cert.yaml)

<details>
    <summary> Вывод консоли создания сертификата...  </summary>

```
beatl@Sirius:~/homeworks/K8s/2.3$ kaf my-issuer.yaml
issuer.cert-manager.io/selfsigned-issuer created

beatl@Sirius:~/homeworks/K8s/2.3$ kaf my-selfsign-cert.yaml
certificate.cert-manager.io/my-selfsigned-ca created
```

</details>

<details>
    <summary> Вывод консоли запуска ConfigMap, Deploy, Service, Ingress ...  </summary>

```
beatl@Sirius:~/homeworks/K8s/2.3$ kaf my-tls-configmap.yaml
configmap/my-tls-configmap created

beatl@Sirius:~/homeworks/K8s/2.3$ kaf my-tls-deploy.yaml
deployment.apps/my-tls-deployment created
service/my-tls-service created

beatl@Sirius:~/homeworks/K8s/2.3$ kaf my-tls-ingress.yaml
ingress.networking.k8s.io/my-tls-ingress created
```

</details>

<details>
    <summary> Вывод консоли при доступе к странице по https ...  </summary>

```
beatl@Sirius:~/homeworks/K8s/2.3$ curl https://localhost
curl: (60) SSL certificate problem: self-signed certificate
More details here: https://curl.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.

beatl@Sirius:~/homeworks/K8s/2.3$ curl -k https://localhost
<!DOCTYPE html>
<html>
  <head>
    <title>My test nginx HTTPS page!</title>
  </head>
  <body>
    <h1>This is test nginx HTTPS page for NETOLOGY homework!</h1>
  </body>
</html>
```
</details>

---

###### student
### Исполнитель

Сергей Жуков DevOps-32

---