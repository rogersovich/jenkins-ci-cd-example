pipeline {
    agent any

    environment {
        // Nama aplikasi Docker Anda
        APP_NAME = 'simple-express-app'
        // Port host yang akan mapping ke port internal container (3000)
        HOST_PORT = '3333'
        // Port internal container yang diekspos di Dockerfile
        CONTAINER_PORT = '3000'
        // Definisi label untuk identifikasi image Jenkins
        JENKINS_LABEL_KEY = 'jenkins-build-id'
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
                    // Menggunakan BUILD_NUMBER Jenkins sebagai nilai label
                    def jenkinsBuildLabel = "${JENKINS_LABEL_KEY}=${env.BUILD_NUMBER}"

                    echo "Building Docker image: ${dockerImageTag} with label: ${jenkinsBuildLabel}"
                    sh "docker build -t ${dockerImageTag} --label ${jenkinsBuildLabel} ."
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
                    echo "Cleaning up old Docker images..."

                    // Dapatkan semua tag image untuk APP_NAME
                    def allTags = sh(returnStdout: true, script: "docker images --format '{{.Tag}}' ${APP_NAME}").trim().split('\n')
                    def imagesToRemove = []

                    // Iterasi melalui setiap tag
                    allTags.each { tag ->
                        // Pastikan tag adalah angka dan kurang dari BUILD_NUMBER saat ini
                        try {
                            if (tag.isInteger() && tag.toInteger() < env.BUILD_NUMBER.toInteger()) {
                                imagesToRemove.add("${APP_NAME}:${tag}")
                            }
                        } catch (NumberFormatException e) {
                            // Abaikan tag yang bukan angka (misal: "latest" atau tag lain)
                            echo "Skipping non-numeric tag: ${tag}"
                        }
                    }

                     if (imagesToRemove) {
                        echo "Found old images to remove: ${imagesToRemove.join(' ')}"
                        // Hapus image yang teridentifikasi
                        // Gunakan -f (force) agar tidak ada konfirmasi
                        sh "docker rmi -f ${imagesToRemove.join(' ')} || true"
                        echo "Old images cleaned."
                    } else {
                        echo "No old images found with tags less than ${env.BUILD_NUMBER}."
                    }

                    // 2. Membersihkan dangling images (image tanpa tag atau tidak terkait container/image lain)
                    echo "Cleaning up any dangling images..."
                    sh "docker image prune -f"

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