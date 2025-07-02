FROM eclipse-temurin:21-jdk

# Expose application port
EXPOSE 8081

# Argument to get the JAR file from build context
ARG JAR_FILE=target/*.jar

# Create non-root group and user
RUN groupadd -r pipeline && useradd -m -r -g pipeline k8s-pipeline

# Set working directory to the new user's home
WORKDIR /home/k8s-pipeline

# Copy the JAR into the working directory (relative path)
COPY ${JAR_FILE} /home/k8s-pipeline/app.jar

# Change ownership of the jar file (good practice)
RUN chown k8s-pipeline:pipeline app.jar

# Switch to non-root user
USER k8s-pipeline

# Run the application
CMD ["java", "-jar", "app.jar"]

