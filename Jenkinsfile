##this pipeline basically builds the docker image the push it to the ECR repositry and then deploy the image into the EKS environment.
pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID = "444320815966"
        AWS_DEFAULT_REGION = "ap-south-1"
        IMAGE_REPO_NAME = "collection_parking_logic_uat"
		IMAGE_TAG="latest"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
    }
   
    stages {
        stage('Removing Previous Build') {
            steps {
                echo "CLEANING PREVIOUS RUNNING PROCESS"
                echo "Cleanup Done"
            }
        }
        
        stage('Docker Build Image') {
            steps {
                script {
                    sh 'docker version'
                    sh 'whoami'
                    sh 'pwd'
                    sh 'ls -lrt'
                    sh 'ifconfig'
                    sh 'docker.build "${IMAGE_REPO_NAME}:${IMAGE_TAG}"
                    sh "docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:$IMAGE_TAG"
                    sh 'docker image list'
                }
            }
        }
        
        stage('Push Image to ECR') {
            steps {
                script {
				    sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                    sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${IMAGE_TAG}"
                }
            }
        }
        
        stage('Deploy to K8s') {
            steps {
                echo "Deployment started..."
                sh 'whoami'
                sh 'pwd'
                sh 'ls -lrt'
                sh 'ifconfig'
                sh 'kubectl apply -f deployment.yaml'
                sh 'kubectl apply -f service.yaml'
                sh 'kubectl get pods'
                sh 'kubectl get svc'
            }
        }
    }
 
    post {
        always {
            cleanWs()
            echo "Workspace cleaned"
        }
    }
}
