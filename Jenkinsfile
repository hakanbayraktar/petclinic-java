pipeline {
    agent any 
    
    environment{
        cred = credentials('aws-key') // AWS access key için tanımlı credential
        dockerhub_cred = credentials('docker-cred') // Docker Hub için tanımlı credential
        DOCKER_IMAGE = "hbayraktar/petclinic"
        DOCKER_TAG = "$BUILD_NUMBER"
        SONARQUBE_URL = 'http://localhost:9000'
        SONAR_TOKEN = credentials('SONAR_TOKEN')
    }
    stages{
        
        stage("Git Checkout"){ // Repository checkout işlemi
            steps{
                git branch: 'main', changelog: false, poll: false, url: 'https://github.com/hakanbayraktar/petclinic-java.git'
            }
        }
          stage('SonarQube Analysis') {
            steps {
                sh """
                    mvn sonar:sonar \
                    -Dsonar.projectKey=petclinic-java \
                    -Dsonar.host.url=${SONARQUBE_URL} \
                    -Dsonar.login=${SONAR_TOKEN}
                """
            }
        }
        /*
        stage("OWASP Dependency Check") {
            steps {
                script {
                    dependencyCheck additionalArguments: '--failOnCVSS=5 --format HTML', odcInstallation: 'DP'
                    dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
                }
            }
        }

       */
       stage("MVN build"){ // Maven build aşaması
            steps{
                sh "mvn clean install -Dmaven.test.skip=true"
            }
        }
        
       stage("Docker Build & Push"){ // Docker image build ve push aşaması
            steps{
                script{
                   withDockerRegistry(credentialsId: 'docker-cred', toolName: 'docker') {                        
                        sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                        sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    }
                }
            }
        }
        
        stage("Update Kubernetes Manifest"){ // Kubernetes manifest dosyasını güncelleme
            steps{
                sh "sed -i 's|hbayraktar/petclinic:latest|${DOCKER_IMAGE}:${DOCKER_TAG}|' manifest/deployment.yaml"
            }
        }
        stage("TRIVY"){
            steps{
                sh " trivy image adijaiswal/pet-clinic123:latest"
            }
        }
        stage("Deploy To EKS"){ // EKS'e deployment yapma
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
    
