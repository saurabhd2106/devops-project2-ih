FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /app

# Leverage build cache for dependencies
COPY pom.xml .
RUN mvn -q -e -B -DskipTests dependency:go-offline

# Copy sources and build
COPY src ./src
RUN mvn -q -e -B -DskipTests clean package

# Runtime image
FROM eclipse-temurin:21-jre
WORKDIR /app

# Set default Spring profile (overridable at runtime)
ENV SPRING_PROFILES_ACTIVE=docker

# Copy the built jar
COPY --from=build /app/target/*.jar /app/app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","/app/app.jar"]
