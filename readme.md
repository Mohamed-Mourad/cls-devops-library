# 📚 Library Project - DevOps Setup

Welcome to the **Library Project**!  
This repository contains everything you need for a complete CI/CD workflow, infrastructure management, and Kubernetes deployment.

---

## 📂 Project Structure

```bash
.
├── jenkins-pipelines/
│   ├── ci-pipeline.groovy       # Jenkins CI pipeline (build & push Docker image)
│   ├── cd-pipeline.groovy       # Jenkins CD pipeline (deploy to EKS)
│   └── README.md                # Jenkins pipelines usage documentation
│
├── k8s/
│   ├── base/                    # Base Kubernetes manifests
│   ├── overlays/
│   │   └── dev/                 # Kustomize overlay for development environment
│   └── README.md                # Kubernetes manifests & Kustomize usage guide
│
├── terraform/
│   ├── eks-cluster/             # Terraform for AWS EKS cluster
│   ├── efs-storage/             # Terraform for Amazon EFS setup
│   └── README.md                # Terraform deployment guide
│
└── README.md                    # (This file) Project overview and getting started
```

---

## 🚀 Project Scope

This project automates the full lifecycle from code to deployment:

1. **Continuous Integration (CI)**  
   - Jenkins pipeline (`ci-pipeline.groovy`) automatically:
     - Clones the code from GitHub.
     - Builds a Docker image.
     - Pushes the Docker image to DockerHub.

2. **Continuous Deployment (CD)**  
   - Jenkins pipeline (`cd-pipeline.groovy`) automatically:
     - Clones the code again for deployment.
     - Connects to AWS EKS (via generated kubeconfig).
     - Creates the namespace if missing.
     - Applies Kubernetes manifests using **Kustomize** with EFS integration.
     - Verifies the application deployment and provides access information.

3. **Infrastructure as Code (IaC)**  
   - **Terraform** is used to:
     - Create the EKS Cluster (Amazon Elastic Kubernetes Service).
     - Set up EFS (Elastic File System) for persistent storage.
     - Manage other AWS resources cleanly and reproducibly.

4. **Kubernetes Deployment**  
   - Kubernetes manifests are structured using **Kustomize** for better environment management.
   - EFS storage integration is handled dynamically through environment variables.

---

## 🛠️ Tools and Technologies

- **Jenkins** (Pipelines for CI/CD)
- **Docker** (Containerization)
- **AWS EKS** (Managed Kubernetes)
- **AWS EFS** (Persistent storage)
- **Terraform** (Infrastructure as Code)
- **Kubernetes + Kustomize** (Deployment management)
- **GitHub** (Source code management)

---

## 📋 Prerequisites

- Jenkins server configured with:
  - Docker
  - AWS CLI
  - kubectl
  - kustomize
- DockerHub account for pushing images
- AWS credentials for EKS and EFS
- Terraform installed locally or on a CI/CD runner
- Kubernetes cluster created via Terraform

---

## 🏁 Getting Started

1. **Deploy infrastructure**  
   Follow the steps in `terraform/README.md` to provision AWS resources.

2. **Build and Push Docker image**  
   Trigger the **CI Pipeline** via Jenkins (`ci-pipeline.groovy`).

3. **Deploy to Kubernetes**  
   Trigger the **CD Pipeline** via Jenkins (`cd-pipeline.groovy`).

4. **Access the application**  
   Once deployed, the application will be accessible via the LoadBalancer IP or Ingress hostname.

---

## 🤝 Contributions

Feel free to open issues or pull requests if you want to contribute!

---

## 📜 License

This project is licensed under the MIT License.
