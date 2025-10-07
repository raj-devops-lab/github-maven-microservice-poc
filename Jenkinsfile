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
  - name: owasp
    image: owasp/dependency-check:latest
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
          // You can add versioning logic here later if needed
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
      when { expression { false } } // skip for now if tests not ready
      steps {
        container('maven') {
          sh 'mvn test'
        }
      }
    }

  //   stage('SonarQube Scan') {
  //     when { expression { false } } // enable later when SonarQube is configured
  //     steps {
  //       echo '🔍 Running SonarQube Scan...'
  //     }
  //   }

  //   stage('OWASP Dependency Check') {
  //     steps {
  //       echo "🛡️ Running OWASP Dependency Check..."
  //       container('owasp') {
  //         sh '''
  //           dependency-check.sh \
  //             --project "${BRANCH_NAME}" \
  //             --scan /home/jenkins/agent/workspace/${JOB_NAME} \
  //             --format HTML \
  //             --out /home/jenkins/agent/workspace/${JOB_NAME}/dependency-check-report
  //         '''
  //       }
  //     }
  //   }

  //   stage('Gitleaks Scan') {
  //     when { expression { false } }
  //     steps {
  //       echo '🔐 Running Gitleaks Scan...'
  //     }
  //   }
  // }

  post {
    always {
      echo "✅ Pipeline finished for branch: ${env.BRANCH_NAME}"
      echo "📄 Reports (if any) are in the workspace directory."
    }
  }
}
