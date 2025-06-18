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
                    // Opsional: Hapus image Docker lama untuk menghemat ruang disk
                    echo "Cleaning up old Docker images..."

                    // 1. Membersihkan image dengan label Jenkins yang tidak sesuai dengan BUILD_NUMBER saat ini
                    //    Ini akan menghapus image yang dibuat oleh Jenkins di build sebelumnya
                    def imagesWithOldLabels = sh(returnStdout: true, script: """
                        docker images --filter 'label=${JENKINS_LABEL_KEY}' --format '{{.ID}}' | xargs -r docker inspect --format '{{.RepoTags}} {{.Config.Labels.${JENKINS_LABEL_KEY}}}' | \
                        awk -v current_build="${env.BUILD_NUMBER}" '\$2 != current_build { print \$1 }'
                    """).trim()

                    if (imagesWithOldLabels) {
                        echo "Found images with old Jenkins build labels to remove: ${imagesWithOldLabels}"
                        sh "docker rmi ${imagesWithOldLabels} || true"
                    } else {
                        echo "No old Jenkins-labeled images found to remove."
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