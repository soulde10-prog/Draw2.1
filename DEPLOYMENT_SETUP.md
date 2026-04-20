# Deployment Setup Instructions

## Hosting the Application

### Local Development
1. **Clone the Repository:**  
   ```bash
   git clone https://github.com/soulde10-prog/Draw2.1.git
   cd Draw2.1
   ```  

2. **Install Dependencies:**  
   Use your package manager to install the required dependencies. Example using npm:
   ```bash
   npm install
   ```  

3. **Run the Application Locally:**  
   Start the development server:
   ```bash
   npm start
   ```  

### Docker Deployment
1. **Build the Docker Image:**  
   Make sure Docker is installed, then build the image:
   ```bash
   docker build -t draw2.1 .
   ```  

2. **Run the Docker Container:**  
   ```bash
   docker run -p 8080:8080 draw2.1
   ```  
   Access the application at `http://localhost:8080`.

### Cloud Hosting Options
#### Using AWS
1. **Set Up an EC2 Instance:**  
   - Go to the AWS EC2 console, create a new instance, and choose an appropriate AMI.
   - Configure your security group to allow HTTP, HTTPS, and SSH access.

2. **Install Docker on EC2 Instance:**
   ```bash
   sudo yum update -y
   sudo yum install docker -y
   sudo service docker start
   ```  

3. **Deploy Your Application:**  
   Follow the Docker deployment steps above on your EC2 instance.

#### Using Heroku
1. **Create a Heroku App:**  
   ```bash
   heroku create draw2.1
   ```  

2. **Deploy to Heroku:**  
   ```bash
   git push heroku main
   ```  

### Remote Access Setup
1. **Configure SSH Access:**  
   Ensure that you have SSH access to your server or cloud instance.

2. **Connect Remotely:**  
   ```bash
   ssh -i your-key.pem ec2-user@your-ec2-public-dns
   ```  
   Replace `your-key.pem` and `your-ec2-public-dns` with your actual key and public DNS.

## Conclusion
You are now set up to run the application locally, in Docker, or on the cloud. Make sure to customize your environment variables and settings based on your specific deployment needs.
