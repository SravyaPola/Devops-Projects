# Use a slimmed‐down OpenJDK JRE image as the base
FROM openjdk:11-jre-slim

# Set a working directory inside the container
WORKDIR /app

# Copy the built JAR from the "order-ms/target" folder into the image.
# The wildcard (*.jar) will pick up whatever .jar was produced by Maven.
COPY order-ms/target/*.jar app.jar

# Expose whatever port your service listens on (e.g. 8080 for a Spring Boot app)
EXPOSE 8080

# When a container is started from this image, run the JAR
ENTRYPOINT ["java", "-jar", "app.jar"]

