
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh "docker build -t yuki982/python-flask-cicd:${BUILD_NUMBER} ."
            }
        }
        stage('Test') {
            steps {
                sh '''docker run -d \
                --name python-flask-test \
                --network jenkins-test \
                yuki982/python-flask-cicd:${BUILD_NUMBER} '''
                retry(15) {
                    sleep 2
                    sh '''curl -f http://python-flask-test:8000/health '''
                }
            }
        }
        stage('docker login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds', 
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD')]) 
                    {
                    sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                }
            }
        }
        stage('Push') {
            steps {
                sh "docker push yuki982/python-flask-cicd:${BUILD_NUMBER}"
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
  
