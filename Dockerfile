FROM eclipse-temurin:21-jdk

# Expose application port
EXPOSE 8081

# Argument to get the JAR file (from build context)
ARG JAR_FILE=target/*.jar

# Create group and user (auto-assign UID/GID unless specified)
RUN groupadd -r pipeline && useradd -m -r -g pipeline k8s-pipeline

# Copy JAR into user's home directory
COPY ${JAR_FILE} /home/k8s-pipeline/app.jar

# Set ownership and permissions (optional but recommended)
RUN chown k8s-pipeline:pipeline /home/k8s-pipeline/app.jar

# Set working directory
WORKDIR /home/k8s-pipeline

# Switch to non-root user
USER k8s-pipeline

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
