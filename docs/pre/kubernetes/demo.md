# Kuberntes 101

ここでは Kubernetes における主要なリソースの作成方法について紹介します。  
細かい説明は省略していますので、適宜リソースについて調べながら進めてください。  
また、manifest の内容も適宜確認してください。

## Namespace を作成する

```shell
$ kubectl create namespace sandbox
$ kubens sandbox

$ kubectl get pods
No resources found in sandbox namespace.
```

## Pod を作成する

nginx の Pod を作成します。`Running` になれば動いています。

```shell
$ kubectl apply -f pod.yaml

$ kubectl get pods
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          89s
```

`kubectl port-forward` で Pod への接続を確立し、curl で nginx Pod にリクエストを送信します。

```shell
$ kubectl port-forward pod/nginx 12345:80
Forwarding from 127.0.0.1:12345 -> 80
Forwarding from [::1]:12345 -> 80

$ curl -I localhost:12345
HTTP/1.1 200 OK
Server: nginx/1.23.0
```

`kubectl logs` でコンテナのログを確認できます。

```
$ kubectl logs nginx
...
2022/07/03 09:41:19 [notice] 1#1: start worker process 33
2022/07/03 09:41:19 [notice] 1#1: start worker process 34
127.0.0.1 - - [03/Jul/2022:09:44:06 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.81.0" "-"
```

Pod を削除しておきます。

```shell
$ kubectl delete -f pod.yaml
```

## Deployment を作成する

nginx の Deployment を作成します。`replicas` に `2` を設定しているので Pod は2つ起動します。

```shell
$ kubectl apply -f deployment.yaml

$ kubectl get deployment
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   2/2     2            2           7s

$ kubectl get pods
NAME                    READY   STATUS    RESTARTS   AGE
nginx-8d545c96d-kgmmv   1/1     Running   0          10s
nginx-8d545c96d-nhr6n   1/1     Running   0          10s
```

Pod を1つ選び、削除します。

```shell
$ kubectl delete pod nginx-8d545c96d-kgmmv
pod "nginx-8d545c96d-kgmmv" deleted
```

Pod を削除しても、自動で新しい Pod が起動します。

```shell
$ kubectl get pods
NAME                    READY   STATUS    RESTARTS   AGE
nginx-8d545c96d-nhr6n   1/1     Running   0          82s
nginx-8d545c96d-s62c6   1/1     Running   0          4s   👈
```

`replicas` を5に変更すると Pod は5つ起動します。

```shell
$ kubectl patch deployment nginx -p '{"spec":{"replicas":5}}'
deployment.apps/nginx patched

$ kubectl get pods
NAME                    READY   STATUS              RESTARTS   AGE
nginx-8d545c96d-2929h   0/1     ContainerCreating   0          3s
nginx-8d545c96d-l8w6l   0/1     ContainerCreating   0          3s
nginx-8d545c96d-mzks5   0/1     ContainerCreating   0          3s
nginx-8d545c96d-nhr6n   1/1     Running             0          4m1s
nginx-8d545c96d-s62c6   1/1     Running             0          2m43s
```

Deployment を削除しておきます。

```shell
$ kubectl delete -f deployment.yml
deployment.apps "nginx" deleted
```

## Service を作成する

```shell
$ kubectl apply -f deployment.yml
$ kubectl apply -f service.yaml

$ kubectl get pods
NAME                    READY   STATUS    RESTARTS   AGE
nginx-8d545c96d-fpn88   1/1     Running   0          7s
nginx-8d545c96d-jpnmj   1/1     Running   0          7s

$ kubectl get service
NAME    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
nginx   ClusterIP   10.101.128.111   <none>        80/TCP    7s
```

Service は `<service name>.<namespace name>.svc.cluster.local` で Pod から名前解決できます。

```shell
$ kubectl run --rm -it --image=ubuntu:22.04 bash
If you don't see a command prompt, try pressing enter.
root@bash:/# apt update && apt install -y curl
root@bash:/# curl nginx.sandbox.svc.cluster.local
<!DOCTYPE html>
<html>
...
```

Pod から何度か curl でリクエストを送信し、Service から各 Pod にリクエストが振り分けられていることを確認します。

```shell
$ stern nginx
...
nginx-8d545c96d-fpn88 nginx 172.17.0.1 - - [03/Jul/2022:10:04:17 +0000] "GET / HTTP/1.1" 200 615 "-" "curl/7.81.0" "-"
nginx-8d545c96d-jpnmj nginx 172.17.0.1 - - [03/Jul/2022:10:04:18 +0000] "GET / HTTP/1.1" 200 615 "-" "curl/7.81.0" "-"
nginx-8d545c96d-fpn88 nginx 172.17.0.1 - - [03/Jul/2022:10:04:18 +0000] "GET / HTTP/1.1" 200 615 "-" "curl/7.81.0" "-"
nginx-8d545c96d-fpn88 nginx 172.17.0.1 - - [03/Jul/2022:10:04:19 +0000] "GET / HTTP/1.1" 200 615 "-" "curl/7.81.0" "-"
nginx-8d545c96d-jpnmj nginx 172.17.0.1 - - [03/Jul/2022:10:04:20 +0000] "GET / HTTP/1.1" 200 615 "-" "curl/7.81.0" "-"
nginx-8d545c96d-fpn88 nginx 172.17.0.1 - - [03/Jul/2022:10:04:20 +0000] "GET / HTTP/1.1" 200 615 "-" "curl/7.81.0" "-"
```

