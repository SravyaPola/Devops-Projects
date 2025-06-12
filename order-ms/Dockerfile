# order-ms/Dockerfile

# 1. Start from a slim OpenJDK runtime
FROM openjdk:17-jdk-slim

# 2. Create and switch to /app
WORKDIR /app

# 3. Copy the JAR our Jenkins build produces
#    (inside order-ms/, target/ is right next to this Dockerfile)
COPY target/*.jar app.jar

# 4. Expose the port Spring Boot runs on
EXPOSE 8080

# 5. Run the app
ENTRYPOINT ["java","-jar","app.jar"]

