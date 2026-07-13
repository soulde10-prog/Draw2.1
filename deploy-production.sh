#!/bin/bash
# Draw2.1 Production Deploy Script for Linux/Mac
# This script automates the entire deployment process

set -e  # Exit on error

echo ""
echo "========================================"
echo "   Draw2.1 - Production Deployment"
echo "========================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="draw2-1"
APP_DIR="/opt/draw2-1"
GIT_REPO="https://github.com/soulde10-prog/Draw2.1.git"
BRANCH="production-release-v1"

# Functions
print_step() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

check_requirements() {
    print_step "Checking system requirements..."
    
    # Check for Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed"
        exit 1
    fi
    print_step "Node.js: $(node --version)"
    
    # Check for npm
    if ! command -v npm &> /dev/null; then
        print_error "npm is not installed"
        exit 1
    fi
    print_step "npm: $(npm --version)"
    
    # Check for Git
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed"
        exit 1
    fi
    print_step "Git: $(git --version)"
    
    # Check for MongoDB
    if ! command -v mongosh &> /dev/null; then
        print_warning "MongoDB CLI not found. Ensure MongoDB Atlas is configured."
    fi
}

setup_directory() {
    print_step "Setting up application directory..."
    
    if [ ! -d "$APP_DIR" ]; then
        sudo mkdir -p "$APP_DIR"
        sudo chown $(whoami):$(whoami) "$APP_DIR"
    fi
    
    cd "$APP_DIR"
}

clone_repository() {
    print_step "Cloning repository..."
    
    if [ -d ".git" ]; then
        print_step "Repository already exists, updating..."
        git pull origin "$BRANCH"
    else
        git clone --branch "$BRANCH" "$GIT_REPO" .
    fi
}

setup_environment() {
    print_step "Setting up environment..."
    
    if [ ! -f ".env" ]; then
        cp .env.example .env
        print_warning "Created .env file. Please edit it with your configuration:"
        print_warning "  sudo nano .env"
    fi
}

install_dependencies() {
    print_step "Installing dependencies..."
    
    # Frontend
    print_step "Installing frontend dependencies..."
    cd "$APP_DIR/frontend"
    npm ci
    
    # Backend
    print_step "Installing backend dependencies..."
    cd "$APP_DIR/backend"
    npm ci
    
    cd "$APP_DIR"
}

build_frontend() {
    print_step "Building frontend..."
    
    cd "$APP_DIR/frontend"
    npm run build
    
    cd "$APP_DIR"
}

setup_systemd() {
    print_step "Setting up systemd service..."
    
    sudo tee /etc/systemd/system/draw2-1.service > /dev/null << EOF
[Unit]
Description=Draw2.1 Backend Service
After=network.target

[Service]
Type=simple
User=$(whoami)
WorkingDirectory=$APP_DIR
Environment=\"NODE_ENV=production\"
ExecStart=/usr/bin/node backend/server.js
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
    
    sudo systemctl daemon-reload
    sudo systemctl enable draw2-1
    print_step "Service enabled"
}

setup_nginx() {
    print_step "Setting up Nginx..."
    
    if ! command -v nginx &> /dev/null; then
        print_warning "Nginx not installed. Installing..."
        sudo apt-get update
        sudo apt-get install -y nginx
    fi
    
    # Copy Nginx config
    sudo cp "$APP_DIR/nginx.conf" /etc/nginx/nginx.conf
    sudo nginx -t
    print_step "Nginx configured"
}

setup_ssl() {
    print_step "Setting up SSL certificate..."
    
    if ! command -v certbot &> /dev/null; then
        print_warning "Certbot not installed. Installing..."
        sudo apt-get install -y certbot python3-certbot-nginx
    fi
    
    print_warning "To generate SSL certificate, run:"
    echo "  sudo certbot certonly --nginx -d your-domain.com"
}

start_services() {
    print_step "Starting services..."
    
    sudo systemctl restart nginx
    sudo systemctl restart draw2-1
    
    print_step "Services started"
}

verify_deployment() {
    print_step "Verifying deployment..."
    
    sleep 2
    
    if curl -s http://localhost:3001/health > /dev/null; then
        print_step "Backend is running ✓"
    else
        print_error "Backend is not responding"
        exit 1
    fi
    
    if curl -s http://localhost/ > /dev/null; then
        print_step "Frontend is running ✓"
    else
        print_error "Frontend is not responding"
        exit 1
    fi
}

# Main execution
echo "Deploy User: $(whoami)"
echo "Target Directory: $APP_DIR"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_error "Deployment cancelled"
    exit 1
fi

check_requirements
setup_directory
clone_repository
setup_environment
install_dependencies
build_frontend
setup_systemd
setup_nginx
setup_ssl
start_services
verify_deployment

echo ""
echo "========================================"
echo "   Deployment Complete!"
echo "========================================"
echo ""
print_step "Application is running at:"
echo "  Frontend: http://localhost"
echo "  Backend: http://localhost:3001"
echo ""
print_step "Next steps:"
echo "  1. Configure SSL certificate"
echo "  2. Add domain to Nginx config"
echo "  3. Monitor logs: sudo journalctl -u draw2-1 -f"
echo ""
