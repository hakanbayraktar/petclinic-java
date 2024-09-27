pipeline {
    agent any 
    
    environment{
        cred = credentials('aws-key')
        dockerhub_cred = credentials('docker-cred')
        DOCKER_IMAGE = "hbayraktar/petclinic"
        DOCKER_TAG = "$BUILD_NUMBER"
    }
    stages{
        
        stage("Git Checkout"){
            steps{
                git branch: 'main', changelog: false, poll: false, url: 'https://github.com/hakanbayraktar/Petclinic.git'
            }
        }
        
        stage(" MVN build"){
            steps{
                sh "mvn clean install -Dmaven.test.skip=true"
            }
        }
        
        }
        
        stage("Docker Build & Push"){
            steps{
                script{
                   withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {
                        
                        sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                        sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG} "
                    }
                }
            }
        }
        
        stage("Update Kubernetes Manifest"){
            steps{
                sh "sed -i 's|hbayraktar/petclinix:latest|${DOCKER_IMAGE}:${DOCKER_TAG}|' manifest/deployment.yaml"
            }
        }
        stage("Deploy To EKS"){
            steps{
                sh 'aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster'
                sh 'kubectl apply -f manifest/deployment.yaml'
            }
        }
    }
    post {
        always {
            echo "Job is completed"
        }
        success {
            echo "It is a success"
        }
        failure {
            echo "Job is failed"
        }
    }
}
