# 使用官方的 Maven 镜像进行构建
FROM maven:3.8.6-openjdk-8-slim AS builder

# 安装 git
RUN apt-get update && apt-get install -y git

# 设置工作目录
WORKDIR /gateway

# 从 GitHub 克隆代码
RUN git clone https://github.com/wang-yan-github/gateway.git

# 构建项目
RUN mvn clean install -DskipTests

# 使用官方的 Java 基础镜像作为运行环境
FROM openjdk:8-jre-slim

# 将构建好的 jar 文件复制到新的容器中
COPY --from=builder /gateway/target/gateway-0.0.1.jar /app/gateway-0.0.1.jar

# 设置工作目录
WORKDIR /app

# 暴露端口（根据项目实际运行的端口调整）
EXPOSE 8080

# 启动 Java 应用
CMD ["java", "-jar", "gateway-0.0.1.jar"]
