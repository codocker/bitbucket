# docker-bitbucket

基于最新版本的`Atlassian Bitbucket`版本打包的`Docker`镜像，功能有
- 集成了`MySQL`/`MariaDB`驱动
- 最新可用的`Agent`程序
- 集成健康检查

## 使用方法

### 部署容器

```shell
sudo docker pull storezhang/bitbucket && sudo docker run \
  --volume=/home/storezhang/data/docker/bitbucket:/config:rw \
  --env=UID=$(id -u xxx) \
  --env=GID=$(id -g xxx) \
  --env=ORG=https://xxx.com \
  --env=NAME=xxx \
  --env=EMAIL=abc@xxx.com \
  --env=PROXY_DOMAIN=bitbucket.ruijc.com \
  --env=PROXY_PORT=20443 \
  --publish=37990:7990 \
  --restart=always \
  --detach=true \
  --name=Bitbucket \
  storezhang/bitbucket
```

提供了比较好的`User Mapping`功能，指定环境变量`UID`和`GID`为相应的用户和组就可以了

### 使用Agent

分成两个步骤

#### 进入容器

```shell
sudo docker exec -it Bitbucket /bin/bash
```

#### 执行Agent

```shell
bitbucket 插件
```

复制序列号到系统，下一步就可以了
