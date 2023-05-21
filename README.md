# 描述

添加代理的镜像, 容器内部可以访问外网

## 使用说明

构建镜像,配置自己的代理

以当前镜像为基础镜像, 将自己的clash配置文件复制到镜像中, 然后设置操作启动clash进程即可.

**1. 将自己的定于配置文件xxx.yaml或者通过命令从订阅链接中下载**

```shell
wget -O config.yaml [subscribe url 订阅链接]
```

**2. 新建一个目录,并新建文件Dockerfile, 内容如下**

```Dockerfile
FROM caldremch/ubuntu-clash-proxy:latest
# /clash/data/ 必须将配置文件复制到这个目录下, 因为clash-supervisord.conf已经固定了这个路径
COPY config.yaml /clash/data/

ENTRYPOINT ["/setup.sh"]
````

setup.sh主要是用于启动clash, 脚本内容如下:

```shell
#!/bin/sh
set -e
supervisord -c /etc/supervisor/supervisord.conf
```

## 为什么要使用setup.sh文件?

因为我们的基础镜像一般都会在上面运行自己的其他服务, 使用setup.sh, 就可以在启动代理进程后, 你也可以在脚本后面加上自己额外的启动.

比如:

```shell
set -e
supervisord -c /etc/supervisor/supervisord.conf
java -jar xxx.jar
```
