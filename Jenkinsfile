pipeline {
  agent any

  stages {

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
      post {
        always {
          junit 'target/surefire-reports/*.xml'
          jacoco execPattern: 'target/jacoco.exec'
        }
      }
    }
    stage('Mutation Tests - PIT') {
      steps {
        sh "mvn org.pitest:pitest-maven:mutationCoverage"
      }
      post {
        always {
          pitmutation mutationStatsFile: 'target/pit-reports/**/mutations.xml'
        }
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
          }
        )
      }
    }
    stage('Docker Build and Push') {
      steps {
        withDockerRegistry([credentialsId: "docker_credential", url: ""]) {
          sh 'printenv'
          sh 'docker build -t masudrana09/numeric-app:""$GIT_COMMIT"" .'
          sh 'docker push masudrana09/numeric-app:""$GIT_COMMIT""'
        }
      }
    }
    stage('Kubernetes Deployment - DEV') {
      steps {
        withKubeConfig([credentialsId: 'kubeconfig']) {
          sh "sed -i 's#replace#masudrana09/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
          sh "kubectl apply -f k8s_deployment_service.yaml"
        }
      }
    }
    
  }

}