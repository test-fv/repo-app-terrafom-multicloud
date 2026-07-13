# =========================
# Stage 1: Build
# =========================
FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /build

# Copiamos primero dependencias (mejora cache)
COPY pom.xml .

RUN mvn -B -e -q dependency:go-offline

# Copiamos el código fuente
COPY src ./src

# Compilamos
RUN mvn -B clean package -DskipTests


# =========================
# Stage 2: Runtime
# =========================
FROM eclipse-temurin:17-jre-alpine

# Herramienta necesaria para el HEALTHCHECK
RUN apk add --no-cache wget

ENV JAVA_OPTS="-Xms256m -Xmx512m"

WORKDIR /app

##############################################################################
# Application
##############################################################################

COPY --from=build /build/target/*.jar /app/app.jar

##############################################################################
# Startup Script
##############################################################################

COPY start.sh /start.sh

RUN chmod +x /start.sh

##############################################################################
# Non Root User
##############################################################################

RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup && \
    chown appuser:appgroup /app/app.jar /start.sh

USER appuser

##############################################################################
# Network
##############################################################################

EXPOSE 8080

##############################################################################
# Health Check
##############################################################################

HEALTHCHECK \
  --interval=10s \
  --timeout=5s \
  --start-period=20s \
  --retries=12 \
  CMD wget -qO- http://127.0.0.1:8080/health >/dev/null || exit 1

##############################################################################
# Start Application
##############################################################################

ENTRYPOINT ["/start.sh"]