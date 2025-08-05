#!/bin/bash

# Complete installation and deployment script for clean Ubuntu server
# Usage: ./install-and-deploy.sh

set -e

# Configuration
GITHUB_REPO="https://github.com/Jian-Zhang08/deployment-test.git"
PROJECT_DIR="deployment-test"
BRANCH="main"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        warning "Running as root. This script will install system packages."
    else
        error "This script needs to be run with sudo for system installations."
        echo "Usage: sudo $0"
        exit 1
    fi
}

# Detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    else
        error "Cannot detect Linux distribution"
        exit 1
    fi
    
    log "Detected OS: $OS"
}

# Update system packages
update_system() {
    log "Updating system packages..."
    
    if command -v apt &> /dev/null; then
        # Debian/Ubuntu
        apt update
    elif command -v dnf &> /dev/null; then
        # Fedora/RHEL/CentOS/Rocky
        dnf update -y
    elif command -v yum &> /dev/null; then
        # Older RHEL/CentOS
        yum update -y
    else
        error "No supported package manager found"
        exit 1
    fi
    
    log "System packages updated successfully!"
}

# Install Git
install_git() {
    log "Installing Git..."
    
    if command -v apt &> /dev/null; then
        apt install -y git
    elif command -v dnf &> /dev/null; then
        dnf install -y git
    elif command -v yum &> /dev/null; then
        yum install -y git
    else
        error "No supported package manager found"
        exit 1
    fi
    
    log "Git installed successfully!"
}

# Install Docker
install_docker() {
    log "Installing Docker..."
    
    if command -v apt &> /dev/null; then
        # Ubuntu/Debian installation
        apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
        
        # Add Docker's official GPG key
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        
        # Add Docker repository
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        # Update package index
        apt update
        
        # Install Docker Engine
        apt install -y docker-ce docker-ce-cli containerd.io
        
    elif command -v dnf &> /dev/null; then
        # RHEL/CentOS/Rocky installation
        dnf install -y dnf-utils
        
        # Add Docker repository
        dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        
        # Install Docker Engine
        dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
    elif command -v yum &> /dev/null; then
        # Older RHEL/CentOS installation
        yum install -y yum-utils
        
        # Add Docker repository
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        
        # Install Docker Engine
        yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
    else
        error "No supported package manager found"
        exit 1
    fi
    
    # Start and enable Docker service
    systemctl start docker
    systemctl enable docker
    
    log "Docker installed successfully!"
}

# Install Docker Compose
install_docker_compose() {
    log "Installing Docker Compose..."
    
    # Download Docker Compose
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    
    # Make it executable
    chmod +x /usr/local/bin/docker-compose
    
    # Create symlink to ensure it's in PATH
    ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    
    log "Docker Compose installed successfully!"
}

# Install additional utilities
install_utilities() {
    log "Installing additional utilities..."
    
    if command -v apt &> /dev/null; then
        apt install -y curl wget unzip
    elif command -v dnf &> /dev/null; then
        dnf install -y curl wget unzip
    elif command -v yum &> /dev/null; then
        yum install -y curl wget unzip
    else
        error "No supported package manager found"
        exit 1
    fi
    
    log "Utilities installed successfully!"
}

# Configure firewall (optional)
configure_firewall() {
    log "Configuring firewall..."
    
    if command -v apt &> /dev/null; then
        # Ubuntu/Debian - use UFW
        apt install -y ufw
        
        # Allow SSH (important!)
        ufw allow ssh
        
        # Allow HTTP and HTTPS
        ufw allow 80/tcp
        ufw allow 443/tcp
        
        # Allow custom port for the application
        ufw allow 3000/tcp
        
        # Enable firewall
        ufw --force enable
        
    elif command -v dnf &> /dev/null || command -v yum &> /dev/null; then
        # RHEL/CentOS/Rocky - use firewalld
        if command -v dnf &> /dev/null; then
            dnf install -y firewalld
        else
            yum install -y firewalld
        fi
        
        # Start and enable firewalld
        systemctl start firewalld
        systemctl enable firewalld
        
        # Allow SSH (important!)
        firewall-cmd --permanent --add-service=ssh
        
        # Allow HTTP and HTTPS
        firewall-cmd --permanent --add-service=http
        firewall-cmd --permanent --add-service=https
        
        # Allow custom port for the application
        firewall-cmd --permanent --add-port=3000/tcp
        
        # Reload firewall
        firewall-cmd --reload
        
    else
        error "No supported package manager found for firewall configuration"
        exit 1
    fi
    
    log "Firewall configured successfully!"
}

# Create non-root user for Docker (optional)
create_docker_user() {
    log "Setting up Docker user..."
    
    # Create user if it doesn't exist
    if ! id "dockeruser" &>/dev/null; then
        useradd -m -s /bin/bash dockeruser
        usermod -aG docker dockeruser
        log "Created user 'dockeruser' with Docker access"
    else
        usermod -aG docker dockeruser
        log "User 'dockeruser' already exists, added to docker group"
    fi
}

# Add current user to docker group
add_current_user_to_docker() {
    log "Adding current user to docker group..."
    
    # Get the user who ran sudo
    local sudo_user=${SUDO_USER:-$USER}
    
    if [ "$sudo_user" != "root" ]; then
        usermod -aG docker "$sudo_user"
        log "Added user '$sudo_user' to docker group"
        log "Note: You may need to log out and log back in for changes to take effect"
    fi
}

