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
  imagePullSecrets:
    - name: dockerhub-secret
  containers:
  - name: jnlp
    image: jenkins/inbound-agent:latest
    tty: true
  - name: maven
    image: maven:3.9.9-eclipse-temurin-17
    command: ['cat']
    tty: true
  - name: node
    image: node:18
    command: ['cat']
    tty: true
  - name: gitleaks
    image: zricethezav/gitleaks:latest
    command: ['cat']
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
        echo "🚀 Running Maven Build"
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

        // ✅ Publish test results
        junit '**/target/surefire-reports/*.xml'
      }
    }

    stage('OWASP Dependency Check') {
      when { expression { env.BRANCH_NAME.startsWith("feature/") } }
      steps {
        echo "🛡️ Running OWASP Dependency Check"
        container('node') {
          sh '''
            set -e

            # Create directories
            mkdir -p odc odc-report

            # Install required tools
            apt-get update -y
            apt-get install -y openjdk-17-jdk wget unzip

            # Define Dependency Check version
            DEP_CHECK_VERSION=12.1.0

            echo "⬇️ Downloading Dependency Check v${DEP_CHECK_VERSION}"
            wget -O dependency-check.zip https://github.com/jeremylong/DependencyCheck/releases/download/v${DEP_CHECK_VERSION}/dependency-check-${DEP_CHECK_VERSION}-release.zip

            echo "📦 Extracting Dependency Check"
            unzip -q dependency-check.zip -d odc

            echo "🚀 Running OWASP Dependency Check scan"
            odc/dependency-check/bin/dependency-check.sh \
                --project "MyApp" \
                --scan . \
                --format HTML \
                --out odc-report \
                --nvdApiKey e84fb4cb-dab5-4095-871d-7d53a4363621 \
                --exclude "**/coverage/**" \
                --disableOssIndex \
                --enableExperimental

            echo "✅ Scan completed. Reports available in odc-report/"
            ls -lh odc-report
          '''
        }

        // 📊 Publish report in Jenkins
        publishHTML(target: [
          allowMissing: true,
          keepAll: true,
          alwaysLinkToLastBuild: true,
          reportDir: 'odc-report',
          reportFiles: 'dependency-check-report.html',
          reportName: 'OWASP Dependency Check Report'
        ])
      }
    }

    stage('Gitleaks Scan') {
      when { expression { env.BRANCH_NAME.startsWith("feature/") } }
      steps {
        echo "🔐 Running Gitleaks Scan"
        container('gitleaks') {
          sh '''
            set -e

            echo "📂 Preparing Gitleaks report directory..."
            rm -rf gitleaks-report
            mkdir -p gitleaks-report

            echo "🚀 Running Gitleaks scan (JSON report)..."
            gitleaks detect \
              --source=. \
              --report-format=json \
              --report-path=gitleaks-report/gitleaks-report.json \
              --verbose \
              --redact

            echo "🪄 Converting JSON → HTML for Jenkins UI..."
            REPORT_JSON=gitleaks-report/gitleaks-report.json
            REPORT_HTML=gitleaks-report/gitleaks-report.html

            if [ -s "$REPORT_JSON" ]; then
              echo '<html><body><h3>Gitleaks Scan Report</h3><pre>' > $REPORT_HTML
              cat $REPORT_JSON >> $REPORT_HTML
              echo '</pre></body></html>' >> $REPORT_HTML
            else
              echo '<html><body><h3>Gitleaks Scan Report</h3><p>No leaks found ✅</p></body></html>' > $REPORT_HTML
            fi

            echo "✅ Gitleaks scan completed"
            ls -lh gitleaks-report
          '''
        }

        // 📊 Publish Gitleaks HTML report
        publishHTML(target: [
          allowMissing: true,
          alwaysLinkToLastBuild: true,
          keepAll: true,
          reportDir: 'gitleaks-report',
          reportFiles: 'gitleaks-report.html',
          reportName: 'Gitleaks Secret Scan Report'
        ])
      }
    }

  } // end of stages

  post {
    always {
      echo "🏁 Pipeline completed for branch: ${env.BRANCH_NAME}"
    }
  }
}
