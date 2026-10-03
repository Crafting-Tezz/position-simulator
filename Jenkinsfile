// CI/CD pipeline for the position-simulator microservice (doc pages 73-75, updated):
//  - Maven builds the jar, then Docker packages it
//  - images go to Docker Hub user motez00 via the 'dockerhub' Jenkins credential
//  - deploys only this service's manifest (k8s/deployment.yaml)
def commit_id

pipeline {
    agent any

    environment {
        IMAGE = 'motez00/fleetman-position-simulator'
    }

    stages {
        stage('Preparation') {
            steps {
                checkout scm
                sh 'git rev-parse --short HEAD > .git/commit-id'
                script {
                    commit_id = readFile('.git/commit-id').trim()
                }
            }
        }

        stage('Build') {
            steps {
                echo 'Building the jar with Maven'
                sh 'mvn -B clean install'
            }
        }

        stage('Image Build') {
            steps {
                echo "Building ${IMAGE}:${commit_id}"
                sh "docker build -t ${IMAGE}:${commit_id} -t ${IMAGE}:latest ."
            }
        }

        stage('Image Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub',
                                                  usernameVariable: 'DOCKER_USER',
                                                  passwordVariable: 'DOCKER_TOKEN')]) {
                    // single quotes: the shell expands the secret, Groovy never sees it
                    sh 'echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_USER" --password-stdin'
                    sh "docker push ${IMAGE}:${commit_id}"
                    sh "docker push ${IMAGE}:latest"
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying to Kubernetes'
                sh "sed -i 's|${IMAGE}:.*|${IMAGE}:${commit_id}|' k8s/deployment.yaml"
                sh 'kubectl apply -f k8s/'
                sh 'kubectl rollout status deployment/position-simulator --timeout=180s'
                sh 'kubectl get pods -l app=position-simulator -o wide'
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
    }
}
