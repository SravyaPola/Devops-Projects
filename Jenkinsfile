pipeline {
    agent any

    environment {
        // Hard-coded Docker Hub creds (not recommended for long-term, but as requested)
        DOCKERHUB_USER = "your_dockerhub_username"
        DOCKERHUB_PASS = "your_dockerhub_password_or_token"

        // Image name (will push to DOCKERHUB_USER/IMAGE_NAME:BUILD_NUMBER)
        IMAGE_NAME  = "order-ms"
        IMAGE_TAG   = "${env.BUILD_NUMBER}"
        FULL_IMAGE  = "${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Maven Package') {
            steps {
                // Switch into order-ms/ before running Maven
                dir('order-ms') {
                    sh 'mvn clean package'
                }
            }
            post {
                always {
                    // Archive the JAR/WAR that Maven produced
                    archiveArtifacts artifacts: 'order-ms/target/*.jar', fingerprint: true
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    // Everything in the order-ms/ folder: Dockerfile should also be here
                    dir('order-ms') {
                        sh """
                            # 1) Log in to Docker Hub
                            echo "${DOCKERHUB_PASS}" | docker login -u "${DOCKERHUB_USER}" --password-stdin

                            # 2) Build the Docker image from order-ms/Dockerfile
                            docker build --pull -t ${FULL_IMAGE} .

                            # 3) Push it up
                            docker push ${FULL_IMAGE}
                        """
                    }
                }
            }
            post {
                always {
                    // Clean up local image to save disk space
                    sh "docker rmi ${FULL_IMAGE} || true"
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline succeeded. Image pushed: ${FULL_IMAGE}"
        }
        failure {
            echo "Pipeline failed."
        }
    }
}

