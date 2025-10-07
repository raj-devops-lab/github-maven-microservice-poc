pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
spec:
  imagePullSecrets:
    - name: dockerhub-secret
  volumes:
    - name: maven-cache
      persistentVolumeClaim:
        claimName: maven-cache-pvc
  containers:
    - name: maven
      image: maven:3.9.9-eclipse-temurin-17
      command:
        - cat
      tty: true
      volumeMounts:
        - name: maven-cache
          mountPath: /root/.m2
"""
    }
  }

  environment {
    DEVTRON_URL = 'http://80.225.201.22:8000/orchestrator/webhook/ext-ci/3'
  }

  options {
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '10', daysToKeepStr: '30'))
    timeout(time: 60, unit: 'MINUTES')
  }

  stages {
    stage('Checkout') {
      steps {
        echo "🔄 Checking out branch: ${env.BRANCH_NAME}"
        checkout scm
      }
    }

    stage('Build with Maven') {
      steps {
        echo "🏗️ Building project using Maven"
        container('maven') {
          sh 'mvn -B clean package -DskipTests'
        }
      }
    }

    stage('Run Tests') {
      when { expression { env.BRANCH_NAME.startsWith("feature/") } }
      steps {
        echo "🧪 Running Unit Tests"
        container('maven') {
          sh 'mvn test'
          junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
        }
      }
    }

    stage('OWASP Dependency Check') {
      when { expression { env.BRANCH_NAME.startsWith("feature/") } }
      steps {
        echo "🛡️ Running OWASP Dependency Check"
        container('maven') {
          sh '''
            mkdir -p odc odc-report
            apt-get update -y
            apt-get install -y wget unzip openjdk-17-jdk

            DEP_CHECK_VERSION=12.1.0
            wget -O dependency-check.zip \
              https://github.com/jeremylong/DependencyCheck/releases/download/v${DEP_CHECK_VERSION}/dependency-check-${DEP_CHECK_VERSION}-release.zip
            unzip -q dependency-check.zip -d odc

            odc/dependency-check/bin/dependency-check.sh \
              --project "MavenApp" \
              --scan . \
              --format HTML \
              --out odc-report \
              --nvdApiKey e84fb4cb-dab5-4095-871d-7d53a4363621 \
              --enableExperimental

            echo "✅ OWASP scan completed. Reports in odc-report/"
          '''
        }
        publishHTML(target: [
          reportDir: 'odc-report',
          reportFiles: 'dependency-check-report.html',
          reportName: 'OWASP Dependency Check Report',
          keepAll: true,
          alwaysLinkToLastBuild: true,
          allowMissing: true
        ])
      }
    }

    stage('Gitleaks Scan') {
      when { expression { env.BRANCH_NAME.startsWith("feature/") } }
      steps {
        echo "🔒 Running Gitleaks Scan"
        container('maven') {
          sh '''
            mkdir -p gitleaks
            curl -L -o gitleaks.tar.gz https://github.com/zricethezav/gitleaks/releases/latest/download/gitleaks-linux-amd64.tar.gz
            tar -xzf gitleaks.tar.gz -C gitleaks
            chmod +x gitleaks/gitleaks
            ./gitleaks/gitleaks detect --source="." --report-format=json --report-path=gitleaks-report.json
          '''
        }
        archiveArtifacts artifacts: 'gitleaks-report.json', allowEmptyArchive: true
      }
    }
  }

  post {
    always {
      echo "✅ Pipeline finished for branch: ${env.BRANCH_NAME}"
    }
  }
}
