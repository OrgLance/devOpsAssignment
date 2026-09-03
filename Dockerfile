FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /devOpsAssignment

COPY pom.xml ./

RUN mvn dependency:go-offline

COPY src ./src

RUN mvn clean package

FROM eclipse-temurin:17-jre-alpine

WORKDIR /devOpsAssignment

RUN addgroup -S appgroup && adduser -S appuser -G appgroup


COPY --from=build /devOpsAssignment/target/hello-service.jar  ./

RUN chown appuser:appgroup hello-service.jar 

USER appuser


EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

ENTRYPOINT ["java","-jar","hello-service.jar"]
