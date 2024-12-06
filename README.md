# SonarQube Kubernetes Deployment

This repository contains the necessary configuration files and scripts to deploy SonarQube on a Kubernetes cluster using Docker and Minikube. The deployment uses Helm charts and includes configurations for PostgreSQL database integration.





## Prerequisites
- Ubuntu system


## Usage

1. **set teraform secret**:
   -use `terraform.tfstate-example` file to set postgres passwords. Then rename the file to `terraform.tfstate` and move the file to the `terraform/` directory.

   

2. **Deploy SonarQube**:
     - Run the `run.sh` script to install necessary dependencies and configure the environment. This script will check if you have dependencies installed and if not, it will install them. If Docker installation is needed, you will need to restart your shell session to apply the Docker group changes and then run the script again. 

     ```bash
     sudo bash run.sh
     ```
    - The `run.sh` script will then proceed to deploy SonarQube on your Kubernetes cluster.
     

3. **Access SonarQube**:
   - Once the deployment is complete, access SonarQube through the ingress controller by the url sonar.test.com.




## Dependencies

- Docker
- Kubernetes cluster (v1.19+)
- Helm v3.0+
- kubectl


## Components and Versions

- SonarQube v9.9.1 (Current deployment version)
- Helm Chart version: 8.9.5
- PostgreSQL 13+ (External database)
- Kubernetes v1.19+
- Helm v3.0+

## Directory Structure

```
sonarqube-k8s-deployment/
├── values/              # Helm values files
│   └── sonarqube.yaml  # SonarQube configuration
├── scripts/            # Deployment scripts
├── terraform/          # Infrastructure as Code
└── run.sh             # Main deployment script
```

#

The default credentials for SonarQube are:
- Username: admin
- Password: admin
