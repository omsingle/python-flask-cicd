
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
        stage('Test') {
            steps {
                sh "docker run python-flask-cicd:${BUILD_NUMBER} python -m pytest"
            }
        }
        stage('Deploy') {
            steps {
                sh "docker push python-flask-cicd:${BUILD_NUMBER}"
            }
        }
    }
}