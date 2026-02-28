pipeline {
  agent any

  environment {
    DOCKER_IMAGE    = 'your-dockerhub-username/spring-app'
    DOCKER_TAG      = "${BUILD_NUMBER}"
    KUBECONFIG_PATH = '/var/lib/jenkins/.kube/config'
    SONAR_PROJECT   = 'spring-app'
  }

  tools {
    maven 'Maven3'
    jdk   'JDK17'
  }

  stages {

    stage('Checkout') {
      steps {
        git branch: 'main',
            url: 'https://github.com/your-org/your-repo.git',
            credentialsId: 'git-credentials'
      }
    }

    stage('Build & Test') {
      steps {
        sh 'mvn clean test'
      }
      post {
        always {
          junit '**/target/surefire-reports/*.xml'
        }
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('SonarQube') {
          sh """
            mvn sonar:sonar \
              -Dsonar.projectKey=${SONAR_PROJECT} \
              -Dsonar.login=$SONAR_AUTH_TOKEN
          """
        }
      }
    }

    stage('Quality Gate') {
      steps {
        timeout(time: 5, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('Package') {
      steps {
        sh 'mvn package -DskipTests'
        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
      }
    }

    stage('Deploy to Nexus') {
      steps {
        sh 'mvn deploy -DskipTests'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
        sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
      }
    }

    stage('Push Docker Image') {
      steps {
        withCredentials([usernamePassword(
            credentialsId: 'docker-credentials',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS')]) {
          sh """
            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
            docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
            docker push ${DOCKER_IMAGE}:latest
          """
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh """
          sed -i 's|${DOCKER_IMAGE}:latest|${DOCKER_IMAGE}:${DOCKER_TAG}|g' \
              k8s-deployment.yaml
          kubectl --kubeconfig=${KUBECONFIG_PATH} apply -f k8s-deployment.yaml
          kubectl --kubeconfig=${KUBECONFIG_PATH} \
              rollout status deployment/spring-mysql-deployment
        """
      }
    }
  }

  post {
    success { echo 'Pipeline completed successfully!' }
    failure { echo 'Pipeline failed. Check the logs above.' }
    always  { sh 'docker image prune -f' }
  }
}
