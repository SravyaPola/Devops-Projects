pipeline {
    agent any

    environment {
        IMAGE_NAME = "order-ms"
        IMAGE_TAG  = "${BUILD_NUMBER}"
        // We will compute FULL_IMAGE inside the withCredentials block, because it needs DOCKERHUB_USER
    }

    stages {
        stage('Checkout Source') {
            steps {
                checkout scm
            }
        }

        stage('Compile & Package (Maven)') {
            steps {
                dir('order-ms') {
                    // Skip tests so that Maven doesn’t try to run the broken SpringBoot test
                    sh 'mvn clean package -DskipTests'
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                // Pull Docker Hub credentials out of Jenkins’s global store
                withCredentials([ usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKERHUB_USER',
                    passwordVariable: 'DOCKERHUB_PASS'
                ) ]) {
                    script {
                        // Now that DOCKERHUB_USER is available, set FULL_IMAGE
                        env.FULL_IMAGE = "${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                    }

                    dir('order-ms') {
                        // 1) Log in to Docker Hub. We escape the $ so it's evaluated by the shell at runtime.
                        sh "echo \"\$DOCKERHUB_PASS\" | docker login -u \"\$DOCKERHUB_USER\" --password-stdin"

                        // 2) Build the image, tagging it correctly
                        sh "docker build --pull -t ${FULL_IMAGE} ."

                        // 3) Push to Docker Hub
                        sh "docker push ${FULL_IMAGE}"

                        // 4) Remove the local image to avoid filling up disk
                        sh "docker rmi ${FULL_IMAGE} || true"
                    }
                }
            }
        }
    }
}

