# Draw2.1 - Windows Setup Guide

## Quick Start (Windows)

This guide will help you get Draw2.1 running on Windows.

## Prerequisites

### Required
- **Windows 10/11** (64-bit recommended)
- **Node.js 18+** - [Download](https://nodejs.org/)
- **npm** (comes with Node.js)
- **MongoDB** - Either:
  - Local installation: [Download](https://www.mongodb.com/try/download/community)
  - Cloud (MongoDB Atlas): [Free account](https://www.mongodb.com/cloud/atlas)

### Optional
- **Docker Desktop** - [Download](https://www.docker.com/products/docker-desktop) (for containerized deployment)
- **Git** - [Download](https://git-scm.com/) (for version control)
- **Visual Studio Code** - [Download](https://code.visualstudio.com/) (recommended editor)

## Installation Methods

### Method 1: Automatic Setup (Recommended)

1. **Extract the repository** to a folder on your computer
   ```
   C:\Users\YourName\Documents\Draw2.1
   ```

2. **Run the setup script**
   - Double-click `install-windows.bat`
   - This will check for Node.js and install if needed
   - Then double-click `setup-windows.bat`
   - This will install all dependencies and build the application

3. **Configure environment**
   - Edit `.env` file with your settings:
     ```
     VITE_API_URL=http://localhost:3001
     MONGODB_URI=mongodb://localhost:27017/draw2-1
     JWT_SECRET=your-secret-key
     FRONTEND_URL=http://localhost:5173
     ```

4. **Start the application**
   - Double-click `start-windows.bat`
   - This will open two command windows (frontend and backend)
   - Wait 5-10 seconds for services to start
   - Open browser to: http://localhost:5173

### Method 2: Docker Setup (Windows)

If you have Docker Desktop installed:

1. **Run the Docker setup script**
   ```
   double-click docker-windows.bat
   ```

2. **Access the application**
   - Frontend: http://localhost
   - Backend: http://localhost:3001

### Method 3: Manual Setup

1. **Open Command Prompt** and navigate to the repository:
   ```cmd
   cd C:\Users\YourName\Documents\Draw2.1
   ```

2. **Install frontend dependencies**
   ```cmd
   cd frontend
   npm install
   cd ..
   ```

3. **Install backend dependencies**
   ```cmd
   cd backend
   npm install
   cd ..
   ```

4. **Create .env file**
   ```cmd
   copy .env.example .env
   ```

5. **Edit .env** with your configuration

6. **Start frontend** (Command Prompt 1):
   ```cmd
   cd frontend
   npm run dev
   ```

7. **Start backend** (Command Prompt 2):
   ```cmd
   cd backend
   npm run dev
   ```

8. **Open browser** to: http://localhost:5173

## Available Batch Scripts

### `install-windows.bat`
Checks and installs prerequisites:
- Verifies Node.js installation
- Offers to install Node.js if missing
- Checks for npm and Git

**Usage:**
```
Double-click to run
```

### `setup-windows.bat`
Complete setup and launch:
- Installs all dependencies
- Builds the frontend
- Starts frontend and backend servers in separate windows

**Usage:**
```
Double-click to run
```

### `start-windows.bat`
Quick start (dependencies already installed):
- Starts frontend development server
- Starts backend development server
- Opens two new command windows

**Usage:**
```
Double-click to run
```

### `docker-windows.bat`
Starts all services using Docker Compose:
- Requires Docker Desktop to be installed
- Starts MongoDB, frontend, backend, and Nginx in containers

**Usage:**
```
Double-click to run
```

### `stop-windows.bat`
Stops all running services:
- Kills Node.js processes
- Stops Docker containers

**Usage:**
```
Double-click to run
```

### `clean-windows.bat`
Cleans up node_modules and build files:
- Removes `node_modules` folders
- Removes `dist` folders
- Useful for troubleshooting or freeing disk space

**Usage:**
```
Double-click to run (confirm with 'yes')
```

## Environment Configuration

Edit `.env` file in the root directory:

```env
# Frontend
VITE_API_URL=http://localhost:3001

# Backend
PORT=3001
NODE_ENV=development

# Database
MONGODB_URI=mongodb://localhost:27017/draw2-1

# Authentication
JWT_SECRET=your-super-secret-jwt-key

# CORS
FRONTEND_URL=http://localhost:5173
```

### MongoDB Setup

**Option 1: Local MongoDB**

1. Install MongoDB Community Edition
2. Start MongoDB service
3. Use `mongodb://localhost:27017/draw2-1` in `.env`

**Option 2: MongoDB Atlas (Cloud)**

1. Create free account at [mongodb.com/cloud/atlas](https://mongodb.com/cloud/atlas)
2. Create a cluster
3. Get connection string
4. Update in `.env`:
   ```
   MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/draw2-1
   ```

## Troubleshooting

### Node.js not found
**Problem:** "node is not recognized"

**Solution:**
1. Install Node.js from https://nodejs.org/
2. Restart your computer
3. Run the setup script again

### Port 5173 already in use
**Problem:** "Address already in use"

**Solution:**
1. Close any other applications using port 5173
2. Or modify `frontend/vite.config.js`:
   ```javascript
   server: {
     port: 5174  // Change to different port
   }
   ```

### MongoDB connection failed
**Problem:** "MongooseError: Cannot connect to MongoDB"

**Solution:**
1. Verify MongoDB is running
2. Check `MONGODB_URI` in `.env` is correct
3. If using Atlas, ensure IP is whitelisted
4. Check firewall settings

### Docker not found
**Problem:** "docker is not recognized"

**Solution:**
1. Install Docker Desktop from https://www.docker.com/products/docker-desktop
2. Restart your computer
3. Run `docker-windows.bat` again

### Permission denied errors
**Problem:** "Access is denied"

**Solution:**
1. Run Command Prompt as Administrator
2. Or: Right-click setup script → Run as administrator

### npm install hangs
**Problem:** Installation stops or takes very long

**Solution:**
```cmd
npm cache clean --force
rm -r node_modules package-lock.json
npm install
```

## Common Commands

### Build frontend for production
```cmd
cd frontend
npm run build
```

### Run backend tests
```cmd
cd backend
npm test
```

### View logs (if running manually)
```
Logs appear in the command window where services started
```

### Check service health
```cmd
curl http://localhost:3001/health
```

## Next Steps

1. **Create an account** - Register with email and password
2. **Start drawing** - Create a new project and start designing
3. **Save & export** - Your work is automatically saved to the cloud
4. **Share projects** - Manage layers, undo/redo, and export as PNG/JPEG

## Getting Help

- **GitHub Issues:** https://github.com/soulde10-prog/Draw2.1/issues
- **API Documentation:** See `API.md` in the repository
- **Deployment Guide:** See `DEPLOYMENT_GUIDE.md` for production setup

## Performance Tips

- **Close unnecessary applications** to free up RAM
- **Use SSD** for better performance
- **Disable Windows Defender** temporarily if it slows down installation
- **Run as Administrator** for better performance

## System Requirements

### Minimum
- Windows 10 (64-bit)
- 4GB RAM
- 2GB Disk Space
- Intel i3 or equivalent

### Recommended
- Windows 11
- 8GB RAM
- 5GB Disk Space (for Docker)
- Intel i7 or AMD Ryzen 5

## Support

For issues or questions:
- Email: soulde10@gmail.com
- GitHub: https://github.com/soulde10-prog/Draw2.1
- Website: https://draw2-1.vercel.app

---

**Made with ❤️ for Windows Users**
