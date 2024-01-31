
---
<img src="../Netology.png" height="24px"/>

### Учебная группа DevOps-32

---

## Решение по домашнему заданию к занятию «Kubernetes. Причины появления. Команда kubectl» 

Домашнее задание выполнялось на локальной машине с ОС Ubuntu 22.04.3 LTS

- [Решение задания 1. Установка MicroK8S](#task1) 
- [Решение задания 2: Установка и настройка локального kubectl](#task2) 
- [Исполнитель](#student)


---

###### task1
### Решение задания 1. Установка MicroK8S

<details>
    <summary> Вывод консоли с версией установленного MicroK8S...  </summary>

```
beatl@Sirius:~$ microk8s version
MicroK8s v1.28.3 revision 6089
```

</details>

<details>
    <summary> Вывод консоли с установленными аддонами...  </summary>

```
beatl@Sirius:~$ microk8s status
microk8s is running
high-availability: no
  datastore master nodes: 127.0.0.1:19001
  datastore standby nodes: none
addons:
  enabled:
    dashboard            # (core) The Kubernetes dashboard
    dns                  # (core) CoreDNS
    ha-cluster           # (core) Configure high availability on the current node
    helm                 # (core) Helm - the package manager for Kubernetes
    helm3                # (core) Helm 3 - the package manager for Kubernetes
    metrics-server       # (core) K8s Metrics Server for API access to service metrics
  disabled:
    cert-manager         # (core) Cloud native certificate management
    cis-hardening        # (core) Apply CIS K8s hardening
    community            # (core) The community addons repository
    gpu                  # (core) Automatic enablement of Nvidia CUDA
    host-access          # (core) Allow Pods connecting to Host services smoothly
    hostpath-storage     # (core) Storage class; allocates storage from host directory
    ingress              # (core) Ingress controller for external access
    kube-ovn             # (core) An advanced network fabric for Kubernetes
    mayastor             # (core) OpenEBS MayaStor
    metallb              # (core) Loadbalancer for your Kubernetes cluster
    minio                # (core) MinIO object storage
    observability        # (core) A lightweight observability stack for logs, traces and metrics
    prometheus           # (core) Prometheus operator for monitoring and logging
    rbac                 # (core) Role-Based Access Control for authorisation
    registry             # (core) Private image registry exposed on localhost:32000
    rook-ceph            # (core) Distributed Ceph storage using Rook
    storage              # (core) Alias to hostpath-storage add-on, deprecated
```

</details>

Файл `/var/snap/microk8s/current/certs/csr.conf.template`: [csr.conf.template](./csr.conf.template)

Команда `sudo microk8s refresh-certs --cert front-proxy-client.crt` выполнилась успешно, но вывод консоли затерся (давно делал), поэтому здесь его не привожу.  

---

###### task2
### Решение задания 2: Установка и настройка локального kubectl

<details>
    <summary> Вывод консоли с версией установленного kubectl...  </summary>

```
beatl@Sirius:~$ kubectl version
Client Version: v1.29.1
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
Server Version: v1.28.3

```

</details>

<details>
    <summary> Вывод консоли 'kubectl get nodes'...  </summary>

```
beatl@Sirius:~$ kubectl get nodes -o wide
NAME     STATUS   ROLES    AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
sirius   Ready    <none>   4d16h   v1.28.3   192.168.0.45   <none>        Ubuntu 22.04.3 LTS   6.5.0-15-generic   containerd://1.6.15

```

</details>


<details>
    <summary> Вывод консоли с командой проброса портов...  </summary>

```
beatl@Sirius:~$ microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443
Forwarding from 127.0.0.1:10443 -> 8443
Forwarding from [::1]:10443 -> 8443
Handling connection for 10443
Handling connection for 10443
Handling connection for 10443
Handling connection for 10443

```

</details>

[Скриншот dashboard](./screenshort.png)


---

###### Student 
### Исполнитель

Сергей Жуков DevOps-32

---