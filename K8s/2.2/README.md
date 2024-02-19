
---
<img src="../Netology.png" height="24px"/>

### Учебная группа DevOps-32

---

## Решение по домашнему заданию к занятию «Хранение в K8s. Часть 2» 

В тестовой среде Kubernetes нужно создать PV и продемострировать запись и хранение файлов.

Домашнее задание выполнялось на локальной машине с ОС Ubuntu 22.04.3 LTS и MicroK8S

- [Решение задания 1: Создать Deployment приложения, использующего локальный PV, созданный вручную.](#task1) 
- [Решение задания 2: Создать Deployment приложения, которое может хранить файлы на NFS с динамическим созданием PV.](#task2) 
- [Исполнитель](#student)


---

###### task1
### Решение задания 1: Создать Deployment приложения, использующего локальный PV, созданный вручную.

[Файл-манифест Deployment из контейнеров `busybox` и `multitool`](./my-test-pv-deploy.yaml)

[Файл-манифест `PersitentVolume`](./my-test-pv.yaml)

[Файл-манифест `PersitentVolumeClaim`](./my-test-pvc.yaml)

Создание PersistentVolume:

```
beatl@Sirius:~/homeworks/K8s/2.2$ kaf my-test-pv.yaml
persistentvolume/my-local-volume created

beatl@Sirius:~/homeworks/K8s/2.2$ k get pv my-local-volume
NAME                            CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                                                  STORAGECLASS    REASON   AGE
my-local-volume                 1Gi        RWO            Delete           Available                                                          local-storage            12s

beatl@Sirius:~/homeworks/K8s/2.2$ k describe pv my-local-volume
Name:              my-local-volume
Labels:            <none>
Annotations:       <none>
Finalizers:        [kubernetes.io/pv-protection]
StorageClass:      local-storage
Status:            Available
Claim:             
Reclaim Policy:    Delete
Access Modes:      RWO
VolumeMode:        Filesystem
Capacity:          1Gi
Node Affinity:     
  Required Terms:  
    Term 0:        kubernetes.io/hostname in [sirius]
Message:           
Source:
    Type:  LocalVolume (a persistent volume backed by local storage on a node)
    Path:  /tmp/test-pv
Events:    <none>
```

Создание PersistentVolumeClaim:

```
beatl@Sirius:~/homeworks/K8s/2.2$ kaf my-test-pvc.yaml
persistentvolumeclaim/my-test-pvc created

beatl@Sirius:~/homeworks/K8s/2.2$ k get pvc
NAME          STATUS   VOLUME            CAPACITY   ACCESS MODES   STORAGECLASS    AGE
my-test-pvc   Bound    my-local-volume   1Gi        RWO            local-storage   3s

beatl@Sirius:~/homeworks/K8s/2.2$ k describe pvc
Name:          my-test-pvc
Namespace:     lesson2-2
StorageClass:  local-storage
Status:        Bound
Volume:        my-local-volume
Labels:        <none>
Annotations:   pv.kubernetes.io/bind-completed: yes
               pv.kubernetes.io/bound-by-controller: yes
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      1Gi
Access Modes:  RWO
VolumeMode:    Filesystem
Used By:       <none>
Events:        <none>
```


<details>
    <summary> Вывод консоли с Deployment `my-test-pv-deployment`...  </summary>

```
beatl@Sirius:~/homeworks/K8s/2.2$ kaf my-test-pv-deploy.yaml
deployment.apps/my-test-pv-deployment created

beatl@Sirius:~/homeworks/K8s/2.2$ kgp
NAME                                     READY   STATUS    RESTARTS   AGE
my-test-pv-deployment-5b5779db8b-6h4ld   2/2     Running   0          10m

beatl@Sirius:~/homeworks/K8s/2.2$ k describe pods 
Name:             my-test-pv-deployment-5b5779db8b-6h4ld
Namespace:        lesson2-2
Priority:         0
Service Account:  default
Node:             sirius/192.168.0.45
Start Time:       Mon, 19 Feb 2024 13:50:44 +0300
Labels:           app=my-vol2
                  pod-template-hash=5b5779db8b
Annotations:      cni.projectcalico.org/containerID: dfb149c9505f6291401867408a1b1ca15c7d5334163bfaa821facb3ac65b8070
                  cni.projectcalico.org/podIP: 10.1.230.219/32
                  cni.projectcalico.org/podIPs: 10.1.230.219/32
Status:           Running
IP:               10.1.230.219
IPs:
  IP:           10.1.230.219
Controlled By:  ReplicaSet/my-test-pv-deployment-5b5779db8b
Containers:
  busybox:
    Container ID:  containerd://96548937c30e9fbfe0d8e771dc6100854fcd4df114fd0e3a37731c76a5781d1d
    Image:         busybox
    Image ID:      docker.io/library/busybox@sha256:6d9ac9237a84afe1516540f40a0fafdc86859b2141954b4d643af7066d598b74
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      v=1; while true; do echo Value is: $v > /output/my-test-file.txt; v=$(($v+1)); sleep 5; done;
    State:          Running
      Started:      Mon, 19 Feb 2024 14:01:02 +0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /output from my-test-pv-vol (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-hzr6s (ro)
  multitool:
    Container ID:  containerd://4b8a069745560e8d8b3d6b844a586edfc5f0e84b5f9235cfdc2959dfda748f64
    Image:         wbitt/network-multitool
    Image ID:      docker.io/wbitt/network-multitool@sha256:d1137e87af76ee15cd0b3d4c7e2fcd111ffbd510ccd0af076fc98dddfc50a735
    Port:          <none>
    Host Port:     <none>
    Command:
      sh
      -c
      while true; do cat /input/my-test-file.txt; sleep 5; done;
    State:          Running
      Started:      Mon, 19 Feb 2024 14:01:03 +0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /input from my-test-pv-vol (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-hzr6s (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  my-test-pv-vol:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  my-test-pvc
    ReadOnly:   false
  kube-api-access-hzr6s:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason       Age                   From     Message
  ----     ------       ----                  ----     -------
  Normal   Pulling      28s                   kubelet  Pulling image "busybox"
  Normal   Pulled       27s                   kubelet  Successfully pulled image "busybox" in 1.197s (1.197s including waiting)
  Normal   Created      27s                   kubelet  Created container busybox
  Normal   Started      27s                   kubelet  Started container busybox
  Normal   Pulling      27s                   kubelet  Pulling image "wbitt/network-multitool"
  Normal   Pulled       26s                   kubelet  Successfully pulled image "wbitt/network-multitool" in 996ms (996ms including waiting)
  Normal   Created      26s                   kubelet  Created container multitool
  Normal   Started      26s                   kubelet  Started container multitool
```

</details>

<details>
    <summary> Вывод консоли с чтением контейнером `multitool` обновляющегося файла...  </summary>

```
beatl@Sirius:~/homeworks/K8s/2.2$ k logs my-test-pv-deployment-5b5779db8b-6h4ld -c multitool
Value is: 1
Value is: 2
Value is: 3
Value is: 4
Value is: 5
Value is: 6
Value is: 7
Value is: 8
Value is: 9
Value is: 10
Value is: 11
Value is: 12
Value is: 13
Value is: 14
Value is: 15
Value is: 16
Value is: 17
Value is: 18
Value is: 19
Value is: 20
Value is: 21
Value is: 22
Value is: 23
```

</details>

Удаляем PVC и Deployment:

```
beatl@Sirius:~/homeworks/K8s/2.2$ k delete deploy my-test-pv-deployment
deployment.apps "my-test-pv-deployment" deleted

beatl@Sirius:~/homeworks/K8s/2.2$ k delete pvc my-test-pvc
persistentvolumeclaim "my-test-pvc" deleted
```

Состояние PV после удаления PVC и Deployment

```
beatl@Sirius:~/homeworks/K8s/2.2$ k get pv my-local-volume
NAME                            CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                                  STORAGECLASS    REASON   AGE
my-local-volume                 1Gi        RWO            Delete           Failed   lesson2-2/my-test-pvc                                  local-storage            38m
```

Статус изменился с `Bound` на `Failed`, по причине пропадания связки через PVC.

Файл остался на месте:

```
beatl@Sirius:~/homeworks/K8s/2.2$ ls -la /tmp/test-pv
итого 12
drwxrwxr-x  2 beatl beatl 4096 фев 19 14:01 .
drwxrwxrwt 25 root  root  4096 фев 19 14:09 ..
-rw-r--r--  1 root  root    13 фев 19 14:07 my-test-file.txt

beatl@Sirius:~/homeworks/K8s/2.2$ cat /tmp/test-pv/my-test-file.txt
Value is: 80
```

Удаляем PV:

```
beatl@Sirius:~/homeworks/K8s/2.2$ k delete pv my-local-volume
persistentvolume "my-local-volume" deleted
```

Файл все равно не удаляется, несмотря на `ReclaimPolicy: Delete` ввиду того, что Delete не работает для local-storage.

Note: The local PersistentVolume requires manual cleanup and deletion by the user if the external static provisioner is not used to manage the volume lifecycle.

```
beatl@Sirius:~/homeworks/K8s/2.2$ ls -la /tmp/test-pv
итого 12
drwxrwxr-x  2 beatl beatl 4096 фев 19 14:01 .
drwxrwxrwt 25 root  root  4096 фев 19 14:12 ..
-rw-r--r--  1 root  root    13 фев 19 14:07 my-test-file.txt

beatl@Sirius:~/homeworks/K8s/2.2$ cat /tmp/test-pv/my-test-file.txt
Value is: 80
```

---

###### task2
### Решение задания 2: Создать Deployment приложения, которое может хранить файлы на NFS с динамическим созданием PV.

Проверка наличия StorageClass `nfs`:

```
beatl@Sirius:~/homeworks/K8s/2.2$ k get sc
NAME   PROVISIONER                            RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs    cluster.local/nfs-server-provisioner   Delete          Immediate           true                   5d20h
```

[Файл-манифест для Deployment](./my-dyn-pv-deploy.yaml)

[Файл-манифест для PVC](./my-dynamic-pvc.yaml)


<details>
    <summary> Вывод консоли при создании Deployment и PVC...  </summary>

```
beatl@Sirius:~/homeworks/K8s/2.2$ kaf my-dyn-pv-deploy.yaml
deployment.apps/my-dyn-pv-deployment created

beatl@Sirius:~/homeworks/K8s/2.2$ kgp
NAME                                    READY   STATUS    RESTARTS   AGE
my-dyn-pv-deployment-645cbc989-c75cw   0/1     Pending   0          5s

beatl@Sirius:~/homeworks/K8s/2.2$ kaf my-dynamic-pvc.yaml
persistentvolumeclaim/my-dynamic-pvc created

beatl@Sirius:~/homeworks/K8s/2.2$ kgp
NAME                                    READY   STATUS              RESTARTS   AGE
my-dyn-pv-deployment-645cbc989-c75cw   0/1     ContainerCreating   0          57s

beatl@Sirius:~/homeworks/K8s/2.2$ kgp
NAME                                    READY   STATUS    RESTARTS   AGE
my-dyn-pv-deployment-645cbc989-c75cw   1/1     Running   0          68s
```

</details>

Как видно из вывода консоли Pod находится в состоянии `Pending`, пока не выполнили `apply PVC`.

После Pod переходит в состояние `Running`.

Проверяем наличие динамически созданного PV:

```
beatl@Sirius:~/homeworks/K8s/2.2$ k get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                                  STORAGECLASS   REASON   AGE
data-nfs-server-provisioner-0              1Gi        RWO            Retain           Bound    nfs-server-provisioner/data-nfs-server-provisioner-0                           5d20h
pvc-d5c761a1-d67f-41ef-bbc3-f1d4ece2fac0   2Gi        RWO            Delete           Bound    lesson2-2/my-dynamic-pvc                               nfs                     3m21s
```

Проверяем возможность чтения и записи файла изнутри пода:

```
beatl@Sirius:~/homeworks/K8s/2.2$ k exec my-dyn-pv-deployment-645cbc989-c75cw -it -- bash

my-dyn-pv-deployment-645cbc989-c75cw:/# mkdir test

my-dyn-pv-deployment-645cbc989-c75cw:/# cd test

my-dyn-pv-deployment-645cbc989-c75cw:/test# echo Try write to file > test-file.txt

my-dyn-pv-deployment-645cbc989-c75cw:/test# cat test-file.txt
Try write to file

my-dyn-pv-deployment-645cbc989-c75cw:/test# exit
exit
```

---

###### student
### Исполнитель

Сергей Жуков DevOps-32

---