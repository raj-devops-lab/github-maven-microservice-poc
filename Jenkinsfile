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
    image: ghcr.io/owasp/dependency-check:latest
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
      when { expression { false } } // skip for now if tests not ready
      steps {
        container('maven') {
          sh 'mvn test'
        }
      }
    }

    // 🛡️ OWASP Dependency Check for Java
    stage('OWASP Dependency Check') {
      when { expression { env.BRANCH_NAME.startsWith("feature/") } }
      steps {
        echo "🛡️ Running OWASP Dependency Check for Java project"
        container('owasp') {
          sh '''
            set -e

            echo "📂 Preparing report directory..."
            mkdir -p dependency-check-report

            echo "🚀 Running OWASP Dependency Check..."
            dependency-check.sh \
              --project "JavaApp-${BRANCH_NAME}" \
              --scan . \
              --format "HTML" \
              --out dependency-check-report \
              --enableExperimental \
              --disableOssIndex \
              --nvdApiKey=e84fb4cb-dab5-4095-871d-7d53a4363621

            echo "✅ OWASP Dependency Check completed. Reports saved to dependency-check-report/"
            ls -lh dependency-check-report || true
          '''
        }

        publishHTML(target: [
            reportDir: 'dependency-check-report',
            reportFiles: 'dependency-check-report.html',
            reportName: '🛡️ OWASP Dependency Check Report',
            allowMissing: true,
            alwaysLinkToLastBuild: true,
            keepAll: true
        ])
      }
    }

    // 🔐 Gitleaks Secret Scan
    stage('Gitleaks Scan') {
      when { expression { env.BRANCH_NAME.startsWith("feature/") } }
      agent {
        kubernetes {
          yaml """
apiVersion: v1
kind: Pod
spec:
  imagePullSecrets:
    - name: dockerhub-secret
  containers:
    - name: node
      image: node:18
      command: ['cat']
      tty: true
    - name: gitleaks
      image: ghcr.io/gitleaks/gitleaks:latest
      command: ['cat']
      tty: true
"""
        }
      }
      steps {
        container('gitleaks') {
          sh '''
            set -e
            set -x

            echo "📂 Preparing Gitleaks report directory..."
            rm -rf gitleaks-report
            mkdir -p gitleaks-report

            echo "🚀 Running Gitleaks scan (JSON report)..."
            gitleaks detect \
                --source=. \
                --report-format=json \
                --report-path=gitleaks-report/gitleaks-report.json \
                --verbose \
                --redact || true

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

        publishHTML(target: [
            allowMissing: true,
            alwaysLinkToLastBuild: true,
            keepAll: true,
            reportDir: 'gitleaks-report',
            reportFiles: 'gitleaks-report.html',
            reportName: 'Gitleaks Secret Scan Report'
        ])
      }

      post {
        success {
          echo "✅ Gitleaks scan stage completed successfully."
        }

        always {
          echo "📦 Archiving Gitleaks report artifacts..."
          archiveArtifacts artifacts: 'gitleaks-report/**', fingerprint: true

          echo "📜 Checking for leaked files..."
          sh '''
            if [ -s gitleaks-report/gitleaks-report.json ]; then
              echo "⚠️  Potential leaks detected:"
              cat gitleaks-report/gitleaks-report.json | jq -r '.[] | "\\(.File):\\(.StartLine) -> \\(.RuleID)"'
            else
              echo "✅ No secrets found in the scan."
            fi
          '''
        }

        unstable {
          echo "⚠️ Marking build as UNSTABLE due to Gitleaks findings."
        }

        failure {
          echo "❌ Gitleaks scan failed. Please check the logs."
        }
      }
    }

  } // end stages

  post {
    always {
      echo "✅ Pipeline finished for branch: ${env.BRANCH_NAME}"
      echo "📄 Reports (if any) are in the workspace directory."
    }
  }
}
