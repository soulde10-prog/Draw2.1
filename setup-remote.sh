#!/bin/bash

# A script to automate remote deployment

# Exit on error
set -e

# Function to display messages in color
info() { echo "\e[34m[INFO] \e[0m$1"; }
error() { echo "\e[31m[ERROR] \e[0m$1"; }

# Check if parameters are provided
if [ "$#" -ne 3 ]; then
    error "Usage: $0 <remote_host> <user> <port>"
    exit 1
fi

REMOTE_HOST=$1
USER=$2
PORT=$3

# Update the system
info "Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y

# Install dependencies
info "Installing dependencies..."
sudo apt-get install -y curl git wget build-essential

# Install Docker
info "Installing Docker..."
 curl -fsSL https://get.docker.com -o get-docker.sh
 sh get-docker.sh

# Install Docker Compose
info "Installing Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 2)
 sudo curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
 sudo chmod +x /usr/local/bin/docker-compose

# Install Node.js 18
info "Installing Node.js 18..."
 curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Clone the Draw2.1 repository
info "Cloning the Draw2.1 repository..."
 git clone https://github.com/soulde10-prog/Draw2.1.git
 cd Draw2.1

# Copy .env.example to .env
info "Copying .env.example to .env..."
 cp .env.example .env

# Install npm dependencies
info "Installing npm dependencies..."
 cd backend && npm install && cd ../frontend && npm install && cd ..

# Build Docker images
info "Building Docker images..."
 docker-compose build

# Start services
info "Starting all services..."
 docker-compose up -d

# Display status and next steps
info "Deployment complete!"
info "You can check the status of the services with 'docker-compose ps'"
info "Remember to configure your .env file according to your environment."