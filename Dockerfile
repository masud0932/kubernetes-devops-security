FROM eclipse-temurin:21-jdk

# Create group and user
RUN groupadd pipeline && useradd -m -g pipeline k8s-pipeline

# Copy JAR and set permissions
COPY target/numeric-0.0.1.jar /home/k8s-pipeline/app.jar
RUN chmod 755 /home/k8s-pipeline/app.jar \
    && chown k8s-pipeline:pipeline /home/k8s-pipeline/app.jar

# Switch to non-root user
USER k8s-pipeline

# Expose port
EXPOSE 8083

# Run app
ENTRYPOINT ["java", "-jar", "/home/k8s-pipeline/app.jar"]
