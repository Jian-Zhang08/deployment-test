#!/bin/bash

# Deployment script for deploymenttest application
# Usage: ./deploy.sh [build|start|stop|restart|logs|status]

set -e

# Configuration
APP_NAME="deploymenttest-app"
COMPOSE_FILE="docker-compose.yml"
DOCKER_IMAGE="deploymenttest-app:latest"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
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

# Check if running as root or with sudo
check_permissions() {
    if [[ $EUID -eq 0 ]]; then
        warning "Running as root. Consider using a non-root user with docker group access."
    fi
}

# Build the application
build() {
    log "Building Docker image..."
    docker-compose -f $COMPOSE_FILE build --no-cache
    log "Build completed successfully!"
}

# Start the application
start() {
    log "Starting application..."
    docker-compose -f $COMPOSE_FILE up -d
    log "Application started successfully!"
    log "Application is available at: http://localhost:3000"
}

# Stop the application
stop() {
    log "Stopping application..."
    docker-compose -f $COMPOSE_FILE down
    log "Application stopped successfully!"
}

# Restart the application
restart() {
    log "Restarting application..."
    docker-compose -f $COMPOSE_FILE restart
    log "Application restarted successfully!"
}

# Show logs
logs() {
    log "Showing application logs..."
    docker-compose -f $COMPOSE_FILE logs -f
}

# Show status
status() {
    log "Checking application status..."
    docker-compose -f $COMPOSE_FILE ps
}

# Health check
health_check() {
    log "Performing health check..."
    if curl -f http://localhost:3000/health &> /dev/null; then
        log "Health check passed!"
    else
        error "Health check failed!"
        exit 1
    fi
}

# Clean up
cleanup() {
    log "Cleaning up unused Docker resources..."
    docker system prune -f
    log "Cleanup completed!"
}

# Main function
main() {
    local action=${1:-"help"}
    
    check_docker
    check_permissions
    
    case $action in
        "build")
            build
            ;;
        "start")
            start
            ;;
        "stop")
            stop
            ;;
        "restart")
            restart
            ;;
        "logs")
            logs
            ;;
        "status")
            status
            ;;
        "health")
            health_check
            ;;
        "cleanup")
            cleanup
            ;;
        "deploy")
            build
            start
            health_check
            log "Deployment completed successfully!"
            ;;
        "help"|*)
            echo "Usage: $0 [build|start|stop|restart|logs|status|health|cleanup|deploy]"
            echo ""
            echo "Commands:"
            echo "  build     - Build the Docker image"
            echo "  start     - Start the application"
            echo "  stop      - Stop the application"
            echo "  restart   - Restart the application"
            echo "  logs      - Show application logs"
            echo "  status    - Show application status"
            echo "  health    - Perform health check"
            echo "  cleanup   - Clean up unused Docker resources"
            echo "  deploy    - Build and start the application"
            echo "  help      - Show this help message"
            ;;
    esac
}

# Run main function with all arguments
main "$@" 