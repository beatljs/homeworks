
---
<img src="../Netology.png" height="24px"/>

### Учебная группа DevOps-32

---

## Решение по домашнему заданию к занятию «Запуск приложений в K8S» 

Домашнее задание выполнялось на локальной машине с ОС Ubuntu 22.04.3 LTS

- [Решение задания 1: Создать Deployment и обеспечить доступ к репликам приложения из другого Pod](#task1) 
- [Решение задания 2: Создать Deployment и обеспечить старт основного контейнера при выполнении условий](#task2) 
- [Исполнитель](#student)


---

###### task1
### Решение задания 1: Создать Deployment и обеспечить доступ к репликам приложения из другого Pod

[Файл-манифест для Deployment `my-test-deployment` и сервиса `my-service`](./my-test-deploy.yaml)

<details>
    <summary> Вывод консоли `kubectl apply` и `kubectl get pods` ...  </summary>

```
beatl@Sirius:~/homeworks/K8s/1.3$ kubectl get pods
No resources found in lesson3 namespace.

beatl@Sirius:~/homeworks/K8s/1.3$ kubectl apply -f my-test-deploy.yaml
deployment.apps/my-test-deployment created
service/test-service created

beatl@Sirius:~/homeworks/K8s/1.3$ kubectl get pods
NAME                                  READY   STATUS    RESTARTS   AGE
my-test-deployment-684ddfd54c-5mxn6   2/2     Running   0          64s
```

</details>

Увеличиваем количество реплик до 2

<details>
    <summary> Вывод консоли `kubectl apply` и `kubectl get pods`...  </summary>

```
beatl@Sirius:~/homeworks/K8s/1.3$ kubectl apply -f my-test-deploy.yaml
deployment.apps/my-test-deployment configured
service/test-service unchanged

beatl@Sirius:~/homeworks/K8s/1.3$ kubectl get pods
NAME                                  READY   STATUS    RESTARTS   AGE
my-test-deployment-684ddfd54c-5mxn6   2/2     Running   0          5m6s
my-test-deployment-684ddfd54c-gqq9t   2/2     Running   0          8s

```

</details>

<details>
    <summary> Вывод консоли `kubectl describe svc`...  </summary>

```
beatl@Sirius:~/homeworks/K8s/1.3$ kubectl describe svc
Name:              test-service
Namespace:         lesson3
Labels:            <none>
Annotations:       <none>
Selector:          app=my-app1
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.152.183.67
IPs:               10.152.183.67
Port:              test-nginx  80/TCP
TargetPort:        80/TCP
Endpoints:         10.1.230.236:80,10.1.230.242:80
Port:              test-multitool  8088/TCP
TargetPort:        8080/TCP
Endpoints:         10.1.230.236:8080,10.1.230.242:8080
Session Affinity:  None
Events:            <none>

```

</details>

<details>
    <summary> Вывод консоли при создании пода для проверки доступа и демонстрация доступа до приложений п.1...  </summary>

```
beatl@Sirius:~/homeworks/K8s/1.3$ kubectl run -n lesson3 my-curl-pod --image=wbitt/network-multitool -it --rm -- sh
If you don't see a command prompt, try pressing enter.

/ # curl test-service
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

/ # curl test-service:8088
WBITT Network MultiTool (with NGINX) - my-test-deployment-684ddfd54c-5mxn6 - 10.1.230.236 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)

/ # curl test-service:8088
WBITT Network MultiTool (with NGINX) - my-test-deployment-684ddfd54c-5mxn6 - 10.1.230.236 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)

/ # curl test-service:8088
WBITT Network MultiTool (with NGINX) - my-test-deployment-684ddfd54c-5mxn6 - 10.1.230.236 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)

/ # curl test-service:8088
WBITT Network MultiTool (with NGINX) - my-test-deployment-684ddfd54c-gqq9t - 10.1.230.242 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)

/ # curl test-service:8088
WBITT Network MultiTool (with NGINX) - my-test-deployment-684ddfd54c-5mxn6 - 10.1.230.236 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)

/ # curl test-service:8088
WBITT Network MultiTool (with NGINX) - my-test-deployment-684ddfd54c-gqq9t - 10.1.230.242 - HTTP: 8080 , HTTPS: 443 . (Formerly praqma/network-multitool)

/ # curl test-service:80
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
Session ended, resume using 'kubectl attach my-curl-pod -c my-curl-pod -i -t' command when the pod is running
pod "my-curl-pod" deleted

```

</details>

---

###### task2
### Решение задания 2: Создать Deployment и обеспечить старт основного контейнера при выполнении условий

[Файл-манифест для Pod `my-nginxsvc-deploy`](./my-nginxsvc-deploy.yaml)

[Файл-манифест для Service `my-service2`](./my-service2.yaml)

<details>
    <summary> Вывод консоли `kubectl apply` и `kubectl get pods` до и после старта сервиса...  </summary>

```
beatl@Sirius:~/homeworks/K8s/1.3$ kubectl apply -f my-nginxsvc-deploy.yaml
deployment.apps/my-nginxsvc-deployment created

beatl@Sirius:~/homeworks/K8s/1.3$ kubectl get pods
NAME                                      READY   STATUS     RESTARTS   AGE
my-curl-pod                               1/1     Running    0          24m
my-nginxsvc-deployment-564b7885df-5xczw   0/1     Init:0/1   0          8s

beatl@Sirius:~/homeworks/K8s/1.3$ kubectl apply -f my-service2.yaml
service/my-service2 created

beatl@Sirius:~/homeworks/K8s/1.3$ kubectl get pods
NAME                                      READY   STATUS    RESTARTS   AGE
my-curl-pod                               1/1     Running   0          25m
my-nginxsvc-deployment-564b7885df-5xczw   1/1     Running   0          51s

```

</details>

---

###### student
### Исполнитель

Сергей Жуков DevOps-32

---