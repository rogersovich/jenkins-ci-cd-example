pipeline {
    agent any

    environment {
        // Nama aplikasi Docker Anda
        APP_NAME = 'simple-express-app'
        // Port host yang akan mapping ke port internal container (3000)
        HOST_PORT = '3333'
        // Port internal container yang diekspos di Dockerfile
        CONTAINER_PORT = '3000'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/rogersovich/jenkins-ci-cd-example.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Membuat nama tag unik menggunakan BUILD_NUMBER Jenkins
                    def dockerImageTag = "${APP_NAME}:${env.BUILD_NUMBER}"
                    echo "Building Docker image: ${dockerImageTag}"
                    sh "docker build -t ${dockerImageTag} ."
                    echo "Docker image built successfully!"
                }
            }
        }

        stage('Deploy Docker Container') {
            steps {
                script {
                    // Hentikan dan hapus container lama jika ada
                    echo "Stopping and removing old container (if exists)..."
                    sh "docker stop ${APP_NAME} || true" // '|| true' agar tidak error jika container tidak ada
                    sh "docker rm ${APP_NAME} || true"

                    // Jalankan container baru
                    echo "Running new Docker container..."
                    sh "docker run -d --name ${APP_NAME} -p ${HOST_PORT}:${CONTAINER_PORT} ${APP_NAME}:${env.BUILD_NUMBER}"
                    echo "Docker container deployed successfully on port ${HOST_PORT}!"
                }
            }
        }

        stage('Cleanup Old Docker Images') {
            steps {
                script {
                    // Opsional: Hapus image Docker lama untuk menghemat ruang disk
                    echo "Cleaning up old Docker images..."
                    sh "docker image prune -f --filter 'label=jenkins-build-id'" // Contoh filter, bisa disesuaikan
                    // Atau yang lebih agresif (hati-hati):
                    // sh "docker rmi \$(docker images -q ${APP_NAME} | grep -v ${env.BUILD_NUMBER}) || true"
                    echo "Old Docker images cleaned."
                }
            }
        }
    }

    post {
        always {
            // Notifikasi selalu
            echo "Pipeline finished for ${APP_NAME}."
        }
        success {
            echo "Deployment successful!"
        }
        failure {
            echo "Deployment failed! Check build logs for errors."
        }
    }
}