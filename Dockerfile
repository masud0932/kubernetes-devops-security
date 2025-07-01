FROM eclipse-temurin:21-jdk
EXPOSE 8080
ARG JAR_FILE=target/*.jar
RUN groupadd pipeline && useradd -m -g pipeline k8s-pipeline
COPY ${JAR_FILE} /home/k8s-pipeline/app.jar
USER k8s-pipeline
ENTRYPOINT ["java","-jar","/home/k8s-pipeline/app.jar"]