#!/bin/bash

set -e



SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TERRAFORM_DIR="${PROJECT_ROOT}/terraform"

if [ ! -d "$TERRAFORM_DIR" ]; then
    echo "Error: Terraform directory not found: $TERRAFORM_DIR"
    exit 1
fi

if ! minikube status >/dev/null 2>&1; then
    echo "Starting Minikube..."
    minikube start --driver=docker --cpus=2 --memory=4096
fi

echo "Enabling ingress..."
minikube addons enable ingress

cd "$TERRAFORM_DIR" || exit 1

echo "Initializing Terraform..."
terraform init

echo "Planning Terraform changes..."
terraform plan

echo "Applying Terraform changes..."
terraform apply -auto-approve

echo -e "\nDeployment completed!"
echo "Default credentials: admin/admin"
echo -e "\nService URL:"
SONARQUBE_URL=$(minikube service sonarqube-sonarqube -n sonarqube --url)
echo "SonarQube is accessible at: $SONARQUBE_URL"

