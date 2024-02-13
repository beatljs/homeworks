
---
<img src="../Netology.png" height="24px"/>

### Учебная группа DevOps-32

---

## Решение по домашнему заданию к занятию «Сетевое взаимодействие в K8S. Часть 1» 

Домашнее задание выполнялось на локальной машине с ОС Ubuntu 22.04.3 LTS и MicroK8S

- [Решение задания 1: Создать Deployment приложений backend и frontend](#task1) 
- [Решение задания 2: Создать Ingress и обеспечить доступ к приложениям снаружи кластера](#task2) 
- [Исполнитель](#student)


---

###### task1
### Решение задания 1: Создать Deployment приложений backend и frontend

[Файл-манифест Deployment для `backend`](./my-test5-be-deploy.yaml)

[Файл-манифест Deployment для `frontend`](./my-test5-fe-deploy.yaml)

[Файл-манифест Service для `backend`](./my-nginx-svc.yaml)

[Файл-манифест Service для `frontend`](./my-mtool-svc.yaml)

<details>
    <summary> Вывод консоли команды `curl` из пода backend для проверки доступа...  </summary>

```
beatl@Sirius:~/homeworks$ k exec my-test5-be-deployment-74f4475797-htwlc -it -- sh

/ # curl my-nginx-svc
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
/ # exit
```

</details>

---

###### task2
### Решение задания 2: Создать Ingress и обеспечить доступ к приложениям снаружи кластера

[Файл-манифест для Ingress `my-ingress`](./my-test5-ingress.yaml)

<details>
    <summary> Вывод консоли при создании Ingress...  </summary>

```
beatl@Sirius:~/homeworks/K8s/1.5$ kaf my-test5-ingress.yaml
ingress.networking.k8s.io/my-ingress created

beatl@Sirius:~/homeworks/K8s/1.5$ kgi
NAME         CLASS   HOSTS       ADDRESS   PORTS   AGE
my-ingress   nginx   localhost             80      8s

beatl@Sirius:~/homeworks/K8s/1.5$ kgi
NAME         CLASS   HOSTS       ADDRESS     PORTS   AGE
my-ingress   nginx   localhost   127.0.0.1   80      19s
```

</details>

<details>
    <summary> Вывод консоли 'curl localhost' ...  </summary>

```
beatl@Sirius:~/homeworks/K8s/1.5$ curl -v localhost
*   Trying [::1]:80...
* connect to ::1 port 80 failed: В соединении отказано
*   Trying 127.0.0.1:80...
* Connected to localhost (127.0.0.1) port 80
> GET / HTTP/1.1
> Host: localhost
> User-Agent: curl/8.4.0
> Accept: */*
> 
< HTTP/1.1 200 OK
< Date: Sun, 11 Feb 2024 07:28:25 GMT
< Content-Type: text/html
< Content-Length: 612
< Connection: keep-alive
< Last-Modified: Tue, 04 Dec 2018 14:44:49 GMT
< ETag: "5c0692e1-264"
< Accept-Ranges: bytes
< 
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
* Connection #0 to host localhost left intact
```

</details>

<details>
    <summary> Вывод консоли  Вывод консоли 'curl localhost/api' ...  </summary>

```
beatl@Sirius:~/homeworks/K8s/1.5$ curl -v localhost/api
*   Trying [::1]:80...
* connect to ::1 port 80 failed: В соединении отказано
*   Trying 127.0.0.1:80...
* Connected to localhost (127.0.0.1) port 80
> GET /api HTTP/1.1
> Host: localhost
> User-Agent: curl/8.4.0
> Accept: */*
> 
< HTTP/1.1 200 OK
< Date: Sun, 11 Feb 2024 07:28:08 GMT
< Content-Type: text/html
< Content-Length: 158
< Connection: keep-alive
< Last-Modified: Sun, 11 Feb 2024 06:32:32 GMT
< ETag: "65c86a00-9e"
< Accept-Ranges: bytes
< 
WBITT Network MultiTool (with NGINX) - my-test5-be-deployment-74f4475797-htwlc - 10.1.230.193 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)
* Connection #0 to host localhost left intact
```

</details>

---

###### student
### Исполнитель

Сергей Жуков DevOps-32

---