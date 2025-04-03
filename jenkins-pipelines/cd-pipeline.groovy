pipeline {
    agent any
    environment {
        K8S_NAMESPACE = 'k8s'
        IMAGE_NAME = 'mohamedmorad/library-project'
        IMAGE_TAG = 'latest'
    }
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main',
                    credentialsId: 'github',
                    url: 'https://github.com/Mohamed-Mourad/cls-devops-library.git'
            }
        }
        // stage('Update Deployment Manifest') {
        //     steps {
        //         script {
        //             // Update the image in your backend deployment manifest.
        //             // This example assumes that your backend.yaml contains a line like:
        //             //   image: mohamedmorad/library-project:<old_tag>
        //             // which we replace with the new tag.
        //             sh "sed -i 's|${IMAGE_NAME}:.*|${IMAGE_NAME}:${IMAGE_TAG}|g' k8s/backend.yaml"
        //         }
        //     }
        // }
        stage('Generate Kubeconfig') {
            steps {
                // Generate a temporary kubeconfig file in the workspace
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                  credentialsId: 'aws-credentials']]) {
                      sh 'aws eks --region eu-west-1 update-kubeconfig --name cls-eks-cluster --kubeconfig ./kubeconfig_tmp'
                  }
            }
        }
        stage('Create namespace') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                credentialsId: 'aws-credentials']]) {
                    withEnv(["KUBECONFIG=${env.WORKSPACE}/kubeconfig_tmp"]) {
                        sh '''
                            echo "Creating namespace (if not exists)..."
                            kubectl create namespace ${K8S_NAMESPACE} || echo "Namespace ${K8S_NAMESPACE} already exists"
                        '''
                    }
                }
            }
        }
        stage('Apply kube crt in k8s') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                credentialsId: 'aws-credentials']]) {
                    withEnv(["KUBECONFIG=${env.WORKSPACE}/kubeconfig_tmp"]) {
                        script {
                            // Retrieve the full configmap YAML
                            def configmapYaml = sh(script: "kubectl get configmap kube-root-ca.crt -n kube-public -o yaml", returnStdout: true).trim()
                            
                            // Extract the ca.crt field
                            def caCert = sh(script: "echo '${configmapYaml}' | grep 'ca.crt' | awk '{print \$2}'", returnStdout: true).trim()
        
                            // Check if ca.crt was extracted successfully
                            if (caCert) {
                                // Create or update the configmap with the extracted certificate
                                sh """
                                    kubectl create configmap kube-root-ca.crt --from-literal=ca.crt="${caCert}" -n ${K8S_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
                                """
                            } else {
                                error("The 'ca.crt' field is missing from the kube-root-ca.crt ConfigMap in the kube-public namespace.")
                            }
                        }
                    }
                }
            }
        }
        stage('Deploy to EKS') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                credentialsId: 'aws-credentials']]) {
                    withEnv(["KUBECONFIG=${env.WORKSPACE}/kubeconfig_tmp"]) {
                        sh '''
                            echo "Applying persistent volume and claims..."
                            kubectl apply -f k8s/efs-storageclass.yaml
                            kubectl apply -f k8s/efs-pv.yaml
                            kubectl apply -f k8s/efs-pvc.yaml
                            
                            echo "Deploying Postgres resources..."
                            kubectl apply -f k8s/postgres.yaml -n ${K8S_NAMESPACE}
                            kubectl apply -f k8s/postgres-service.yaml -n ${K8S_NAMESPACE}
                            kubectl apply -f k8s/postgres-secret.yaml -n ${K8S_NAMESPACE}
                            
                            echo "Deploying Backend resources..."
                            kubectl apply -f k8s/backend.yaml -n ${K8S_NAMESPACE}
                            kubectl apply -f k8s/backend-service.yaml -n ${K8S_NAMESPACE}
                            
                            echo "Deploying Ingress configuration..."
                            kubectl apply -f k8s/ingress.yaml -n ${K8S_NAMESPACE}
                        '''
                    }
                }
            }
        }
        stage('Verify Deployment') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                credentialsId: 'aws-credentials']]) {
                    withEnv(["KUBECONFIG=${env.WORKSPACE}/kubeconfig_tmp"]) {
                        // Wait for the backend deployment rollout to complete and list pods.
                        sh 'kubectl rollout status deployment/backend-deployment -n ${K8S_NAMESPACE}'
                        sh 'kubectl get pods -n ${K8S_NAMESPACE}'
                        script {
                            def loadBalancerIP = sh(script: "kubectl get svc -n ${K8S_NAMESPACE} -o jsonpath='{.items[?(@.spec.type==\"LoadBalancer\")].status.loadBalancer.ingress[0].hostname}'", returnStdout: true).trim()
                            def ingressIP = sh(script: "kubectl get ingress -n ${K8S_NAMESPACE} -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}'", returnStdout: true).trim()

                            if (loadBalancerIP) {
                                echo "Your application is available at: http://${loadBalancerIP}"
                            } else if (ingressIP) {
                                echo "Your application is available at: http://${ingressIP}"
                            } else {
                                echo "Could not determine the application URL. Check your Kubernetes services or ingress settings."
                            }
                        }
                    }
                }
            }
        }
    }
    post {
        success {
            echo 'CD Pipeline completed successfully!'
        }
        failure {
            echo 'CD Pipeline failed. Please review the logs.'
        }
    }
}