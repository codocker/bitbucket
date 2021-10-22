FROM storezhang/alpine AS builder


# 版本
ENV VERSION 7.6.7


WORKDIR /opt/atlassian


RUN apk update
RUN apk add axel

# 安装Bitbucket
RUN axel --num-connections 64 --insecure --output bitbucket${VERSION}.tar.gz "https://product-downloads.atlassian.com/software/stash/downloads/atlassian-bitbucket-${VERSION}.tar.gz"
RUN tar -xzf bitbucket${VERSION}.tar.gz
RUN mv atlassian-bitbucket-${VERSION} bitbucket
# 不需要启动内部Elasticsearch程序，强制使用外部搜索引擎
RUN rm -rf /opt/atlassian/bitbucket/elasticsearch
RUN rm -rf /opt/atlassian/bitbucket/bin/_start-search.sh && rm -rf /opt/atlassian/bitbucket/bin/_stop-search.sh





# 打包真正的镜像
FROM storezhang/atlassian



MAINTAINER storezhang "storezhang@gmail.com"
LABEL architecture="AMD64/x86_64" version="latest" build="2021-10-22"
LABEL Description="Atlassian公司产品Bitbucket，用来做Git服务器。在原来的基础上增加了MySQL/MariaDB驱动以及破解解程序"



# 开放端口
# Bitbucket本身的端口
EXPOSE 7990



# 复制文件
COPY --from=builder /opt/atlassian/bitbucket /opt/atlassian/bitbucket
COPY docker /



RUN set -ex \
    \
    \
    \
    # 安装Git环境
    && apk update \
    && apk --no-cache add git \
    \
    \
    \
    # 增加执行权限
    && chmod +x /etc/s6/bitbucket/* \
    && chmod +x /usr/bin/bitbucket \
    \
    \
    \
    # 安装MySQL/MariaDB驱动
    && cp -r /opt/oracle/mysql/lib /opt/atlassian/bitbucket/app/WEB-INF \
    \
    \
    \
    # 清理镜像，减少无用包
    && rm -rf /var/cache/apk/*



# 设置Bitbucket HOME目录
ENV BITBUCKET_HOME /config
ENV LOG_EXPIRED_DAYS 30



# 健康检查
HEALTHCHECK --interval=15s --timeout=5s --retries=3 CMD curl --include --fail http://127.0.0.1:7990
