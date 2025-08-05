#!/bin/bash

# Script to pull project from GitHub and deploy with Docker
# Usage: ./deploy-from-github.sh [pull|deploy|full]

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

# Check if git is installed
check_git() {
    if ! command -v git &> /dev/null; then
        error "Git is not installed. Please install Git first."
        exit 1
    fi
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
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

# Full deployment (pull + deploy)
full_deployment() {
    log "Starting full deployment process..."
    pull_from_github
    deploy_app
    log "Full deployment completed successfully!"
}

# Show status
show_status() {
    if [ -d "$PROJECT_DIR" ]; then
        cd "$PROJECT_DIR"
        log "Checking application status..."
        docker-compose ps
        cd ..
    else
        warning "Project directory not found. Run 'pull' first."
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
        warning "Project directory not found. Run 'pull' first."
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

# Main function
main() {
    local action=${1:-"help"}
    
    check_git
    check_docker
    
    case $action in
        "pull")
            pull_from_github
            ;;
        "deploy")
            deploy_app
            ;;
        "full"|"deploy-full")
            full_deployment
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
            echo "Usage: $0 [pull|deploy|full|status|logs|stop|cleanup|help]"
            echo ""
            echo "Commands:"
            echo "  pull      - Pull latest changes from GitHub"
            echo "  deploy    - Deploy the application (requires project to be pulled first)"
            echo "  full      - Pull from GitHub and deploy (recommended)"
            echo "  status    - Show application status"
            echo "  logs      - Show application logs"
            echo "  stop      - Stop the application"
            echo "  cleanup   - Stop app and clean up Docker resources"
            echo "  help      - Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 full           # Pull and deploy in one command"
            echo "  $0 pull           # Only pull latest changes"
            echo "  $0 deploy         # Only deploy (if already pulled)"
            echo "  $0 status         # Check if app is running"
            ;;
    esac
}

# Run main function with all arguments
main "$@" 