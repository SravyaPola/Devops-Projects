pipeline {
    agent any

    environment {
        // We’ll fill in DOCKERHUB_USER and DOCKERHUB_PASS at runtime via credentials,
        // and use BUILD_NUMBER to tag the image uniquely.
        IMAGE_NAME  = "myapp"
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
                sh 'mvn clean package'
            }
            post {
                always {
                    archiveArtifacts artifacts: "target/*.jar", fingerprint: true
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKERHUB_USER',
                        passwordVariable: 'DOCKERHUB_PASS'
                    )]) {
                        sh """
                            # 1) Log in to Docker Hub
                            echo "${DOCKERHUB_PASS}" \
                              | docker login -u "${DOCKERHUB_USER}" --password-stdin

                            # 2) Build the Docker image
                            docker build --pull -t ${FULL_IMAGE} .

                            # 3) Push the image to Docker Hub
                            docker push ${FULL_IMAGE}
                        """
                    }
                }
            }
            post {
                always {
                    // Clean up local image after pushing, so disk doesn’t fill up
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

