# 构建阶段
FROM maven:3.8.6-eclipse-temurin-8-alpine AS builder

WORKDIR /build
RUN git clone -b main --depth 1 https://github.com/wang-yan-github/gateway.git . \
    && mvn package -DskipTests -T 1C
# 先复制POM文件利用缓存
COPY pom.xml .
# 下载依赖（保持这步独立以利用Docker缓存）
RUN mvn dependency:go-offline -B

# 复制源代码
COPY src ./src

# 构建应用（使用并行构建并减少日志输出）
RUN mvn package -DskipTests \
    -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=WARN \
    -T 1C

# 运行阶段
FROM eclipse-temurin:8-jre-alpine

# 设置时区
ENV TZ=Asia/Shanghai
RUN apk add --no-cache tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# 创建非特权用户
RUN addgroup -S appuser && adduser -S appuser -G appuser

WORKDIR /app
# 复制构建产物并设置权限
COPY --from=builder --chown=appuser:appuser /build/target/*.jar ./app.jar

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -qO- http://localhost:8080/actuator/health | grep -q UP || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]