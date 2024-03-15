
---
<img src="../Netology.png" height="24px"/>

### Учебная группа DevOps-32

---

## Решение по домашнему заданию к занятию «Управление доступом»

Домашнее задание выполнялось на локальной машине с ОС Ubuntu 22.04.3 LTS и MicroK8S

### Содержание

- [Решение задания 1: Создайте конфигурацию для подключения пользователя](#task1) 
- [Исполнитель](#student)


---

###### task1
### Решение задания 1: Создайте конфигурацию для подключения пользователя

Создаем key для пользователя `semen`

```
openssl genrsa -out semen.key 2048

beatl@Sirius:~/homeworks/K8s/2.4$ ls
2.4.md  semen.key
```

Создаем CSR запрос для сертификата

```
obeatl@Sirius:~/homeworks/K8s/2.4$ openssl req -new -key semen.key -out semen.csr -subj "/CN=semen/O=ops"

beatl@Sirius:~/homeworks/K8s/2.4$ ls
2.4.md  semen.csr  semen.key
```

Кодируем base64

```
cat semen.csr | base64

LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1l6Q0NBVXNDQVFBd0hqRU9N
QXdHQTFVRUF3d0ZjMlZ0Wlc0eEREQUtCZ05WQkFvTUEyOXdjekNDQVNJdwpEUVlKS29aSWh2Y05B
UUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTks0cU5sOTFBK0I0enZScXUwNmRVckQvWXNhCkJoakR4
YlpZWDNhNVYyUi9YT0pScEFZWEFYNmpRWTNUeGVmd2JqTEpaUmI1dDlyT2ZqY0xaQmJvOU9SSUxP
b3oKZGdEN242MTVaaUZBOU03NElFa0h3eGNVSm15dWFTc3pnbFY5ck54OWVEZDdKWU4yL3h1Mk9E
aGxhdzNYRlVZZgp2V01LTVN0N0tPRERWTkVmWjQ0LzhmOFRrRjltN3pYY0VzdVZwTHpEN2pwbldM
MWtRTitLbk00KzVGZDBPZW03CkdUOXhDZ0Y0V0wwdHRxakNGQkF3VXZhYUE3UUZXeGllSjgwdkRT
eVhxWVBTTEFCK0hZWjcxVVNMUmJ6V084WkMKOEw1QU9OYjhzOVpIVUNUdnhRTFJCS1IwVUNQNnZH
Wk9mbW9GUHlxWG4zTG5LVC9UclJNK1VlOHZwbFVDQXdFQQpBYUFBTUEwR0NTcUdTSWIzRFFFQkN3
VUFBNElCQVFCcnppTmQ1VFF1RjErQkpZVzJDOEFPVC9Vb1YwczNZOEtRCkl4WlR6RGRPd0NURlc3
Nmd5ZldtdThaTURmMXdaeitJR0hqcFNuTVRGT0pReHIzVGYyejFoT01EdXlzcGhCT3kKbkVZdllT
d24xekRVc2tDa3hHK3VHVkIra0pSb0dCcU9PaG9HdHRja2wyK0ZDMTV1MFc1czFBa2hhdkN6N0NU
WQpudEhQM2ozd054d1I2V2tTUUJKWS8rMEpxSFlSOFltYmQwK1NFaXdLSkRKeGprWFBBcXp2MWpF
N05kSEc0NzNWCjh0a3A3RG1qOWNpRnhWRGpsc1NGTDcyUlpHc3pORFM1Um1aSi9aRFBWUzQzc0p5
YTNpWmltdTdTREN2Y00wWHkKUWw2c3IvWVh1M0ZxdzJvWGpBYjJIQTRDSVo2czZrdXA2d2NPQkhz
Z3VianRzWnpTVzJLZQotLS0tLUVORCBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0K
```

[Файл-манифест для  `my-semen-csr`](./my-semen-csr.yaml)

```
beatl@Sirius:~/homeworks/K8s/2.4$ kaf my-semen-csr.yaml
certificatesigningrequest.certificates.k8s.io/ssl-csr created

beatl@Sirius:~/homeworks/K8s/2.4$ k get csr
NAME      AGE   SIGNERNAME                            REQUESTOR   REQUESTEDDURATION   CONDITION
ssl-csr   20s   kubernetes.io/kube-apiserver-client   admin       <none>              Pending

beatl@Sirius:~/homeworks/K8s/2.4$ kubectl certificate approve ssl-csr
certificatesigningrequest.certificates.k8s.io/ssl-csr approved

beatl@Sirius:~/homeworks/K8s/2.4$ k get csr
NAME      AGE   SIGNERNAME                            REQUESTOR   REQUESTEDDURATION   CONDITION
ssl-csr   98s   kubernetes.io/kube-apiserver-client   admin       <none>              Approved,Issued

beatl@Sirius:~/homeworks/K8s/2.4$ kubectl get csr ssl-csr -o jsonpath={.status.certificate} | base64 --decode > semen.crt

beatl@Sirius:~/homeworks/K8s/2.4$ cat semen.crt
-----BEGIN CERTIFICATE-----
MIIDBjCCAe6gAwIBAgIRAL8s6FE6pdvTfwFlNAyq6/8wDQYJKoZIhvcNAQELBQAw

---- Skip -----

-----END CERTIFICATE-----
```

Создаем роли и binding для пользователя `semen`

[Файл-манифест для роли `my-pod-reader` и `my-pod-reader-bind`](./my-semen-role.yaml)

```
beatl@Sirius:~/homeworks/K8s/2.4$ kaf my-semen-role.yaml
role.rbac.authorization.k8s.io/my-pod-reader created
rolebinding.rbac.authorization.k8s.io/my-pod-reader-bind created

beatl@Sirius:~/homeworks/K8s/2.4$ k get roles
NAME            CREATED AT
my-pod-reader   2024-03-15T09:11:41Z
```

Добавляем пользователя `semen` в кластер и создаем для него контекст

```
beatl@Sirius:~/homeworks/K8s/2.4$ kubectl config set-credentials semen --client-certificate semen.crt --client-key semen.key --embed-certs=true
User "semen" set.

beatl@Sirius:~/homeworks/K8s/2.4$ k config set-context semen-context --cluster=microk8s-cluster --user=semen
Context "semen-context" created.

beatl@Sirius:~/homeworks/K8s/2.4$ k config get-contexts
CURRENT   NAME            CLUSTER            AUTHINFO   NAMESPACE
*         microk8s        microk8s-cluster   admin      lesson2-4
          semen-context   microk8s-cluster   semen      
```

Создаем pod для проверки

[Файл-манифест для пода `semen-pod`](./my-semen-pod.yaml)

```
beatl@Sirius:~/homeworks/K8s/2.4$ kaf my-semen-pod.yaml
pod/semen-pod created

beatl@Sirius:~/homeworks/K8s/2.4$ kgp
NAME                           READY   STATUS    RESTARTS   AGE
semen-pod                      1/1     Running   0          7s
```

Переключаемся на контекст пользователя

```
beatl@Sirius:~/homeworks/K8s/2.4$ k config use-context semen-context
Switched to context "semen-context".
```

Проверяем наличие и отсутствие доступа согласно ДЗ

```
beatl@Sirius:~/homeworks/K8s/2.4$ kgp -n=lesson2-4
Error from server (Forbidden): pods is forbidden: User "semen" cannot list resource "pods" in API group "" in the namespace "lesson2-4"

beatl@Sirius:~/homeworks/K8s/2.4$ k logs semen-pod -n=lesson2-4
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2024/03/15 09:41:51 [notice] 1#1: using the "epoll" event method
2024/03/15 09:41:51 [notice] 1#1: nginx/1.25.4
2024/03/15 09:41:51 [notice] 1#1: built by gcc 12.2.0 (Debian 12.2.0-14) 
2024/03/15 09:41:51 [notice] 1#1: OS: Linux 6.5.0-25-generic
2024/03/15 09:41:51 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 65536:65536
2024/03/15 09:41:51 [notice] 1#1: start worker processes
2024/03/15 09:41:51 [notice] 1#1: start worker process 29
    ---- Skip ----
2024/03/15 09:41:51 [notice] 1#1: start worker process 44

beatl@Sirius:~/homeworks/K8s/2.4$ k describe pod semen-pod -n=lesson2-4
Name:             semen-pod
Namespace:        lesson2-4
Priority:         0
Service Account:  default
Node:             sirius/192.168.0.45
Start Time:       Fri, 15 Mar 2024 12:41:49 +0300
Labels:           <none>
Annotations:      cni.projectcalico.org/containerID: 4d4ec6c74a43ee2ab634c9040e59e5a8bf39b0be5f0ed6541814a93df05951e8
                  cni.projectcalico.org/podIP: 10.1.230.226/32
                  cni.projectcalico.org/podIPs: 10.1.230.226/32
Status:           Running
IP:               10.1.230.226
IPs:
  IP:  10.1.230.226
Containers:
  nginx:
    Container ID:   containerd://eeb09bbb68e0a16e901bd50efe1807d82b9d54149f025cf1c9d32183326c0431
    Image:          nginx
    Image ID:       docker.io/library/nginx@sha256:6db391d1c0cfb30588ba0bf72ea999404f2764febf0f1f196acd5867ac7efa7e
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Fri, 15 Mar 2024 12:41:51 +0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-6798m (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-6798m:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>
```

P.S.: Файлы сертификатов и ключей в репозиторий выкладывать не стал, а то Git ругается ...

---

###### student
### Исполнитель

Сергей Жуков DevOps-32

---