# Pull or clone the repository
pull_from_github() {
    if [ -d "$PROJECT_DIR" ]; then
        log "Repository already exists. Pulling latest changes..."
        cd "$PROJECT_DIR"
        git fetch origin
        git reset --hard origin/$BRANCH
        git clean -fd
        cd ..
    else
        log "Cloning repository from GitHub..."
        git clone -b $BRANCH $GITHUB_REPO $PROJECT_DIR
    fi
    
    log "Repository updated successfully!"
}

# Deploy the application
deploy_app() {
    if [ ! -d "$PROJECT_DIR" ]; then
        error "Project directory not found. Run 'pull' first."
        exit 1
    fi
    
    cd "$PROJECT_DIR"
    
    # Check if required files exist
    if [ ! -f "Dockerfile" ]; then
        error "Dockerfile not found in the project directory."
        exit 1
    fi
    
    if [ ! -f "docker-compose.yml" ]; then
        error "docker-compose.yml not found in the project directory."
        exit 1
    fi
    
    # Build and start the application
    log "Building Docker image..."
    docker-compose build
    
    log "Starting application..."
    docker-compose up -d
    
    log "Application deployment completed!"
    log "You can access it at: http://localhost:3000"
    
    cd ..
}

# Show status
show_status() {
    if [ -d "$PROJECT_DIR" ]; then
        cd "$PROJECT_DIR"
        log "Checking application status..."
        docker-compose ps
        cd ..
    else
        warning "Project directory not found."
    fi
}

# Show logs
show_logs() {
    if [ -d "$PROJECT_DIR" ]; then
        cd "$PROJECT_DIR"
        log "Showing application logs..."
        docker-compose logs -f
        cd ..
    else
        warning "Project directory not found."
    fi
}

# Stop application
stop_app() {
    if [ -d "$PROJECT_DIR" ]; then
        cd "$PROJECT_DIR"
        log "Stopping application..."
        docker-compose down
        log "Application stopped successfully!"
        cd ..
    else
        warning "Project directory not found."
    fi
}

# Clean up
cleanup() {
    log "Cleaning up..."
    if [ -d "$PROJECT_DIR" ]; then
        cd "$PROJECT_DIR"
        docker-compose down
        cd ..
    fi
    docker system prune -f
    log "Cleanup completed!"
}

# Full installation and deployment
full_installation() {
    log "Starting complete installation and deployment process..."
    
    # Detect distribution
    detect_distro
    
    # System setup
    update_system
    install_git
    install_docker
    install_docker_compose
    install_utilities
    
    # Add current user to docker group (automatic)
    add_current_user_to_docker
    
    # Optional configurations
    read -p "Do you want to configure firewall? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        configure_firewall
    fi
    
    # Deploy application
    pull_from_github
    deploy_app
    
    log "Complete installation and deployment finished successfully!"
    log "Your application is now running at: http://localhost:3000"
    log ""
    log "Useful commands:"
    log "  cd $PROJECT_DIR && docker-compose logs -f    # View logs"
    log "  cd $PROJECT_DIR && docker-compose down       # Stop application"
    log "  cd $PROJECT_DIR && docker-compose up -d      # Start application"
    log ""
    log "Note: If you get permission errors, you may need to log out and log back in"
    log "      or run: newgrp docker"
}

# Install only (without deployment)
install_only() {
    log "Installing system dependencies only..."
    update_system
    install_git
    install_docker
    install_docker_compose
    install_utilities
    log "System dependencies installed successfully!"
}

# Deploy only (assumes dependencies are already installed)
deploy_only() {
    log "Deploying application only..."
    pull_from_github
    deploy_app
    log "Application deployed successfully!"
}

# Main function
main() {
    local action=${1:-"auto"}
    
    case $action in
        "install")
            check_root
            install_only
            ;;
        "deploy")
            check_root
            deploy_only
            ;;
        "full"|"install-and-deploy")
            check_root
            full_installation
            ;;
        "status")
            show_status
            ;;
        "logs")
            show_logs
            ;;
        "stop")
            stop_app
            ;;
        "cleanup")
            cleanup
            ;;
        "help"|*)
            if [[ $action == "auto" ]]; then
                # Auto mode - do everything
                check_root
                full_installation
            else
                echo "Usage: sudo $0 [install|deploy|full|status|logs|stop|cleanup|help]"
                echo ""
                echo "Commands:"
                echo "  (no args) - Install dependencies and deploy (recommended for clean server)"
                echo "  install   - Install system dependencies only (Git, Docker, etc.)"
                echo "  deploy    - Deploy application only (assumes dependencies installed)"
                echo "  full      - Install dependencies and deploy (recommended for clean server)"
                echo "  status    - Show application status"
                echo "  logs      - Show application logs"
                echo "  stop      - Stop the application"
                echo "  cleanup   - Stop app and clean up Docker resources"
                echo "  help      - Show this help message"
                echo ""
                echo "Examples:"
                echo "  sudo $0               # Complete installation and deployment (auto)"
                echo "  sudo $0 full          # Complete installation and deployment"
                echo "  sudo $0 install       # Install dependencies only"
                echo "  sudo $0 deploy        # Deploy only (if dependencies installed)"
                echo ""
                echo "Note: This script must be run with sudo for system installations."
            fi
            ;;
    esac
}

# Run main function with all arguments
main "$@" 