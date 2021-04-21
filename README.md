# docker-bitbucket

基于最新版本的Atlassian Bitbucket版本打包的Docker镜像，集成了MySQL/MariaDB驱动以及最新可用的Agent程序

## 使用方法

### 部署容器

```shell
sudo docker pull storezhang/bitbucket && sudo docker run \
  --volume=/home/storezhang/data/docker/bitbucket:/config:rw \
  --env=UID=$(id -u xxx) \
  --env=GID=$(id -g xxx) \
  --env=PROXY_DOMAIN=bitbucket.ruijc.com \
  --env=PROXY_PORT=20443 \
  --publish=37990:7990 \
  --restart=always \
  --detach=true \
  --name=Bitbucket \
  storezhang/bitbucket
```

提供了比较好的User Mapping功能，指定环境变量UID和GID为相应的用户和组就可以了

### 使用Agent

分成两个步骤

#### 进入容器

```shell
sudo docker exec -it Bitbucket /bin/bash
```

#### 执行Agent

```shell
keygen -p bitbucket -m xxx@xxx.com -n xxx -o https://xxx.com -s ABCD-CFDS-JJFF-LLKD -d
```

复制序列号到系统，下一步就可以了