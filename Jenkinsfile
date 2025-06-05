pipeline {
    agent any

    environment {
        IMAGE_NAME = "order-ms"
        IMAGE_TAG  = "${BUILD_NUMBER}"
        // FULL_IMAGE will be set once we have DOCKERHUB_USER from credentials
        FULL_IMAGE = ""
    }

    stages {
        stage('Checkout Source') {
            steps {
                checkout scm
            }
        }

        stage('Compile & Test (Maven)') {
            steps {
                dir('order-ms') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }

        stage('Build, Tag & Push Docker Image') {
            steps {
                // Assume you created a Jenkins “Username with password” credential
                // with ID = "dockerhub-creds"
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKERHUB_USER',
                    passwordVariable: 'DOCKERHUB_PASS'
                )]) {
                    script {
                        // Now that DOCKERHUB_USER is available, set FULL_IMAGE
                        env.FULL_IMAGE = "${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                    }
                    dir('order-ms') {
                        sh '''
                            # 1) Log in to Docker Hub using the stored credential
                            echo "$DOCKERHUB_PASS" \
                              | docker login -u "$DOCKERHUB_USER" --password-stdin

                            # 2) Build the Docker image
                            docker build --pull -t $FULL_IMAGE .

                            # 3) Push the image to Docker Hub
                            docker push $FULL_IMAGE

                            # 4) Clean up local image
                            docker rmi $FULL_IMAGE || true
                        '''
                    }
                }
            }
        }
    }
}

