# Docker の環境構築

VirtualBox や VMWare などの仮想化ソフトウェアを使って Ubuntu 22.04 をゲストOS とした仮想環境を作ってください。  
ここでは Vagrant + VirtualBox を使った方法を紹介しますが、Ubuntu 22.04 をゲスト OS として、[Docker をインストールできていれば](https://docs.docker.com/engine/install/ubuntu/)手段は問いません。

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
