pipeline {
    agent any

    environment {
        IMAGE_NAME = "order-ms"
    }

    stages {
        stage('Checkout') {
            steps {
                // Uses the SCM settings you configured in the Jenkins Job (polling main)
                checkout scm
            }
        }

        stage('Build with Maven') {
            steps {
                // Go into order-ms/ and run Maven to produce the JAR in target/
                dir('order-ms') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                // Grab your Docker Hub creds (Username/Password) by ID
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKERHUB_USER',
                    passwordVariable: 'DOCKERHUB_PASS'
                )]) {
                    // From the repo root (where Dockerfile lives), build and push:
                    sh """
                        echo "\$DOCKERHUB_PASS" | docker login -u "\$DOCKERHUB_USER" --password-stdin
                        docker build -t \$DOCKERHUB_USER/${IMAGE_NAME}:\$BUILD_NUMBER .
                        docker push \$DOCKERHUB_USER/${IMAGE_NAME}:\$BUILD_NUMBER
                        docker rmi \$DOCKERHUB_USER/${IMAGE_NAME}:\$BUILD_NUMBER || true
                    """
                }
            }
        }
    }
}

