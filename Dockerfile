# 使用官方的 Maven 镜像进行构建
FROM maven:3.8.6-openjdk-8-slim AS builder

# 安装 git
RUN apt-get update && apt-get install -y git

# 设置工作目录
WORKDIR /gateway

# 从 GitHub 克隆代码
RUN git clone https://github.com/wang-yan-github/gateway.git . && ls -l

# 构建项目
RUN mvn clean install -DskipTests
