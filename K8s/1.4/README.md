
---
<img src="../Netology.png" height="24px"/>

### Учебная группа DevOps-32

---

## Решение по домашнему заданию к занятию «Сетевое взаимодействие в K8S. Часть 1» 

Домашнее задание выполнялось на локальной машине с ОС Ubuntu 22.04.3 LTS и MicroK8S

- [Решение задания 1: Создать Deployment и обеспечить доступ к контейнерам приложения по разным портам из другого Pod внутри кластера](#task1) 
- [Решение задания 2: Создать Service и обеспечить доступ к приложениям снаружи кластера](#task2) 
- [Исполнитель](#student)


---

###### task1
### Решение задания 1: Создать Deployment и обеспечить доступ к контейнерам приложения по разным портам из другого Pod внутри кластера

[Файл-манифест для Deployment `my-test4-deployment` и сервиса `test4-service`](./my-test4-deploy.yaml)

<details>
    <summary> Вывод консоли `kubectl apply` и `kubectl get pods` ...  </summary>

```
beatl@Sirius:~/homeworks/K8s/1.3$ kubectl get pods
No resources found in lesson3 namespace.

beatl@Sirius:~/homeworks/K8s/1.3$ kubectl apply -f my-test4-deploy.yaml
deployment.apps/my-test4-deployment created
service/test4-service created

beatl@Sirius:~/homeworks/K8s/1.4$ kubectl get pods
NAME                                   READY   STATUS    RESTARTS   AGE
my-test4-deployment-5d8ddf88bd-wxq5f   2/2     Running   0          16m
my-test4-deployment-5d8ddf88bd-nhlnk   2/2     Running   0          16m
my-test4-deployment-5d8ddf88bd-2x7fw   2/2     Running   0          16m
```

</details>

<details>
    <summary> Вывод консоли `kubectl get svc`...  </summary>

```
beatl@Sirius:~/homeworks/K8s/1.4$ kubectl get svc
NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
test4-service   ClusterIP   10.152.183.153   <none>        9001/TCP,9002/TCP   18m
```

</details>

<details>
    <summary> Вывод консоли при создании пода для проверки доступа и демонстрация доступа до разных подов...  </summary>

```
beatl@Sirius:~/homeworks/K8s/1.4$ kubectl run -n lesson4 my-curl-pod --image=wbitt/network-multitool -it --rm -- sh
If you don't see a command prompt, try pressing enter.

/ # nslookup test4-service
Server:         10.152.183.10
Address:        10.152.183.10#53

Name:   test4-service.lesson4.svc.cluster.local
Address: 10.152.183.153

/ # curl test4-service:9001
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>
<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>
<p><em>Thank you for using nginx.</em></p>
</body>
</html>

/ # curl test4-service:9002
WBITT Network MultiTool (with NGINX) - my-test4-deployment-5d8ddf88bd-2x7fw - 10.1.230.246 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)

/ # curl test4-service:9002
WBITT Network MultiTool (with NGINX) - my-test4-deployment-5d8ddf88bd-wxq5f - 10.1.230.239 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)

/ # curl test4-service:9002
WBITT Network MultiTool (with NGINX) - my-test4-deployment-5d8ddf88bd-nhlnk - 10.1.230.247 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)
```

</details>

---

###### task2
### Решение задания 2: Создать Service и обеспечить доступ к приложениям снаружи кластера

[Файл-манифест для Service `test4-nodeport-service`](./test4-nodeport-service.yaml)

<details>
    <summary> Вывод консоли `kubectl get nodes`...  </summary>

```
beatl@Sirius:~/homeworks/K8s/1.4$ kubectl get nodes -o wide
NAME     STATUS   ROLES    AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
sirius   Ready    <none>   13d   v1.28.3   192.168.0.45   <none>        Ubuntu 22.04.3 LTS   6.5.0-17-generic   containerd://1.6.15
```

</details>

<details>
    <summary> Вывод консоли `kubectl describe svc`...  </summary>

```
beatl@Sirius:~/homeworks/K8s/1.4$ kubectl describe svc test4-nodeport-service
Name:                     test4-nodeport-service
Namespace:                lesson4
Labels:                   <none>
Annotations:              <none>
Selector:                 app=my-app4
Type:                     NodePort
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.152.183.35
IPs:                      10.152.183.35
Port:                     port-nginx  9001/TCP
TargetPort:               80/TCP
NodePort:                 port-nginx  30001/TCP
Endpoints:                10.1.230.239:80,10.1.230.246:80,10.1.230.247:80
Port:                     port-multitool  9002/TCP
TargetPort:               8080/TCP
NodePort:                 port-multitool  30002/TCP
Endpoints:                10.1.230.239:8080,10.1.230.246:8080,10.1.230.247:8080
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

</details>

<details>
    <summary> Вывод консоли `curl ...` после старта сервиса...  </summary>

```
beatl@Sirius:~/homeworks/K8s/1.4$ curl http://192.168.0.45:30001
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>
<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>
<p><em>Thank you for using nginx.</em></p>
</body>
</html>

beatl@Sirius:~/homeworks/K8s/1.4$ curl http://192.168.0.45:30002
WBITT Network MultiTool (with NGINX) - my-test4-deployment-5d8ddf88bd-nhlnk - 10.1.230.247 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)

beatl@Sirius:~/homeworks/K8s/1.4$ curl http://192.168.0.45:30002
WBITT Network MultiTool (with NGINX) - my-test4-deployment-5d8ddf88bd-2x7fw - 10.1.230.246 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)

beatl@Sirius:~/homeworks/K8s/1.4$ curl http://192.168.0.45:30002
WBITT Network MultiTool (with NGINX) - my-test4-deployment-5d8ddf88bd-wxq5f - 10.1.230.239 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)
```

</details>

---

###### student
### Исполнитель

Сергей Жуков DevOps-32

---