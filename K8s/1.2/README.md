
---
<img src="../Netology.png" height="24px"/>

### Учебная группа DevOps-32

---

## Решение по домашнему заданию к занятию «Базовые объекты K8S» 

Домашнее задание выполнялось на локальной машине с ОС Ubuntu 22.04.3 LTS

- [Решение задания 1: Создать Pod с именем hello-world](#task1) 
- [Решение задания 2: Создать Service и подключить его к Pod](#task2) 
- [Исполнитель](#student)


---

###### task1
### Решение задания 1: Создать Pod с именем hello-world

[Файл-манифест для Pod `hello-world`](./pod-hello-world.yaml)

<details>
    <summary> Вывод консоли `kubectl apply` и `kubectl get pods` ...  </summary>

```
beatl@Sirius:~/homeworks/K8s/1.2$ kubectl apply -f pod-hello-world.yaml
pod/hello-world created

beatl@Sirius:~/homeworks/K8s/1.2$ kubectl get pods
NAME           READY   STATUS    RESTARTS   AGE
hello-world    1/1     Running   0          32s
```

</details>

<details>
    <summary> Вывод консоли `kubectl port-forward` и запроса `curl`...  </summary>

```
beatl@Sirius:~/homeworks/K8s/1.2$ kubectl port-forward pod/hello-world 8888:8080
Forwarding from 127.0.0.1:8888 -> 8080
Handling connection for 8888
Handling connection for 8888
Handling connection for 8888
................

beatl@Sirius:~/homeworks$ curl 127.0.0.1:8888

Hostname: hello-world

Pod Information:
        -no pod information available-

Server values:
        server_version=nginx: 1.12.2 - lua: 10010

Request Information:
        client_address=127.0.0.1
        method=GET
        real path=/
        query=
        request_version=1.1
        request_scheme=http
        request_uri=http://127.0.0.1:8080/

Request Headers:
        accept=*/*  
        host=127.0.0.1:8888  
        user-agent=curl/8.4.0  

Request Body:
        -no body in request-
```

</details>

---

###### task2
### Решение задания 2: Создать Service и подключить его к Pod

[Файл-манифест для Pod `netology-web`](./pod-netology-web.yaml)

[Файл-манифест для Service `test-service`](./k8s-test-service.yaml)

<details>
    <summary> Вывод консоли `kubectl apply` и `kubectl get pods` ...  </summary>

```
beatl@Sirius:~/homeworks/K8s/1.2$ kubectl apply -f pod-netology-web.yaml
pod/netology-web created

beatl@Sirius:~/homeworks/K8s/1.2$ kubectl get pods
NAME           READY   STATUS    RESTARTS   AGE
hello-world    1/1     Running   0          27m
netology-web   1/1     Running   0          17s

```

</details>

<details>
    <summary> Вывод консоли `kubectl apply` и `kubectl get svc` ...  </summary>

```
beatl@Sirius:~/homeworks/K8s/1.2$ kubectl apply -f k8s-test-service.yaml
service/test-service created

beatl@Sirius:~/homeworks/K8s/1.2$ kubectl get svc -o wide
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE     SELECTOR
kubernetes     ClusterIP   10.152.183.1    <none>        443/TCP   4d23h   <none>
test-service   ClusterIP   10.152.183.97   <none>        80/TCP    3m24s   app=beatlapp
```

</details>

<details>
    <summary> Вывод консоли `kubectl describe svc` ...  </summary>

```
beatl@Sirius:~/homeworks$ kubectl describe svc test-service
Name:              test-service
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          app=beatlapp
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.152.183.97
IPs:               10.152.183.97
Port:              test-web  80/TCP
TargetPort:        8080/TCP
Endpoints:         10.1.230.245:8080,10.1.230.246:8080
Session Affinity:  None
Events:            <none>
```

</details>

<details>
    <summary> Вывод консоли `kubectl port-forward` и запроса `curl`...  </summary>

```
beatl@Sirius:~/homeworks/K8s/1.2$ kubectl port-forward svc/test-service 30080:80
Forwarding from 127.0.0.1:30080 -> 8080
Handling connection for 30080
Handling connection for 30080
Handling connection for 30080
................

beatl@Sirius:~/homeworks$ curl 127.0.0.1:30080

Hostname: netology-web

Pod Information:
        -no pod information available-

Server values:
        server_version=nginx: 1.12.2 - lua: 10010

Request Information:
        client_address=127.0.0.1
        method=GET
        real path=/
        query=
        request_version=1.1
        request_scheme=http
        request_uri=http://127.0.0.1:8080/

Request Headers:
        accept=*/*  
        host=127.0.0.1:30080  
        user-agent=curl/8.4.0  

Request Body:
        -no body in request-

```

</details>


---

###### Student 
### Исполнитель

Сергей Жуков DevOps-32

---