#!/bin/bash

set -e

REAL_USER=$(logname || echo "${SUDO_USER}")

log_info() {
    echo -e "[INFO] $1"
}

log_error() {
    echo -e "[ERROR] $1"
}

check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        log_error "Please run with sudo"
        exit 1
    fi
}

install_docker() {
    if command -v docker >/dev/null 2>&1; then
        log_info "Docker is already installed"
        docker --version
    else
        log_info "Installing Docker..."

        log_info "Installing prerequisites..."
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl

        log_info "Setting up Docker repository..."
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc

        log_info "Adding Docker repository to apt sources..."
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
            $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
            sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        sudo apt-get update

        log_info "Installing Docker packages..."
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

        log_info "Docker installation completed:"
        docker --version
    fi

 
    if groups $REAL_USER | grep &>/dev/null "\bdocker\b"; then
        log_info "User $REAL_USER is already in the docker group."
    else
        log_error "User $REAL_USER is not in the docker group."
        log_info "Please run the following command to add the user to the docker group:"
        echo "sudo usermod -aG docker $REAL_USER"
        log_info "To apply the group changes immediately without logging out, run the following command:"
        echo "newgrp docker"
         log_info "After applying the changes, you run the script again."
        exit 1
    fi
}

install_minikube() {
    if command -v minikube >/dev/null 2>&1; then
        log_info "Minikube is already installed"
        minikube version
        return
    fi

    log_info "Installing Minikube..."
    

    log_info "Downloading Minikube..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    

    log_info "Installing Minikube binary..."
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    

    rm minikube-linux-amd64
    

    log_info "Minikube installation completed:"
    minikube version
}

install_kubectl() {
    if command -v kubectl >/dev/null 2>&1; then
        log_info "kubectl is already installed"
        kubectl version --client
        return
    fi

    log_info "Installing kubectl..."
    

    log_info "Downloading kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    

    log_info "Installing kubectl binary..."
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    

    rm kubectl
    

    log_info "kubectl installation completed:"
    kubectl version --client
}

install_helm() {
    if command -v helm >/dev/null 2>&1; then
        log_info "Helm is already installed"
        helm version
        return
    fi

    log_info "Installing Helm..."
    

    log_info "Downloading Helm installation script..."
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    

    log_info "Setting script permissions..."
    chmod 700 get_helm.sh
    

    log_info "Running Helm installation script..."
    ./get_helm.sh
    

    rm get_helm.sh
    

    log_info "Helm installation completed:"
    helm version
}

install_terraform() {
    if command -v terraform >/dev/null 2>&1; then
        log_info "Terraform is already installed"
        terraform version
        return
    fi

    log_info "Installing Terraform..."

    log_info "Installing required packages..."
    sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
    

    log_info "Adding HashiCorp GPG key..."
    wget -O- https://apt.releases.hashicorp.com/gpg | \
        gpg --dearmor | \
        sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
    

    log_info "Verifying GPG key fingerprint..."
    gpg --no-default-keyring \
        --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
        --fingerprint
    

    log_info "Adding HashiCorp repository..."
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        sudo tee /etc/apt/sources.list.d/hashicorp.list
    

    log_info "Updating package information..."
    sudo apt-get update

    log_info "Installing Terraform package..."
    sudo apt-get install -y terraform
    

    log_info "Terraform installation completed:"
      terraform version
}

prompt_user() {
    local prompt="$1"
    while true; do
        read -p "$prompt [y/n]: " response
        case $response in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes (y) or no (n).";;
        esac
    done
}

main() {
    check_sudo

    local install_needed=false
    if ! command -v docker >/dev/null 2>&1 || \
       ! command -v minikube >/dev/null 2>&1 || \
       ! command -v kubectl >/dev/null 2>&1 || \
       ! command -v helm >/dev/null 2>&1 || \
       ! command -v terraform >/dev/null 2>&1; then
        install_needed=true
    fi

    local proceed_with_install=false
    if [ "$install_needed" = true ]; then
        log_info "Some dependencies are missing."
        if prompt_user "Would you like to proceed with installation?"; then
            proceed_with_install=true
        else
            log_info "Installation cancelled."
            exit 0
        fi
    fi
    

    if [ "$proceed_with_install" = true ]; then
        ! command -v docker >/dev/null 2>&1 && install_docker
        ! command -v minikube >/dev/null 2>&1 && install_minikube
        ! command -v kubectl >/dev/null 2>&1 && install_kubectl
        ! command -v helm >/dev/null 2>&1 && install_helm
        ! command -v terraform >/dev/null 2>&1 && install_terraform
        log_info "Installation completed successfully!"
    else
        log_info "All dependencies are already installed!"
    fi
}

main
