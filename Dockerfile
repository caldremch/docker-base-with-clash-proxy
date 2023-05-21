FROM ubuntu:22.04

# Replace the source (used in domestic builds), if it is a domestic build please type the following 3 lines of comments
# 替换源(国内构建使用), 如果是国内构建请打以下3行注释
# RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
# RUN sed -i s@/security.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
# RUN sed -i 's/ports.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

# Set China time zone, if you need to set it to another time zone, change the TZ value
# 设置中国时区, 如果需要设置成别的时区, 就更换TZ的值
ENV TZ=Asia/Shanghai \
	DEBIAN_FRONTEND=noninteractive

# supervisor is a process management tool, mainly used for multi-process management, here mainly used to start the clash process
# supervisor为进程管理工具, 主要用于多进程管理, 这里主要用于启动clash进程
RUN apt-get update && apt install -y tzdata supervisor cloc wget gzip\
	&& ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
	&& echo ${TZ} > /etc/timezone \
	&& dpkg-reconfigure --frontend noninteractive tzdata \
	&& rm -rf /var/lib/apt/lists/*  # 清空已经下载的软件包文件和缓存,减少镜像的大小. Empty the downloaded package files and cache to reduce the size of the image

# Download and copy the clash executable
# 下载并复制clash执行文件
ARG clashVersion=1.16.0
RUN wget -O clash.gz https://github.com/Dreamacro/clash/releases/download/v1.16.0/clash-linux-amd64-v${clashVersion}.gz \
	&& gzip -d clash.gz && cp clash /usr/local/bin/ && rm -rf clash.gz && rm -rf clash

# Country.mmdb is the file needed to run the clash, which is used for the clash cache 
# Country.mmdb为clash运行所需要的文件,用于clash缓存的 
COPY Country.mmdb /clash/data/

# chmod +x /usr/local/bin/clash Set executable
# 设置可执行
RUN chmod +x /usr/local/bin/clash

# Copy the clash startup configuration file to the supervisor configuration directory
# 将clash启动的配置文件复制到supervisor配置目录下
COPY clash-supervisord.conf /etc/supervisor/conf.d/

# Set up http/https proxy
# 设置http/https代理
ENV http_proxy="http://127.0.0.1:7890"
ENV https_proxy="http://127.0.0.1:7890"
ENV no_proxy="localhost, 127.0.0.1"

# Set mirror-related description information
# 设置镜像相关描述信息
LABEL maintainer="Caldremch"
LABEL org.label-schema.schema-version="0.0.1"
LABEL org.label-schema.name="caldremch/ubuntu-clash-proxy"
LABEL org.label-schema.version="${DOCKER_TAG}"
LABEL org.label-schema.usage="/README.md"
LABEL org.label-schema.docker.cmd="docker run -it --entrypoint /bin/bash caldremch/ubuntu-clash-proxy"
LABEL org.label-schema.build-date="${BUILD_DATE}"
LABEL org.label-schema.vcs-ref="${SOURCE_COMMIT}@${SOURCE_BRANCH}"