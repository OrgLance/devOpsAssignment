# ============================================================
# Stage 1: Build
# ============================================================
FROM maven:3.9.6-eclipse-temurin-17-alpine AS builder

WORKDIR /app

# Copy Maven configuration first for better Docker layer caching
COPY pom.xml .

# Copy source code
COPY src ./src

# Build the Spring Boot JAR
RUN mvn clean package -DskipTests


# ============================================================
# Stage 2: Runtime
# ============================================================
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Create non-root user and group
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

# Copy the built JAR from the builder stage
COPY --from=builder /app/target/hello-service.jar /app/app.jar

# Give ownership to the non-root user
RUN chown appuser:appgroup /app/app.jar

# Run application as non-root user
USER appuser

# Application port
EXPOSE 8080

# Container health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=15s --retries=3 \
    CMD wget -qO- http://localhost:8080/health || exit 1

# Start Spring Boot application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
