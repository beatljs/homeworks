
---
<img src="../Netology.png" height="24px"/>

### Учебная группа DevOps-32

---

## Решение по домашнему заданию к занятию «Хранение в K8s. Часть 1» 

Домашнее задание выполнялось на локальной машине с ОС Ubuntu 22.04.3 LTS и MicroK8S

- [Решение задания 1: Создать Deployment приложения, состоящего из двух контейнеров и обменивающихся данными.](#task1) 
- [Решение задания 2: Создать DaemonSet приложения, которое может прочитать логи ноды.](#task2) 
- [Исполнитель](#student)


---

###### task1
### Решение задания 1: Создать Deployment приложения, состоящего из двух контейнеров и обменивающихся данными.

[Файл-манифест Deployment из контейнеров `busybox` и `multitool`](./my-test-vol-deploy.yaml)

<details>
    <summary> Вывод консоли с чтением контейнером `multitool` обновляющегося файла...  </summary>

```
beatl@Sirius:~/homeworks/K8s/2.1$ kaf my-test-vol-deploy.yaml
deployment.apps/my-test-vol-deployment created

beatl@Sirius:~/homeworks/K8s/2.1$ kgp
NAME                                      READY   STATUS    RESTARTS   AGE
my-test-vol-deployment-7c56c849bc-qqjsb   2/2     Running   0          10s

beatl@Sirius:~/homeworks/K8s/2.1$ k logs -f my-test-vol-deployment-7c56c849bc-qqjsb -c multitool
Value is: 2
Value is: 4
Value is: 6
Value is: 8
Value is: 10
Value is: 12
Value is: 14
Value is: 16
Value is: 18
Value is: 20
Value is: 22
Value is: 24
Value is: 26
Value is: 28
Value is: 30
Value is: 32
Value is: 34
Value is: 36
Value is: 38
Value is: 40
Value is: 42
Value is: 44
Value is: 46
Value is: 48
Value is: 50
Value is: 52
Value is: 54
Value is: 56
Value is: 58
Value is: 60
Value is: 62
Value is: 64
Value is: 66
Value is: 68
Value is: 70
Value is: 72
Value is: 74
Value is: 76
Value is: 78
Value is: 80
Value is: 82
Value is: 84
Value is: 86
Value is: 88
Value is: 90
Value is: 92
Value is: 94
Value is: 96
Value is: 98
Value is: 100
Value is: 102
Value is: 104
Value is: 106
Value is: 108
Value is: 110
^C
```

</details>

---

###### task2
### Решение задания 2: Создать DaemonSet приложения, которое может прочитать логи ноды.

[Файл-манифест для DaemonSet](./my-test-ds-deploy.yaml)

<details>
    <summary> Вывод консоли при создании DaemonSet...  </summary>

```
beatl@Sirius:~/homeworks/K8s/2.1$ kaf my-test-ds-deploy.yaml
daemonset.apps/my-test-ds-deployment created

beatl@Sirius:~/homeworks/K8s/2.1$ k get ds
NAME                    DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
my-test-ds-deployment   1         1         1       1            1           <none>          12s

beatl@Sirius:~/homeworks/K8s/2.1$ k describe ds
Name:           my-test-ds-deployment
Selector:       app=my-ds1
Node-Selector:  <none>
Labels:         app=my-ds1
Annotations:    deprecated.daemonset.template.generation: 1
Desired Number of Nodes Scheduled: 1
Current Number of Nodes Scheduled: 1
Number of Nodes Scheduled with Up-to-date Pods: 1
Number of Nodes Scheduled with Available Pods: 1
Number of Nodes Misscheduled: 0
Pods Status:  1 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=my-ds1
  Containers:
   multitool:
    Image:        wbitt/network-multitool
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:
      /var/log/ from my-ds-vol (ro)
  Volumes:
   my-ds-vol:
    Type:          HostPath (bare host directory volume)
    Path:          /var/log/
    HostPathType:  
Events:
  Type    Reason            Age   From                  Message
  ----    ------            ----  ----                  -------
  Normal  SuccessfulCreate  31s   daemonset-controller  Created pod: my-test-ds-deployment-kwzm2
```

</details>

<details>
    <summary> Вывод консоли при чтении syslog ноды изнутри пода...  </summary>

```
beatl@Sirius:~/homeworks/K8s/2.1$ k exec my-test-ds-deployment-kwzm2 -it -- bash

my-test-ds-deployment-kwzm2:/# tail /var/log/syslog
Feb 19 10:58:45 Sirius microk8s.daemon-kubelite[6055]: I0219 10:58:45.320206    6055 handler.go:232] Adding GroupVersion crd.projectcalico.org v1 to ResourceManager
Feb 19 10:58:45 Sirius microk8s.daemon-kubelite[6055]: I0219 10:58:45.320376    6055 handler.go:232] Adding GroupVersion crd.projectcalico.org v1 to ResourceManager
Feb 19 10:58:45 Sirius microk8s.daemon-kubelite[6055]: I0219 10:58:45.370269    6055 handler.go:232] Adding GroupVersion metrics.k8s.io v1beta1 to ResourceManager
Feb 19 10:59:05 Sirius DC.desktop[92482]: TMountWatcher: DoMountEvent
Feb 19 10:59:32 Sirius DC.desktop[92482]: message repeated 17 times: [ TMountWatcher: DoMountEvent]
Feb 19 10:59:45 Sirius microk8s.daemon-kubelite[6055]: I0219 10:59:45.297539    6055 handler.go:232] Adding GroupVersion metrics.k8s.io v1beta1 to ResourceManager
Feb 19 10:59:53 Sirius DC.desktop[92482]: TMountWatcher: DoMountEvent
Feb 19 11:00:35 Sirius DC.desktop[92482]: message repeated 26 times: [ TMountWatcher: DoMountEvent]
Feb 19 11:00:45 Sirius microk8s.daemon-kubelite[6055]: I0219 11:00:45.296752    6055 handler.go:232] Adding GroupVersion metrics.k8s.io v1beta1 to ResourceManager
Feb 19 11:01:02 Sirius DC.desktop[92482]: TMountWatcher: DoMountEvent

my-test-ds-deployment-kwzm2:/# 
```

</details>

---

###### student
### Исполнитель

Сергей Жуков DevOps-32

---