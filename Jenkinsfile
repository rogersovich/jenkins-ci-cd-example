pipeline {
    agent any

    environment {
        # Nama image lokal yang akan kita gunakan
        LOCAL_DOCKER_IMAGE = 'hello-express-local:latest'
        # Nama container yang akan dijalankan di host
        CONTAINER_NAME = 'hello-express-container-local'
    }

    stages {
        stage('Checkout') {
            steps {
                # Karena kita menjalankan dari direktori proyek, tidak perlu git clone lagi.
                # Jenkins secara otomatis bekerja di direktori SCM.
                echo 'Skipping Git checkout for local build.'
                # Jika Anda benar-benar ingin Jenkins melakukan checkout, Anda bisa pakai:
                # git branch: 'main', url: 'https://github.com/your-github-username/your-repo-name.git'
                # (tapi pastikan Jenkinsfile ini ada di root repo dan Anda set SCM di Jenkins Job)
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    # Pastikan Dockerfile ada di root proyek
                    sh "docker build -t ${env.LOCAL_DOCKER_IMAGE} ."
                    echo "Docker image ${env.LOCAL_DOCKER_IMAGE} built successfully."
                }
            }
        }
        stage('Run Docker Container Locally') {
            steps {
                script {
                    sh "docker stop ${env.CONTAINER_NAME} || true" // Hentikan container lama
                    sh "docker rm ${env.CONTAINER_NAME} || true"   // Hapus container lama

                    # Jalankan container baru, memetakan port aplikasi (3000)
                    sh "docker run -d --name ${env.CONTAINER_NAME} -p 3000:3000 ${env.LOCAL_DOCKER_IMAGE}"
                    echo "Docker container ${env.CONTAINER_NAME} started on port 3000."
                }
            }
        }
    }
    post {
        always {
            echo 'Local CI/CD Pipeline finished.'
        }
        success {
            echo 'Local build and run successful!'
        }
        failure {
            echo 'Local build or run failed. Check logs.'
        }
    }
}