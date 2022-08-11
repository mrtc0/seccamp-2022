# Kubernetes Exercices

## Setup

受講生の namespace と kubeconfig の生成をします。

```shell
$ ./setup-namespace-and-sa.sh*
```

## Istio のデプロイ

https://istio.io/latest/docs/setup/install/helm/

```shell
$ kubectl create namespace istio-system
$ helm install istio-base istio/base -n istio-system
$ helm install istiod istio/istiod -n istio-system --wait
```

## 演習用アプリケーションのデプロイ

受講生の Namespace に演習用環境を構築する

```shell
$ ./setup-exercise.sh
```