Service と Deployment を削除しておきます。

```shell
$ kubectl delete -f service.yaml
$ kubectl delete -f deployment.yaml
```

## Ingress を作成する

最初に minikube の NGINX Ingress コントローラーを有効化します。

```shell
$ minikube addons enable ingress
```

Deployment, Service, Ingress をそれぞれ作成します。

```shell
$ kubectl apply -f deployment.yaml
$ kubectl apply -f service.yaml
$ kubectl apply -f ingress.yaml
```

しばらくすると ingress に IP アドレスが割り当てられます。

```shell
$ kubectl get ingress
NAME    CLASS   HOSTS         ADDRESS          PORTS   AGE
nginx   nginx   nginx.local   192.168.59.100   80      27s
```

Ingress 経由で Pod にリクエストが届くことを確認します。

```shell
$ curl -H 'Host: nginx.local' http://192.168.59.100
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
```

リソースを削除しておきます。

```shell
$ kubectl delete -f deployment.yaml
$ kubectl delete -f service.yaml
$ kubectl delete -f ingress.yaml
```

## データの永続化と Secrets リソース

ここでは MySQL コンテナを起動します。MySQL コンテナを起動するにあたり、以下のことを考慮する必要があります。

- MySQL root ユーザーのパスワードの設定
- データの永続化

まず、パスワードの設定についてですが、Kuberntes ではクレデンシャルなどの機密情報を Secrets リソースで扱うのが一般的です。

```shell
$ kubectl create secret generic mysql-pass --from-literal=pass=MySQLP@ssW0rd --dry-run -o yaml > secret.yaml
$ cat secret.yaml
apiVersion: v1
data:
  pass: TXlTUUxQQHNzVzByZA==
kind: Secret
metadata:
  creationTimestamp: null
  name: mysql-pass

$ kubectl apply -f secret.yaml

$ kubectl get secrets
NAME                  TYPE                                  DATA   AGE
default-token-cn86n   kubernetes.io/service-account-token   3      53m
mysql-pass            Opaque                                1      6m34s
```

Secret は Pod に環境変数として設定したり、ファイルとしてマウントすることができます。今回は `MYSQL_ROOT_PASSWORD` 環境変数として設定します。  
`mysql` イメージは起動時に `MYSQL_ROOT_PASSWORD` 環境構築を root ユーザーのパスワードとして設定します。

```shell
$ cat deployment.yaml
...
      containers:
      - image: mysql:8
        name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-pass
              key: pass
```

続いてデータの永続化についてですが、Kuberntes クラスタでは PV(Persistent Volume) を使ってデータを永続化することができます。  
Pod から PV を使用するには PVC(Persistent Volume Claim) と呼ばれる「Pod から PV を使うための条件」を記したリソースを別途作成します。  

```shell
$ cat pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi

$ kubectl apply -f pvc.yaml

$ kubectl get pvc
NAME        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mysql-pvc   Bound    pvc-c2311ff5-d7ab-404d-aeb3-4d4e373902f2   1Gi        RWO            standard       2s
```

Pod に PVC のデータをマウントするには `volumes` で作成した PVC を指定し、`volumeMounts` にマウント先を指定します。

```yaml
$ cat deployment.yaml
...
      containers:
      - image: mysql:8
        name: mysql
        ...
        volumeMounts:
        - name: mysql-volume
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-volume
        persistentVolumeClaim:
          claimName: mysql-pvc
```

Secrets と PVC が作成できたら Deployment を作成します。

```shell
$ kubectl apply -f deployment.yaml
$ kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
mysql-849d9779bb-2cs4b   1/1     Running   0          30s
```

パスワード `MySQLP@ssW0rd` でログインできることを確認します。

```shell
$ kubectl exec -it mysql-849d9779bb-2cs4b -- mysql -u root -p
Enter Password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 8.0.29 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
```

テスト用データベースを作成し、Pod を削除します。

```shell
mysql> create database test;
Query OK, 1 row affected (0.01 sec)
mysql> exit
Bye

$ kubectl scale deployment mysql --replicas=0
deployment.apps/mysql scaled

$ kubectl get pods
No resources found in sandbox namespace.

$ kubectl scale deployment mysql --replicas=1
deployment.apps/mysql scaled

$ kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
mysql-849d9779bb-lfzw8   1/1     Running   0          4s
```

再び MySQL に接続し、`test` データベースが永続化していることを確認します。

```shell
$ kubectl exec -it mysql-849d9779bb-lfzw8 -- mysql -u root -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
Server version: 8.0.29 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test               |
+--------------------+
5 rows in set (0.00 sec)
```

リソースを削除しておきます。

```shell
$ kubectl delete -Rf .
deployment.apps "mysql" deleted
persistentvolumeclaim "mysql-pvc" deleted
secret "mysql-pass" deleted
```

## その他のリソース

### DaemonSet

Kubernetes は複数のノードから構成されるクラスタとして動作することが期待されています。今回はシングルノードでの構成ですが、通常は3ノード以上から構成されることがほとんどです。  
DaemonSet は Pod をすべてのノードに配置するためのリソースです。これはノードを監視するようなソフトウェアを動かす際に使用されます。

### ConfigMap

ソフトウェアの設定ファイルなどを Pod にマウントするために使用されるリソースです。コンテナイメージをビルドしたりしなくても ConfigMap を更新するだけで、新しくソフトウェアを構成することができます。

