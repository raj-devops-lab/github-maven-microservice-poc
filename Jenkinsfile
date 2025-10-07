pipeline {
  agent {
    kubernetes {
      label 'dynamic-agent'      
    }
  }
    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10', daysToKeepStr: '30', artifactNumToKeepStr: '5'))
        timeout(time: 60, unit: 'MINUTES')
        skipDefaultCheckout(false)
    }

    environment {
        DOCKER_IMAGE = "spring-app:v2"
        DEVTRON_URL = 'http://80.225.201.22:8000/orchestrator/webhook/ext-ci/2'
    }

    stages {
        stage('Checkout') {
            steps {
                echo "🔄 Checking out branch: ${env.BRANCH_NAME}"
                checkout scm
            }
        }

//         stage('Validate Commit Message') {
//     when { expression { env.BRANCH_NAME.startsWith("feature/") } }
//     steps {
//         script {
//             // Get the latest commit message
//             def commitMsg = sh(
//                 script: "git log -1 --pretty=%B",
//                 returnStdout: true
//             ).trim()

//             echo "Latest commit message: ${commitMsg}"

//             // Split by '#' to separate message and Jira ID
//             def parts = commitMsg.split('#')

//             if (parts.length != 2) {
//                 error "❌ Commit message must contain a '#' followed by Jira ID!"
//             }

//             def msgText = parts[0].trim()
//             def jiraId = parts[1].trim()

//             // Check message length
//             if (msgText.length() < 30) {
//                 error "❌ Commit message text must be at least 30 characters!"
//             }

//             // Check Jira ID format (e.g., ABC-123)
//             if (!jiraId.matches("[A-Z]{2,}-\\d+")) {
//                 error "❌ Jira ID after '#' is invalid! Example: ABC-123"
//             }

//             echo "✅ Commit message validation passed"
//         }
//     }
// }


        stage('Version Management') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'develop') {
                        echo "Develop branch: updating version.txt"
                    } else if (env.BRANCH_NAME.startsWith("feature/")) {
                        echo "Feature branch: pulling latest version.txt from develop"
                    }
                }
            }
        }
        
        stage('Build') {
        when {
        anyOf {
            expression { env.BRANCH_NAME.startsWith("feature/") }
            branch 'develop'
        }
    }
    steps {
        echo "🚀 Running Maven Build for branch: ${env.BRANCH_NAME}"
        container('maven') {
            sh 'mvn clean install'
        }
    }
}

        stage('Run Tests') {
            when { expression { env.BRANCH_NAME.startsWith("feature/") } }
            steps {
                echo "Running Unit Tests"
                container('maven') {
                   sh 'mvn test'
                   junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        
        stage('SonarQube Scan') {
            when { expression { env.BRANCH_NAME.startsWith("feature/") } }
            steps { echo "Running SonarQube Scan" }
        }

stage('OWASP Dependency Check') {
    when { expression { env.BRANCH_NAME.startsWith("feature/") } }
    steps {
        echo "🛡️ Running OWASP Dependency Check for Maven project"
        container('maven') {
            sh '''
                set -e

                echo "⬇️ Running OWASP Dependency Check via Maven plugin..."
                
                # Add OWASP Dependency Check plugin execution
                mvn org.owasp:dependency-check-maven:12.1.0:check \
                    -Dformat=HTML \
                    -DoutputDirectory=odc-report \
                    -DnvdApiKey=e84fb4cb-dab5-4095-871d-7d53a4363621
                
                echo "✅ Dependency Check completed. Reports available in odc-report/"
                ls -lh odc-report || true
            '''
        }

        // Optional: publish HTML report in Jenkins UI
        publishHTML(target: [
            reportDir: 'odc-report',
            reportFiles: 'dependency-check-report.html',
            reportName: '🛡️ OWASP Dependency Check Report',
            allowMissing: true,
            alwaysLinkToLastBuild: true,
            keepAll: true
        ])
    }
}


        stage('Gitleaks Scan') {
            when { expression { env.BRANCH_NAME.startsWith("feature/") } }
            steps { echo "Running Gitleaks Scan" }
        }

        // stage('Build Docker Image') {
        //     when { branch 'develop' }
        //     steps {
        //         container('docker') {
        //             echo "Building Docker image from pre-built JAR..."
        //             sh """
        //                 docker build -t ${DOCKER_IMAGE} .
        //             """
        //         }
        //     }
        // }

    //     stage('Push Docker Image') {
    //         when { branch 'develop' }
    //         steps {
    //             container('docker') {
    //                 echo "🚀 Pushing Docker image to Docker Hub"
    //         // Login using Jenkins credentials
    //         withCredentials([usernamePassword(credentialsId: 'docker-hub-creds',
    //                                        usernameVariable: 'DOCKER_USER',
    //                                        passwordVariable: 'DOCKER_PASS')]) {
    //         sh """
    //           echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin 
    //           docker tag ${DOCKER_IMAGE} ${DOCKER_USER}/${DOCKER_IMAGE}
    //           docker push ${DOCKER_USER}/${DOCKER_IMAGE}
    //           docker logout 
    //         """
    //       }
    //     }
    //   }
    // }


        // stage('Version Push') {
        //     when { branch 'develop' }
        //     steps { echo "Pushing updated version.txt from develop" }
        }
    }

    post {
        // success {
        //     script {
        //         if (env.BRANCH_NAME == 'develop') {
        //             echo "🚀 Develop branch → Triggering Devtron Deployment"
        //             withCredentials([string(credentialsId: 'DEVTRON-TOKEN', variable: 'DEVTRON_TOKEN')]) {
        //                 sh """
        //                     curl --location --request POST "$DEVTRON_URL" \
        //                          --header "Content-Type: application/json" \
        //                          --header "api-token: $DEVTRON_TOKEN" \
        //                          --data-raw '{
        //                              "dockerImage": "gauravt11/${DOCKER_IMAGE}"
        //                          }'
        //                 """
        //             }
        //         } else {
        //             echo "ℹ️ Not on develop branch → Devtron trigger skipped"
        //         }
        //     }
        // }
        always {
            echo "✅ Pipeline finished for branch: ${env.BRANCH_NAME}"
            // container('maven') {
                // archiveArtifacts artifacts: 'target/**', allowEmptyArchive: true
            // }
        }
    }
}