# 使用官方的 Maven 镜像进行构建
FROM maven:3.8.6-openjdk-8-slim AS builder

# 设置工作目录为 /gateway
WORKDIR /gateway

# 从 GitHub 克隆代码
RUN git clone https://github.com/wang-yan-github/gateway.git .

# 拷贝 Maven 配置文件 (pom.xml) 以利用 Docker 缓存
COPY pom.xml .

# 使用 Maven 缓存构建依赖并去离线
RUN mvn dependency:go-offline -B

# 复制源代码
COPY src /gateway/src

# 构建项目并跳过测试，优化构建
RUN mvn clean install -DskipTests

# 使用官方的 Java 基础镜像作为运行环境
FROM openjdk:8-jre-slim

# 将构建好的 jar 文件从 builder 镜像中复制到当前镜像的 /app 目录
COPY --from=builder /gateway/target/gateway-0.0.1.jar /app/gateway-0.0.1.jar

# 设置工作目录
WORKDIR /app

# 暴露端口（根据项目实际运行的端口调整）
EXPOSE 8080

# 启动 Java 应用
CMD ["java", "-jar", "gateway-0.0.1.jar"]
