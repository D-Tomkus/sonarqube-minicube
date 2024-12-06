#!/bin/bash

export GREEN='\033[0;32m'
export RED='\033[0;31m'
export NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}
export -f log_info

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}
export -f log_error

REAL_USER=$(logname || echo "${SUDO_USER}")

check_script() {
    local script=$1
    if [ ! -f "$script" ]; then
        log_error "Script not found: $script"
        exit 1
    fi
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SETUP_SCRIPT="${SCRIPT_DIR}/scripts/setup.sh"
TERRAFORM_DEPLOY_SCRIPT="${SCRIPT_DIR}/scripts/terraform-deploy.sh"

check_script "$SETUP_SCRIPT"
check_script "$TERRAFORM_DEPLOY_SCRIPT"

log_info "Running setup script..."
if ! sudo bash "$SETUP_SCRIPT"; then
    log_error "Setup script failed"
    exit 1
fi

log_info "Running terraform deploy script..."
if ! sudo -u "${REAL_USER}" bash "$TERRAFORM_DEPLOY_SCRIPT"; then
    log_error "Terraform deploy script failed"
    exit 1
fi

log_info "All scripts completed successfully!"
