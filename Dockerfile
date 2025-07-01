FROM eclipse-temurin:21-jdk
RUN groupadd pipeline && useradd -m -g pipeline k8s-pipeline
COPY target/numeric-0.0.1.jar /home/k8s-pipeline/app.jar
USER k8s-pipeline
ENTRYPOINT ["java", "-jar", "/home/k8s-pipeline/app.jar"]
EXPOSE 8083