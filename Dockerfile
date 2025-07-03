FROM eclipse-temurin:21-jdk-alpine

# Argument to get the JAR file from build context
#ARG JAR_FILE=target/*.jar

# Create group with GID 3000 and user with UID 1000
RUN addgroup -g 3000 -S k8s-group && \
    adduser -u 1000 -S k8s-user -G k8s-group

# Set working directory to the new user's home
WORKDIR /home/k8s-user

# Copy the JAR into the working directory (relative path)
RUN cd /k8s-Deployment
COPY target/numeric-0.0.1.jar /home/k8s-user/app.jar

# Set permissions
RUN chown -R 1000:3000 /home/k8s-user

# Expose application port
EXPOSE 8081

# Switch to non-root user
USER 1000:3000

# Run app
ENTRYPOINT ["java", "-jar", "app.jar"]

