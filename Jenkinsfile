pipeline {
  agent {
    kubernetes {
      label 'dynamic-agent'
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: slave
spec:
  containers:
  - name: jnlp
    image: jenkins/inbound-agent:latest
    tty: true
  - name: maven
    image: maven:3.9.9-eclipse-temurin-17
    command:
    - cat
    tty: true
"""
    }
  }

  stages {

    stage('Checkout') {
      steps {
        echo "🔄 Checking out branch: ${env.BRANCH_NAME}"
        checkout scm
      }
    }

    stage('Version Management') {
      steps {
        script {
          echo "📦 Handling version management for ${env.BRANCH_NAME}"
        }
      }
    }

    stage('Build') {
      steps {
        echo "🚀 Running Maven Build for branch: ${env.BRANCH_NAME}"
        container('maven') {
          sh 'mvn -B clean package'
        }
      }
    }

    stage('Run Tests') {
      steps {
        echo "🧪 Running Maven Tests..."
        container('maven') {
          sh 'mvn test'
        }
      }
    }

  } // 👈 end of stages

  post {
    always {
      echo "✅ Pipeline finished for branch: ${env.BRANCH_NAME}"
      echo "📄 Build artifacts and reports (if any) are in the workspace."
    }
  }
}
