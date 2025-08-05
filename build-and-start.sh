#!/bin/bash

# Simple script to build and start the deploymenttest application

set -e

echo "Building Docker image..."
docker-compose build

echo "Starting application..."
docker-compose up -d

echo "Application is starting..."
echo "You can access it at: http://localhost:3000"
echo ""
echo "To view logs: docker-compose logs -f"
echo "To stop: docker-compose down" 