FROM openjdk:17-jdk-slim
WORKDIR /app
COPY /target/*.jar ./java.jar
EXPOSE 8080
CMD ["java", "-jar", "java.jar"]
