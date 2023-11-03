## this the jenkins file code to  checkout the code from the git and then build the docker file and then push it to ecr and then 
pipeline {
  environment {
    registry = '444320815966.dkr.ecr.ap-south-1.amazonaws.com/collection_parking_logic_uat'
    registryCredential = 'WheelsEMI-prod-cluster'
  }
  
  agent any
  
  stages {
    stage("Removing Previous Build") {
      steps {
        echo "CLEANING PREVIOUS RUNNING PROCESS"
        // sh 'docker ps'
        // sh 'docker stop collection_parking_logic'
        // sh 'docker rm collection_parking_logic'
        echo "Cleanup Done"
      }
    }
    
    stage("Docker Build Image") {
      steps {
        sh 'docker version'
        sh 'whoami'
        sh 'pwd'
        sh 'ls -lrt'
        sh 'ifconfig'
        sh 'docker build -t $registry:latest .'
        sh 'docker image list'
      }
    }
    
    stage('Push Image to ECR') {
      steps {
        withAWS(credentials: registryCredential, region: 'ap-south-1') {
          sh "aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin $registry"
          sh 'docker push $registry:latest'
        }
      }
    }
    
    stage('Deploy to K8s') {
      steps {
	withAWS(credentials: registryCredential, region: 'ap-south-1') {
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
  }

  post {
    always {
      cleanWs()
      echo "Workspace cleaned"
      // sh "docker rmi $registry:latest"
    }
  }
}
