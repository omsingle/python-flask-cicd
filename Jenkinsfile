
pipeline {
    agent any
    environment {
    KUBECONFIG = '/home/asus/.kube/config'
}
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
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                export KUBECONFIG=$WORKSPACE/kubeconfig

                kubectl config set-cluster jenkins-k8s \
                    --server=http://172.17.0.1:8001

                kubectl config set-credentials jenkins

                kubectl config set-context jenkins-k8s \
                    --cluster=jenkins-k8s \
                    --user=jenkins

                kubectl config use-context jenkins-k8s

                kubectl set image deployment/python-flask-cicd \
                python-flask-cicd=yuki982/python-flask-cicd:${BUILD_NUMBER}

                kubectl rollout status deployment/python-flask-cicd --timeout=120s
                '''
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
  
