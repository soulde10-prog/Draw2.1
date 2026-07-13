# DRAW2.1 PRODUCTION DEPLOYMENT GUIDE

## 🚀 Complete Production Server Setup

This guide covers deploying Draw2.1 to production servers across multiple platforms.

---

## TABLE OF CONTENTS

1. [AWS EC2 Deployment](#aws-ec2-deployment)
2. [DigitalOcean Deployment](#digitalocean-deployment)
3. [Heroku Deployment](#heroku-deployment)
4. [Azure App Service Deployment](#azure-app-service-deployment)
5. [Self-Hosted Server](#self-hosted-server)
6. [SSL/HTTPS Configuration](#ssl-https-configuration)
7. [Database Optimization](#database-optimization)
8. [Performance Tuning](#performance-tuning)
9. [Monitoring & Logging](#monitoring--logging)
10. [Backup & Recovery](#backup--recovery)

---

## AWS EC2 DEPLOYMENT

### Prerequisites
- AWS Account with EC2 access
- Key pair created
- Security groups configured

### Step 1: Launch EC2 Instance

```bash
# AWS CLI
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t3.medium \
  --key-name your-key-pair \
  --security-groups allow-http-https-ssh \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Draw2.1-Server}]'
```

**Alternative:** Use AWS Management Console
1. Go to EC2 Dashboard
2. Click "Launch Instance"
3. Choose Ubuntu 22.04 LTS (Free tier eligible)
4. Select t2.micro (Free tier)
5. Configure security groups (allow 22, 80, 443)
6. Launch

### Step 2: Connect to Instance

```bash
# Connect via SSH
ssh -i your-key.pem ec2-user@your-instance-ip
```

### Step 3: Install Dependencies

```bash
# Update system
sudo yum update -y

# Install Node.js
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Install npm
npm install -g npm@latest

# Install MongoDB (optional, use Atlas for production)
sudo yum install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod

# Install Docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Nginx
sudo yum install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Install Git
sudo yum install -y git
```

### Step 4: Clone Repository

```bash
# Navigate to home directory
cd /home/ec2-user

# Clone repository
git clone https://github.com/soulde10-prog/Draw2.1.git
cd Draw2.1

# Checkout production branch
git checkout production-release-v1
```

### Step 5: Configure Environment

```bash
# Create .env file
cp .env.example .env

# Edit with your settings
sudo nano .env
```

**Production .env:**
```env
NODE_ENV=production
PORT=3001

MONGODB_URI=mongodb+srv://user:password@cluster.mongodb.net/draw2-1
JWT_SECRET=generate-secure-random-string
FRONTEND_URL=https://your-domain.com

VITE_API_URL=https://api.your-domain.com
```

### Step 6: Install Dependencies & Build

```bash
# Frontend
cd frontend
npm install
npm run build
cd ..

# Backend
cd backend
npm install
cd ..
```

### Step 7: Setup Nginx Reverse Proxy

```bash
# Backup original config
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup

# Create new config
sudo tee /etc/nginx/nginx.conf > /dev/null << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 50M;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss application/rss+xml font/truetype font/opentype application/vnd.ms-fontobject image/svg+xml;

    upstream backend {
        server 127.0.0.1:3001 max_fails=5 fail_timeout=30s;
    }

    server {
        listen 80;
        server_name your-domain.com www.your-domain.com;
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name your-domain.com www.your-domain.com;

        ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

        # Security headers
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;

        # Frontend
        location / {
            root /home/ec2-user/Draw2.1/frontend/dist;
            try_files $uri /index.html;
        }

        # Backend API
        location /api/ {
            proxy_pass http://backend/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;
            proxy_read_timeout 86400;
        }

        # Static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
}
EOF

# Test config
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

### Step 8: Setup SSL Certificate (Let's Encrypt)

```bash
# Install Certbot
sudo yum install -y certbot python3-certbot-nginx

# Get certificate
sudo certbot certonly --nginx -d your-domain.com -d www.your-domain.com

# Auto-renew
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer
```

### Step 9: Setup PM2 for Process Management

```bash
# Install PM2 globally
sudo npm install -g pm2

# Create PM2 ecosystem file
cd /home/ec2-user/Draw2.1

cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'draw2-1-backend',
      script: './backend/server.js',
      instances: 'max',
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        PORT: 3001,
        MONGODB_URI: process.env.MONGODB_URI,
        JWT_SECRET: process.env.JWT_SECRET,
        FRONTEND_URL: process.env.FRONTEND_URL
      },
      error_file: './logs/err.log',
      out_file: './logs/out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss',
      autorestart: true,
      max_memory_restart: '500M'
    }
  ]
};
EOF

# Start with PM2
pm2 start ecosystem.config.js

# Setup startup on reboot
pm2 startup
pm2 save
```

### Step 10: Monitor & Log

```bash
# View logs
pm2 logs draw2-1-backend

# Monitor
pm2 monit

# View PM2 status
pm2 status
```

---

## DIGITALOCEAN DEPLOYMENT

### Prerequisites
- DigitalOcean Account
- SSH key added to account

### Step 1: Create Droplet

```bash
# Using doctl CLI
doctl compute droplet create draw2-1-server \
  --region nyc3 \
  --image ubuntu-22-04-x64 \
  --size s-2vcpu-2gb \
  --ssh-keys your-ssh-key-id
```

### Step 2: SSH into Droplet

```bash
ssh root@your_droplet_ip
```

### Step 3: Initial Setup

```bash
# Update system
apt update && apt upgrade -y

# Add non-root user
adduser deployer
usermod -aG sudo deployer

# Setup SSH for new user
su - deployer
mkdir -p ~/.ssh
echo "your_public_key" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```

### Step 4: Install Stack

```bash
# Follow same steps as AWS (Steps 3-10)
# Only difference: apt instead of yum

# Example:
sudo apt install -y nodejs npm git docker.io docker-compose nginx certbot python3-certbot-nginx
```

### Step 5: Deploy with Git

```bash
cd /home/deployer
git clone https://github.com/soulde10-prog/Draw2.1.git
cd Draw2.1
git checkout production-release-v1
```

### Step 6: Setup Firewall

```bash
# Enable UFW
sudo ufw enable

# Allow SSH, HTTP, HTTPS
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

---

## HEROKU DEPLOYMENT

### Step 1: Install Heroku CLI

```bash
curl https://cli-assets.heroku.com/install.sh | sh
```

### Step 2: Create Heroku App

```bash
heroku login
heroku create draw2-1-app
```

### Step 3: Add MongoDB Atlas

```bash
# Get connection string from MongoDB Atlas
heroku config:set MONGODB_URI="mongodb+srv://user:password@cluster.mongodb.net/draw2-1"
heroku config:set JWT_SECRET="your-secret-key"
heroku config:set NODE_ENV="production"
```

### Step 4: Create Procfile

```
web: node backend/server.js
```

### Step 5: Deploy

```bash
# Add remote
git remote add heroku https://git.heroku.com/draw2-1-app.git

# Push to Heroku
git push heroku production-release-v1:main
```

### Step 6: Verify

```bash
heroku logs --tail
heroku open
```

---

## AZURE APP SERVICE DEPLOYMENT

### Step 1: Create Resource Group

```bash
az group create --name draw2-1-rg --location eastus
```

### Step 2: Create App Service Plan

```bash
az appservice plan create \
  --name draw2-1-plan \
  --resource-group draw2-1-rg \
  --sku B1 \
  --is-linux
```

### Step 3: Create Web App

```bash
az webapp create \
  --resource-group draw2-1-rg \
  --plan draw2-1-plan \
  --name draw2-1-app \
  --runtime "node|18.0"
```

### Step 4: Configure App Settings

```bash
az webapp config appsettings set \
  --resource-group draw2-1-rg \
  --name draw2-1-app \
  --settings \
    MONGODB_URI="mongodb+srv://..." \
    JWT_SECRET="your-secret" \
    NODE_ENV="production"
```

### Step 5: Deploy from GitHub

```bash
az webapp deployment source config-zip \
  --resource-group draw2-1-rg \
  --name draw2-1-app \
  --src /path/to/app.zip
```

---

## SELF-HOSTED SERVER

### Using Docker Compose (Recommended)

```bash
# On your server
cd /opt/draw2-1

# Create docker-compose.yml with production settings
docker-compose up -d

# View logs
docker-compose logs -f
```

### Using Systemd Service

```bash
# Create service file
sudo tee /etc/systemd/system/draw2-1.service > /dev/null << 'EOF'
[Unit]
Description=Draw2.1 Backend Service
After=network.target mongod.service

[Service]
Type=simple
User=draw2-1
WorkingDirectory=/opt/draw2-1
Environment="NODE_ENV=production"
Environment="PORT=3001"
Environment="MONGODB_URI=mongodb://localhost:27017/draw2-1"
ExecStart=/usr/bin/node backend/server.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start
sudo systemctl enable draw2-1
sudo systemctl start draw2-1
```

---

## SSL/HTTPS CONFIGURATION

### Using Let's Encrypt with Certbot

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot certonly --standalone -d your-domain.com

# Configure Nginx
sudo nano /etc/nginx/sites-available/draw2-1
```

### Nginx SSL Configuration

```nginx
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    # SSL settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # HSTS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
}

server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

### Auto-Renewal

```bash
# Test renewal
sudo certbot renew --dry-run

# Enable timer
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer
```

---

## DATABASE OPTIMIZATION

### MongoDB Index Creation

```javascript
// Connect to MongoDB and run:
db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ username: 1 }, { unique: true });
db.projects.createIndex({ userId: 1 });
db.projects.createIndex({ updatedAt: -1 });
db.projects.createIndex({ name: 'text' });
```

### Connection Pooling

```javascript
// backend/server.js
mongoose.connect(mongoUri, {
  maxPoolSize: 10,
  minPoolSize: 5,
  retryWrites: true,
  retryReads: true
});
```

### Query Optimization

```javascript
// Use projection to limit fields
const projects = await Project.find(
  { userId: req.userId },
  { name: 1, createdAt: 1, updatedAt: 1 }
).sort({ updatedAt: -1 });
```

---

## PERFORMANCE TUNING

### Node.js Optimization

```bash
# Increase file descriptors
ulimit -n 65535

# Enable cluster mode (already in PM2 config)

# Node.js flags
node --max-old-space-size=4096 backend/server.js
```

### Nginx Optimization

```nginx
# gzip compression
gzip on;
gzip_vary on;
gzip_comp_level 6;
gzip_types text/plain text/css text/xml text/javascript application/json application/javascript;

# Caching
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# Connection optimization
keepalive_timeout 65;
keepalive_requests 100;
```

### Database Optimization

```bash
# MongoDB connection monitoring
mongosh --eval "db.serverStatus()"

# Check slow queries
db.setProfilingLevel(1, { slowms: 100 })
db.system.profile.find().pretty()
```

---

## MONITORING & LOGGING

### PM2 Plus (Monitoring)

```bash
# Install PM2 Plus
pm2 install pm2-auto-pull
pm2 install pm2-logrotate
pm2 install pm2-intercom

# Connect to PM2 Plus
pm2 link <secret_key> <public_key>
```

### Nginx Access Logs

```bash
# View real-time logs
tail -f /var/log/nginx/access.log

# Parse logs
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -10
```

### Application Logging

```javascript
// backend/server.js
const fs = require('fs');
const path = require('path');

const logsDir = path.join(__dirname, 'logs');
if (!fs.existsSync(logsDir)) fs.mkdirSync(logsDir);

const logStream = fs.createWriteStream(
  path.join(logsDir, `app-${new Date().toISOString().split('T')[0]}.log`),
  { flags: 'a' }
);

app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    logStream.write(
      `${new Date().toISOString()} ${req.method} ${req.path} ${res.statusCode} ${duration}ms\n`
    );
  });
  next();
});
```

---

## BACKUP & RECOVERY

### MongoDB Backup

```bash
# Local backup
mongodump --uri="mongodb://localhost:27017/draw2-1" --out=./backup

# Atlas backup (automated)
# Enable in MongoDB Atlas > Backup

# Restore
mongorestore --uri="mongodb://localhost:27017" ./backup/draw2-1
```

### Application Backup

```bash
# Backup full application
tar -czf draw2-1-backup-$(date +%Y%m%d).tar.gz /opt/draw2-1

# Upload to S3
aws s3 cp draw2-1-backup-*.tar.gz s3://your-backup-bucket/
```

### Restore Procedure

```bash
# Extract backup
tar -xzf draw2-1-backup-20240115.tar.gz

# Restore database
mongorestore --uri="mongodb+srv://..." ./backup

# Restart services
sudo systemctl restart draw2-1
```

---

## PRODUCTION CHECKLIST

- [ ] Domain name configured
- [ ] SSL certificate installed
- [ ] Firewall rules configured
- [ ] MongoDB connection verified
- [ ] Environment variables set
- [ ] Nginx reverse proxy configured
- [ ] PM2 process manager setup
- [ ] Log rotation enabled
- [ ] Backups scheduled
- [ ] Monitoring enabled
- [ ] CI/CD pipeline configured
- [ ] Uptime monitoring setup
- [ ] CDN configured (optional)
- [ ] Email notifications setup
- [ ] Regular maintenance scheduled

---

## TROUBLESHOOTING

### Cannot connect to database
```bash
# Check MongoDB status
sudo systemctl status mongod

# Test connection
mongosh "mongodb://localhost:27017/draw2-1"
```

### High CPU usage
```bash
# Monitor processes
pm2 monit

# Check Node.js memory
pm2 describe draw2-1-backend
```

### 502 Bad Gateway
```bash
# Check backend status
curl http://localhost:3001/health

# Check Nginx logs
sudo tail -f /var/log/nginx/error.log
```

### SSL certificate renewal failed
```bash
# Manual renewal
sudo certbot renew --force-renewal

# Check certificate
sudo certbot certificates
```

---

## SUPPORT & RESOURCES

- **GitHub:** https://github.com/soulde10-prog/Draw2.1
- **Documentation:** https://github.com/soulde10-prog/Draw2.1/wiki
- **Issues:** https://github.com/soulde10-prog/Draw2.1/issues
- **Email:** soulde10@gmail.com

---

**Production Deployment Complete!** 🎉
