# Kubernetes の環境構築

minikube を使ってシングルノードの Kubernetes クラスタを構築します。

!!! Warning

    Docker を構築した VM 上に構築するわけではありません。ホスト側(ご自身の端末)で実行してください。


## kubectl のインストール

[https://kubernetes.io/ja/docs/tasks/tools/install-kubectl/](https://kubernetes.io/ja/docs/tasks/tools/install-kubectl/) を参考にインストールしてください。

## minikube のインストール

[https://minikube.sigs.k8s.io/docs/start/](https://minikube.sigs.k8s.io/docs/start/) を参考にインストールしてください。

```shell
$ minikube start

# このような表示が出れば OK
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                               READY   STATUS    RESTARTS        AGE
kube-system   coredns-64897985d-ngvq4            1/1     Running   2 (29d ago)     36d
kube-system   etcd-minikube                      1/1     Running   2 (29d ago)     36d
kube-system   kube-apiserver-minikube            1/1     Running   2 (29d ago)     36d
kube-system   kube-controller-manager-minikube   1/1     Running   2 (29d ago)     36d
kube-system   kube-proxy-mqb5s                   1/1     Running   2 (29d ago)     36d
kube-system   kube-scheduler-minikube            1/1     Running   2 (29d ago)     36d
kube-system   storage-provisioner                1/1     Running   5 (3h40m ago)   36d
```

## Kubernetes クラスタの操作を簡単にするツールのインストール

### kubectx / kubens

https://github.com/ahmetb/kubectx

### stern

https://github.com/wercker/stern

