pipeline {
  agent any
  environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "masudrana09/numeric-app:${GIT_COMMIT}"
    applicationURL = "http://devsecops.eastus.cloudapp.azure.com"
    applicationURI = "/increment/99"
  }
  tools {
    maven 'maven'
    }

  stages {
 
      stage('Maven version check') {
        steps {
          sh "mvn --version"
        }
      }
    
    stage('Build Artifact - Maven') {
      steps {
        sh "mvn clean package -DskipTests=true"
        archive 'target/*.jar'
      }
    }

    stage('Unit Tests - JUnit and Jacoco') {
      steps {
        sh "mvn test"
      }
    }
    stage('Mutation Tests - PIT') {
      steps {
        sh "mvn org.pitest:pitest-maven:mutationCoverage -Dverbose=true"
      }
      }
      stage('SonarQube Analysis') {
      steps {
           withSonarQubeEnv('sonarqube') {
           sh "mvn sonar:sonar \
            -Dsonar.projectKey=jenkins-pipeline \
            -Dsonar.projectName='jenkins-pipeline'"
         }
      }
    }
    stage('Quality Gate') {
       steps {
       timeout(time: 2, unit: 'MINUTES') {
      waitForQualityGate abortPipeline: true
    }
  }
}
stage('Dependency Check') {
      steps {
        parallel(
          "Dependency Check": {
            sh "mvn dependency-check:check"
          },
          "Trivy Scan": {
            sh "bash trivy-docker-image-scan.sh"
          },
          "OPA Conftest-Docker": {
            sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test Dockerfile --policy dockerfile-security.rego'
          }
        )
      }
    }
    stage('Docker Build and Push') {
      steps {
        withDockerRegistry([credentialsId: "docker_credential", url: ""]) {
          sh 'printenv'
          sh "sudo docker build -t masudrana09/numeric-app:${GIT_COMMIT} ."
          sh "docker push masudrana09/numeric-app:${GIT_COMMIT}"
        }
      }
    }
    stage('OPA Conftest-Kubernetes') {
      steps {
        parallel(
          "OPA Scan": {
             sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
          },
          "Kubesec Scan": {
            sh "bash kubesec-scan.sh"
          },
          "Trivy Scan-Docker Image": {
            sh "bash trivy-k8s-scan.sh"
          }
        )
      }
    }
    stage('K8S Deployment - DEV') {
      steps {
        parallel(
          "Deployment": {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              sh "kubectl apply -f k8s_deployment_service.yaml"
            }
          },
          "Rollout Status": {
            withKubeConfig([credentialsId: 'kubeconfig']) {
              echo "Waiting for deployment rollout status..."
          }
          }
        )
      }
    }
 }
    post {
     always {
      junit 'target/surefire-reports/*.xml'
      jacoco execPattern: 'target/jacoco.exec'
      pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
      dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
     }
    }
  }
