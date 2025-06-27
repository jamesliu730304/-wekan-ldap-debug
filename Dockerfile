FROM ubuntu:24.04
LABEL maintainer="wekan-debug"

ARG DEBIAN_FRONTEND=noninteractive
ENV NODE_VERSION=v14.21.4
ENV METEOR_RELEASE=2.14
ENV ARCHITECTURE=linux-x64

# 安装系统依赖
RUN apt-get update && \
    apt-get install -y curl wget git build-essential python3 ca-certificates && \
    curl https://install.meteor.com/ | sh

# 创建用户
RUN useradd --user-group --system --home-dir /home/wekan wekan

# 拷贝源码（你将用 . 上传 Wekan 源码）
COPY . /home/wekan/app
WORKDIR /home/wekan/app

# 安装 node 及 meteor
RUN curl -LO https://github.com/wekan/node-v14-esm/releases/download/v14.21.4/node-v14.21.4-linux-x64.tar.gz && \
    tar -xzf node-v14.21.4-linux-x64.tar.gz -C /usr/local --strip-components=1 && \
    npm install -g npm@6.14.17

# 编译 Wekan 项目
RUN meteor npm install --production && \
    meteor build --directory /home/wekan/bundle --server-only && \
    cd /home/wekan/bundle/programs/server && npm install

# 打包为构建镜像中的启动入口
WORKDIR /home/wekan/bundle
EXPOSE 3000
CMD ["node", "main.js"]

