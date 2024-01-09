
---
<img src="Netology.png" height="24px"/>

### Учебная группа DevOps-32

---

## Решение по домашнему заданию 11-microservices-02-principles к занятию «Микросервисы: принципы» 


- [Решение задачи 1: API gateway](#task1) 
- [Решение задачи 2: Брокер сообщений](#task2) 
- [Решение задачи 3: API gateway *](#task3)
- [Исполнитель](#student)


---

###### task1
### Решение задачи 1: API gateway

Cравнительная таблица возможностей различных программных решений.

| Решение            | Маршрутизация | Аутентификация | Терминация HTTPS | Бесплатно/Открыто?                                               |
|--------------------|---------------|----------------|------------------|------------------------------------------------------------------|
| Kong Gateway       | +             | +              | +                | Бесплатно, Apache 2.0                                            |
| Tyk.io             | +             | +              | +                | Бесплатно, MPL                                                   |
| HAProxy            | +             | +              | +                | Бесплатно                                                        |
| Yandex API Gateway | +             | +              | +                | Платно                                                           |
| Azure API Gateway  | +             | +              | +                | Платно                                                           |
| NGINX              | +             | +              | +                | Бесплатно                                                        |
| KrakenD            | +             | +              | +                | Двойное лицензирование, нужные функции частично в платной версии |

Каждое из решений содержит все функции удовлетворяющие условиям задачи. В общем случае подойдет любое.
Но если требуется быстро создать решение для небольшого проекта, то лучше использовать облачные API Gateway, например от Яндекса.
Для локальной реализации наиболее оптимальным будет NGINX - бесплатное решение, великолепная поддержка, множество примеров использования в сети.

---

###### task2
### Решение задачи 2: Брокер сообщений

Cравнительная таблица возможностей различных программных решений.

| Характеристика \ Брокер                               | Kafka | Redis | RabbitMQ | ActiveMQ |
|-------------------------------------------------------|-------|-------|----------|----------|
| Поддержка кластеризации для обеспечения надежности    | +     | +     | +        | +        |
| Хранение сообщений на диске в процессе доставки       | +     | -     | +        | +        |
| Высокая скорость работы                               | +     | +     | +        | -        |
| Поддержка различных форматов сообщений                | +     | +     | +        | +        |
| Разделение прав доступа к различным потокам сообщений | +     | +     | +        | +        |
| Простота эксплуатации                                 | +     | +     | +        | +        |


На мой взгляд лучшими вариантами будут Kafka или RabbitMQ. Окончательное решение будет зависеть от того, что является приоритетом, на какие параметры нужно обратить внимание, а какие параметры можно считать второстепенными. Если требуется максимальная производительность лучше использовать Kafka. При этом RabbitMQ позволяет подписчикам упорядочивать произвольные группы событий.

Kafka — это распределенная очередь с высокой пропускной способностью, созданная для длительного хранения больших объемов данных. Она идеально подходит в тех случаях, где требуется персистентность.

RabbitMQ — давно известный, популярный брокер со множеством функций и возможностей, поддерживающих сложную маршрутизацию. Он способен обеспечивать такую маршрутизацию сообщений при значительном трафике (несколько десятков тысяч сообщений в секунду).


---

###### task3
### Попытка решения задачи 3: API gateway *

К сожалению я не смог в полном объеме решить задачу 3.

Мой вариант решения:

Ссылка на репозиторий с файлами: [11-microservices-02-principles](https://github.com/beatljs/homeworks/tree/11-microservices-02-principles)

Файл `nginx.conf`: [nginx.conf](./gateway/nginx.conf)

Файл `docker-compose`: [docker-compose](./docker-compose.yaml)

<details>
    <summary> Вывод консоли `docker-compose up --build`...  </summary>

```
beatl@Sirius:~/ms$ docker-compose up --build
Pulling storage (minio/minio:latest)...
latest: Pulling from minio/minio
f72461870632: Pull complete
a94a98d27cee: Pull complete
d0230acc7d8e: Pull complete
f834841d28c1: Pull complete
8ae702ff4648: Pull complete
1427ad7391b7: Pull complete
52fd40960e93: Pull complete
Digest: sha256:654e9aeba815c95c85fb2ea72d1a978bce14522e64386c4e541b6b29f4fec069
Status: Downloaded newer image for minio/minio:latest
Pulling createbuckets (minio/mc:)...
latest: Pulling from minio/mc
f72461870632: Already exists
171ed3e79141: Pull complete
ca51c322c1c7: Pull complete
cedff7107927: Pull complete
58b2a1004bc8: Pull complete
e7a4ea262c1b: Pull complete
Digest: sha256:aafc8da473889db6d2e033bf88ba8f66ee8f5a9ca78586eeedb3296bc63e6376
Status: Downloaded newer image for minio/mc:latest
Building uploader
[+] Building 1.1s (10/10) FINISHED                                                                                                                                     docker:default
 => [internal] load build definition from Dockerfile                                                                                                                             0.0s
 => => transferring dockerfile: 144B                                                                                                                                             0.0s
 => [internal] load .dockerignore                                                                                                                                                0.0s
 => => transferring context: 52B                                                                                                                                                 0.0s
 => [internal] load metadata for docker.io/library/node:alpine                                                                                                                   1.0s
 => [internal] load build context                                                                                                                                                0.0s
 => => transferring context: 128B                                                                                                                                                0.0s
 => [1/5] FROM docker.io/library/node:alpine@sha256:82c93cef3d2acbb2557c5fda48214fbc2bf5385edfb4d96d990690d75ddabf7b                                                             0.0s
 => CACHED [2/5] WORKDIR /app                                                                                                                                                    0.0s
 => CACHED [3/5] COPY package*.json ./                                                                                                                                           0.0s
 => CACHED [4/5] RUN npm install                                                                                                                                                 0.0s
 => CACHED [5/5] COPY src ./                                                                                                                                                     0.0s
 => exporting to image                                                                                                                                                           0.0s
 => => exporting layers                                                                                                                                                          0.0s
 => => writing image sha256:a66b66f9bbf149685b565354ac0b01f522c787310af88a7aa8356e1b45bd7e8a                                                                                     0.0s
 => => naming to docker.io/library/ms_uploader                                                                                                                                   0.0s
Building security
[+] Building 1.1s (10/10) FINISHED                                                                                                                                     docker:default
 => [internal] load .dockerignore                                                                                                                                                0.0s
 => => transferring context: 2B                                                                                                                                                  0.0s
 => [internal] load build definition from Dockerfile                                                                                                                             0.0s
 => => transferring dockerfile: 180B                                                                                                                                             0.0s
 => [internal] load metadata for docker.io/library/python:3.9-alpine                                                                                                             1.0s
 => [1/5] FROM docker.io/library/python:3.9-alpine@sha256:5a8aef2661d7c9e8a4c4fc6e79c6da926f3154aac43425264b0548778a3eed61                                                       0.0s
 => [internal] load build context                                                                                                                                                0.0s
 => => transferring context: 93B                                                                                                                                                 0.0s
 => CACHED [2/5] WORKDIR /app                                                                                                                                                    0.0s
 => CACHED [3/5] COPY requirements.txt .                                                                                                                                         0.0s
 => CACHED [4/5] RUN pip install -r requirements.txt                                                                                                                             0.0s
 => CACHED [5/5] COPY src ./                                                                                                                                                     0.0s
 => exporting to image                                                                                                                                                           0.0s
 => => exporting layers                                                                                                                                                          0.0s
 => => writing image sha256:022d993473c54477c0af4a1aaa8c3c99255571b28509b1d2c1e512026445d79a                                                                                     0.0s
 => => naming to docker.io/library/ms_security                                                                                                                                   0.0s
Pulling gateway (nginx:alpine)...
alpine: Pulling from library/nginx
c926b61bad3b: Pull complete
fed54a1dc458: Pull complete
d4735778d47c: Pull complete
8695c106552e: Pull complete
dffa16519b51: Pull complete
9e50a0e580b1: Pull complete
5ddd532e9cec: Pull complete
fe117667dcd0: Pull complete
Digest: sha256:a59278fd22a9d411121e190b8cec8aa57b306aa3332459197777583beb728f59
Status: Downloaded newer image for nginx:alpine
Creating ms_storage_1  ... done
Creating ms_security_1 ... done
Creating ms_createbuckets_1 ... done
Creating ms_uploader_1      ... done
Creating ms_gateway_1       ... done
Attaching to ms_security_1, ms_storage_1, ms_createbuckets_1, ms_uploader_1, ms_gateway_1
createbuckets_1  | Added `storage` successfully.
createbuckets_1  | Bucket created successfully `storage/data`.
security_1       |  * Serving Flask app 'server'
security_1       |  * Debug mode: off
createbuckets_1  | mc: Please use 'mc anonymous'
gateway_1        | /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
gateway_1        | /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
security_1       | WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
security_1       |  * Running on all addresses (0.0.0.0)
security_1       |  * Running on http://127.0.0.1:3000
security_1       |  * Running on http://172.21.0.3:3000
security_1       | Press CTRL+C to quit
storage_1        | MinIO Object Storage Server
storage_1        | Copyright: 2015-2024 MinIO, Inc.
storage_1        | License: GNU AGPLv3 <https://www.gnu.org/licenses/agpl-3.0.html>
storage_1        | Version: RELEASE.2024-01-05T22-17-24Z (go1.21.5 linux/amd64)
storage_1        | 
storage_1        | Status:         1 Online, 0 Offline. 
storage_1        | S3-API: http://172.21.0.2:9000  http://127.0.0.1:9000 
gateway_1        | /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
gateway_1        | 10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
uploader_1       | S3: storage:9000 data
ms_createbuckets_1 exited with code 0
uploader_1       | Listening on port 3000
uploader_1       | (node:1) [DEP0152] DeprecationWarning: Custom PerformanceEntry accessors are deprecated. Please use the detail property.
uploader_1       | (Use `node --trace-deprecation ...` to show where the warning was created)
storage_1        | Console: http://172.21.0.2:9090 http://127.0.0.1:9090 
storage_1        | 
storage_1        | Documentation: https://min.io/docs/minio/linux/index.html
storage_1        | Warning: The standard parity is set to 0. This can lead to data loss.
gateway_1        | 10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
gateway_1        | /docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
gateway_1        | /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
gateway_1        | /docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
gateway_1        | /docker-entrypoint.sh: Configuration complete; ready for start up
```

</details>

<details>
    <summary> Вывод команды `docker ps -a`...  </summary>

```
beatl@Sirius:~/ms$ docker ps -a
CONTAINER ID   IMAGE                COMMAND                  CREATED          STATUS                      PORTS                                           NAMES
ec7a59dbb647   nginx:alpine         "/docker-entrypoint.…"   19 minutes ago   Up 11 minutes               80/tcp, 0.0.0.0:80->8080/tcp, :::80->8080/tcp   ms_gateway_1
aff99fe2547b   ms_uploader          "docker-entrypoint.s…"   19 minutes ago   Up 11 minutes               3000/tcp                                        ms_uploader_1
4540766d91db   minio/mc             "/bin/sh -c '       …"   19 minutes ago   Exited (0) 11 minutes ago                                                   ms_createbuckets_1
3cbdbda3a752   ms_security          "python ./server.py"     19 minutes ago   Up 11 minutes               3000/tcp                                        ms_security_1
93b11a9a3319   minio/minio:latest   "/usr/bin/docker-ent…"   19 minutes ago   Up 11 minutes (unhealthy)   9000/tcp                                        ms_storage_1
```

</details>

<details>
    <summary> Вывод консоли получения токена:...  </summary>

```
beatl@Sirius:~/ms$ curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost/token
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I
```

</details>

<details>
    <summary> Вывод консоли загрузки картинки:...  </summary>

```
beatl@Sirius:~/ms$ curl -X POST -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I' -H 'Content-Type: octet/stream' --data-binary @1.jpg http://localhost/upload
{"filename":"ba7fda81-3e11-4c6a-a209-b5b427483cf8.jpg"}
```

</details>

Вроде все хорошо, но если зайти в web-консоль minio - там кроме созданного букета ничего нет.

Соответственно:

<details>
    <summary> Вывод консоли при попытке скачать картинку:...  </summary>

```
beatl@Sirius:~/ms$ curl -X GET http://localhost/images/ba7fda81-3e11-4c6a-a209-b5b427483cf8.jpg
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.25.3</center>
</body>
</html>

```
</details>

Пробовал множество разных настроек, вплоть до использования других версий minio.

<details>
    <summary> Максимальный результат которого удалось достичь...  </summary>

```
curl -X GET http://172.21.0.2:9000/storage/data/6cc2b4c2-df13-464c-b8a9-fd4bb29ffeea.jpg
<?xml version="1.0" encoding="UTF-8"?>
<Error><Code>AccessDenied</Code><Message>Access Denied.</Message><Key>data/6cc2b4c2-df13-464c-b8a9-fd4bb29ffeea.jpg</Key><BucketName>storage</BucketName><Resource>/storage/data/6cc2b4c2-df13-464c-b8a9-fd4bb29ffeea.jpg</Resource><RequestId>17A7D6C6397F07D8</RequestId><HostId>dd9025bab4ad464b049177c95eb6ebf374d3b3fd1af9251148b658df7ac2e3e8</HostId></Error>

```
</details>

Добавление в GET запрос заголовка с авторизацией дает такой-же результат.

Поначалу казалось, что решение лежит на поверхности, но эксперименты были безуспешными, время ушло - поэтому отправляю неполное решение.

Наверняка надо копать глубже, может что не так в исходниках `uploader` ...

---

###### Student 
### Исполнитель

Сергей Жуков DevOps-32

---
