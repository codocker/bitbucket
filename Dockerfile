FROM ubuntu AS builder


# 版本
ENV VERSION 7.11.2
ENV JDBC_VERSION 8.0.23


WORKDIR /opt/altassian


RUN apt update && apt install -y axel

RUN axel --num-connections 64 --insecure "https://product-downloads.atlassian.com/software/stash/downloads/atlassian-bitbucket-${VERSION}.tar.gz"
RUN tar -xzvf atlassian-bitbucket-${VERSION}.tar.gz && mv atlassian-bitbucket-${VERSION} bitbucket
RUN chmod +x bitbucket/bin/*.sh

RUN axel --num-connections 64 --insecure "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${JDBC_VERSION}.tar.gz"
RUN tar -xzvf mysql-connector-java-${JDBC_VERSION}.tar.gz && mkdir -p /opt/atlassian/bitbucket/app/WEB-INF/lib/ && mv mysql-connector-java-${JDBC_VERSION}/mysql-connector-java-${JDBC_VERSION}.jar /opt/atlassian/bitbucket/app/WEB-INF/lib/mysql-connector-java-${JDBC_VERSION}.jar





# 打包真正的镜像
FROM ubuntu


MAINTAINER storezhang "storezhang@gmail.com"
LABEL architecture="AMD64/x86_64" version="latest" build="2020-12-17"
LABEL Description="Atlassian公司产品Bitbucket，用来做Git服务器。在原来的基础上增加了MySQL/MariaDB驱动以及太了解程序。"



# 设置Bitbucket HOME目录
ENV BITBUCKET_HOME /config
# 设置Java Agent
ENV JAVA_HOME /usr/lib/jvm/java-14-openjdk-amd64
ENV JAVA_OPTS -javaagent:/opt/altassian/agent/agent.jar
# 增加中文支持，不然命令行执行程序会报错
ENV LANG zh_CN.UTF-8

# 设置运行用户及组
ENV USERNAME bitbucket
ENV UID 1000
ENV GID 1000



# 开放端口
# Bitbucket本身的端口
EXPOSE 7990
# 内置Elasticsearch端口
EXPOSE 7992
EXPOSE 7993



VOLUME /config
WORKDIR /config



# 复制文件
COPY --from=builder /opt/altassian /opt/altassian
COPY docker /



RUN set -ex \
    \
    \
    \
    # 创建用户及用户组，后续所有操作都以该用户为执行者，修复在Docker中创建的文件不能被外界用户所操作
    && addgroup --gid ${GID} --system ${USERNAME} \
    && adduser --uid ${UID} --gid ${GID} --system ${USERNAME} \
    \
    \
    \
    # 安装JRE，确保可以启动应用
    && apt update -y --fix-missing \
    && apt upgrade -y \
    \
    \
    \
    # 安装守护进程，因为要Xvfb和Nuwa同时运行
    && apt install -y s6 gosu openjdk-14-jre \
    && chmod +x /usr/bin/entrypoint \
    && chmod +x /usr/bin/agent \
    && chmod +x /etc/s6/.s6-svscan/* \
    && chmod +x /etc/s6/bitbucket/* \
    \
    \
    \
    # 设置中文支持，不然运行NSIS时会报解析不了参数的错误
    && apt install -y locales \
    && sed -ie 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    \
    \
    \
    # 清理镜像，减少无用包
    && rm -rf /var/lib/apt/lists/* \
    && apt clean


ENTRYPOINT ["/usr/bin/entrypoint"]
CMD ["/bin/s6-svscan", "/etc/s6"]