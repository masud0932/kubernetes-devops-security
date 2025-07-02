FROM eclipse-temurin:21-jdk

# Expose application port
EXPOSE 8081

# Argument to get the JAR file (from build context)
ARG JAR_FILE=target/numeric-0.0.1.jar

# Create group and user (auto-assign UID/GID unless specified)
RUN groupadd -r pipeline && useradd -m -r -g pipeline k8s-pipeline

# Copy JAR into user's home directory
COPY ${JAR_FILE} app.jar

# Switch to non-root user
USER k8s-pipeline

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
