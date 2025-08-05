# Docker Deployment Guide

This guide explains how to containerize and deploy the deploymenttest React application on an Ubuntu Linux server.

## Prerequisites

### Ubuntu Server Requirements
- Ubuntu 20.04 LTS or later
- At least 2GB RAM
- At least 10GB free disk space
- Internet connection for downloading Docker images

### Install Docker and Docker Compose

1. **Update package index:**
   ```bash
   sudo apt update
   ```

2. **Install required packages:**
   ```bash
   sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
   ```

3. **Add Docker's official GPG key:**
   ```bash
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
   ```

4. **Add Docker repository:**
   ```bash
   echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```

5. **Install Docker Engine:**
   ```bash
   sudo apt update
   sudo apt install -y docker-ce docker-ce-cli containerd.io
   ```

6. **Install Docker Compose:**
   ```bash
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

7. **Add user to docker group (optional but recommended):**
   ```bash
   sudo usermod -aG docker $USER
   # Log out and log back in for changes to take effect
   ```

8. **Start and enable Docker service:**
   ```bash
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

## Deployment

### Option 1: Using the Deployment Script (Recommended)

1. **Clone or upload your project to the server:**
   ```bash
   # If using git
   git clone <your-repository-url>
   cd deploymenttest
   
   # Or upload files via SCP/SFTP
   ```

2. **Make the deployment script executable:**
   ```bash
   chmod +x deploy.sh
   ```

3. **Deploy the application:**
   ```bash
   ./deploy.sh deploy
   ```

4. **Check application status:**
   ```bash
   ./deploy.sh status
   ```

5. **View logs:**
   ```bash
   ./deploy.sh logs
   ```

### Option 2: Manual Docker Commands

1. **Build the Docker image:**
   ```bash
   docker-compose build
   ```

2. **Start the application:**
   ```bash
   docker-compose up -d
   ```

3. **Check if it's running:**
   ```bash
   docker-compose ps
   ```

## Available Commands

### Deployment Script Commands
- `./deploy.sh build` - Build the Docker image
- `./deploy.sh start` - Start the application
- `./deploy.sh stop` - Stop the application
- `./deploy.sh restart` - Restart the application
- `./deploy.sh logs` - Show application logs
- `./deploy.sh status` - Show application status
- `./deploy.sh health` - Perform health check
- `./deploy.sh cleanup` - Clean up unused Docker resources
- `./deploy.sh deploy` - Build and start the application

### Docker Compose Commands
- `docker-compose up -d` - Start services in background
- `docker-compose down` - Stop and remove containers
- `docker-compose restart` - Restart services
- `docker-compose logs -f` - Follow logs
- `docker-compose ps` - Show service status

## Configuration

### Port Configuration
The application runs on port 3000 by default. To change the port:

1. **Edit docker-compose.yml:**
   ```yaml
   ports:
     - "YOUR_PORT:80"  # Change YOUR_PORT to desired port
   ```

2. **Restart the application:**
   ```bash
   ./deploy.sh restart
   ```

### Environment Variables
Add environment variables in `docker-compose.yml`:

```yaml
environment:
  - NODE_ENV=production
  - YOUR_CUSTOM_VAR=value
```

## Monitoring and Maintenance

### Health Check
The application includes a health check endpoint at `/health`. You can monitor it:

```bash
curl http://localhost:3000/health
```

### Logs
View application logs:
```bash
./deploy.sh logs
# or
docker-compose logs -f
```

### Resource Usage
Monitor Docker resource usage:
```bash
docker stats
```

### Backup and Updates

1. **Backup your application:**
   ```bash
   # Backup source code
   tar -czf deploymenttest-backup-$(date +%Y%m%d).tar.gz .
   
   # Backup Docker images
   docker save deploymenttest-app:latest > deploymenttest-image-$(date +%Y%m%d).tar
   ```

2. **Update application:**
   ```bash
   # Pull latest changes
   git pull origin main
   
   # Rebuild and restart
   ./deploy.sh deploy
   ```

## Troubleshooting

### Common Issues

1. **Port already in use:**
   ```bash
   # Check what's using the port
   sudo netstat -tulpn | grep :3000
   
   # Kill the process or change port in docker-compose.yml
   ```

2. **Permission denied:**
   ```bash
   # Add user to docker group
   sudo usermod -aG docker $USER
   # Log out and log back in
   ```

3. **Docker daemon not running:**
   ```bash
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

4. **Out of disk space:**
   ```bash
   # Clean up Docker
   docker system prune -a
   ```

### Debug Mode
For debugging, you can run the container in interactive mode:

```bash
# Build and run in interactive mode
docker-compose run --rm deploymenttest-app sh

# Or run the built image directly
docker run -it --rm -p 3000:80 deploymenttest-app:latest sh
```

## Security Considerations

1. **Firewall Configuration:**
   ```bash
   # Allow only necessary ports
   sudo ufw allow 3000/tcp
   sudo ufw enable
   ```

2. **Regular Updates:**
   ```bash
   # Update Docker images regularly
   docker-compose pull
   ./deploy.sh deploy
   ```

3. **Monitor Logs:**
   ```bash
   # Set up log rotation
   sudo logrotate -f /etc/logrotate.conf
   ```

## Performance Optimization

1. **Enable Docker BuildKit:**
   ```bash
   export DOCKER_BUILDKIT=1
   ```

2. **Use multi-stage builds** (already implemented in Dockerfile)

3. **Optimize nginx configuration** (already configured in nginx.conf)

## Support

For issues or questions:
1. Check the logs: `./deploy.sh logs`
2. Verify Docker installation: `docker --version`
3. Check system resources: `docker stats`
4. Review this documentation

## File Structure

```
deploymenttest/
├── Dockerfile              # Multi-stage Docker build
├── docker-compose.yml      # Docker Compose configuration
├── nginx.conf             # Nginx server configuration
├── .dockerignore          # Files to exclude from Docker build
├── deploy.sh              # Deployment script
├── README-Docker.md       # This file
└── ... (your application files)
``` 