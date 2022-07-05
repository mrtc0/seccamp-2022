# Docker の環境構築

VirtualBox や VMWare などの仮想化ソフトウェアを使って Ubuntu 22.04 をゲストOS とした仮想環境を作ってください。  
Ubuntu 22.04 をゲスト OS として、[Docker をインストールできていれば](https://docs.docker.com/engine/install/ubuntu/)手段は問いません。

## Vagrant + VirtualBox を使った方法

## 1. VirtualBox をインストールする

[VirtualBox のインストーラーをダウンロードし](https://www.oracle.com/jp/virtualization/technologies/vm/downloads/virtualbox-downloads.html)、インストールしてください。

## 2. Vagrant をインストールする

[Vagrant をダウンロード](https://www.vagrantup.com/downloads)し、インストールしてください。

## 3. VM を起動する

リポジトリを clone して `src/pre/docker` ディレクトリに移動し、`vagrant up` を実行します。  

```shell
$ git clone git@github.com:mrtc0/seccamp-2022.git
$ cd seccamp-2022/src/pre/docker
$ vagrant up
```

## 4. VM にログインする

`vagrant ssh` を実行して VM の中にログインできることを確認してください。

```shell
$ vagrant ssh
```

## 5. Serverspec を実行する(optional)

正しくセットアップされているかどうか Serverspec でテストできます。

```shell
$ gem i serverspec
$ rake spec
```

## 6. VM のシャットダウン

```shell
$ vagrant halt
```

# (M1 Mac 向け)Lima を使った方法

M1 Mac を使っている場合は [Lima](https://github.com/lima-vm/lima) でセットアップします。

## 1. Lima のインストール

```shell
$ brew install lima
```

## 2. リポジトリの clone

```shell
$ git clone git@github.com:mrtc0/seccamp-2022.git
$ cd seccamp-2022
```

## 3. VM の作成と起動

ここでは `docker-x86_64` という名前をつけていますが、なんでも構いません。

```shell
$ limactl start --name docker-x86_64 src/pre/docker/default.yaml
? Creating an instance "docker-x86_64"  [Use arrows to move, type to filter]
> Proceed with the current configuration # これを選ぶ
  Open an editor to review or modify the current configuration
  Choose another example (docker, podman, archlinux, fedora, ...)
  Exit
...

```

## 4. VM にログイン

```shell
$ limactl shell docker-x86_64 bash
```

## 5. VM のシャットダウン

```shell
$ limactl stop docker-x86_64
```
