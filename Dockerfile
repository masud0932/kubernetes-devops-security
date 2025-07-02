FROM eclipse-temurin:21-jdk

# Create a group with GID 3000
RUN groupadd -g 3000 pipeline

# Create a user with UID 1000 and add it to the group
RUN useradd -u 1000 -g 3000 -m -s /bin/bash k8s-pipeline

# Copy JAR and set permissions
COPY target/numeric-0.0.1.jar /home/k8s-pipeline/app.jar
RUN chmod 755 /home/k8s-pipeline/app.jar \
    && chown k8s-pipeline:pipeline /home/k8s-pipeline/app.jar

# Expose port
EXPOSE 8082
# Set working directory
WORKDIR /home/k8s-pipeline

# Run app
ENTRYPOINT ["java", "-jar", "/home/k8s-pipeline/app.jar"]
