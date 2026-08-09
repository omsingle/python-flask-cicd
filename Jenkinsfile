
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh "docker build -t python-flask-cicd:${BUILD_NUMBER} ."
            }
        }
        stage('Test') {
            steps {
                sh '''docker run -d \
                --name python-flask-test \
                -p 8001:8000 \
                python-flask-cicd:${BUILD_NUMBER} '''
                sh "sleep 10"
                sh '''curl -f http://localhost:8001/health '''
            }
        }
    }
        post {
            always {
                sh "docker stop python-flask-test || true"
                sh "docker rm python-flask-test || true"
            }
        }
    }
