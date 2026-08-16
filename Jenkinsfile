
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
                -p 8000:8000 \
                yuki982/python-flask-cicd:${BUILD_NUMBER} '''

                retry(15) {
                    sleep 2
                    sh '''curl -f http://localhost:8000/health '''
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
            rm -f $KUBECONFIG

            kubectl config set-cluster minikube \
                --server=http://172.31.103.99:8001

            kubectl config set-context minikube \
                --cluster=minikube \
                --namespace=default

            kubectl config use-context minikube

            kubectl set image deployment/python-flask-cicd \
                python-flask-cicd=yuki982/python-flask-cicd:${BUILD_NUMBER}

            kubectl rollout status deployment/python-flask-cicd \
                --timeout=120s
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
  
