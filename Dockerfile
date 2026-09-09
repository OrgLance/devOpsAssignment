
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests


FROM eclipse-temurin:17-jre-jammy

WORKDIR /app


RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --system appgroup \
    && useradd --system --gid appgroup appuser

COPY --from=builder /app/target/hello-service.jar /app/hello-service.jar

RUN chown appuser:appgroup /app/hello-service.jar

USER appuser

EXPOSE 8080

ENV GREETING=Hello
ENV NAME=World

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1



