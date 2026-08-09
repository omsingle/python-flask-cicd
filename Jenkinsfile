
pipeline {
    agent any
    stages {
        stage('checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build') {
            steps {
                sh "docker build -t python-flask-cicd:${BUILD_NUMBER} ."
            }
        }
    }
}