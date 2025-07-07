# 🔐 Project: Automated Jenkins Job Triggered by Apache Access Log Size

## 📌 Overview

This project implements an automated system that **monitors the size of an Apache access log file** and **triggers a Jenkins job** if the file size exceeds 1GB. The Jenkins job then **uploads the log file to an S3 bucket**, verifies the upload, and **clears the original log** to avoid disk bloat. This process is scheduled and fully automated using a cron job and Jenkins integration via the REST API.

---

## 🎯 Objective

> Automatically trigger a Jenkins job when a log file exceeds a set size limit (1GB), transfer it to AWS S3, and reset the file.

---

## ⚙️ Architecture

- Shell script monitors log file size every 5 minutes
- If it exceeds 1GB → Jenkins job is triggered
- Jenkins job:
  - Uploads log to S3
  - Confirms upload
  - Clears original log file
- All actions are logged
- Uses Jenkins REST API for automation

---

## 🖥️ Technologies Used

- Ubuntu EC2 Instance
- Apache2 (or any web server generating logs)
- Jenkins
- AWS CLI (for S3)
- Shell Scripting
- Cron (for scheduling)
- GitHub (for source control)

---

## 📁 Project Structure

jenkins-log-monitor/
│
├── log_monitor.sh # Shell script to monitor log size and trigger Jenkins job
├── log_monitor.log # Logs of script execution
├── README.md # Project documentation
└── crontab # Crontab entry for automation

yaml
Copy
Edit

---

## 📜 Step-by-Step Setup Guide

### ✅ 1. Set Up Apache and Jenkins

Install and start Apache and Jenkins:

```bash
sudo apt update
sudo apt install apache2 -y
sudo apt install openjdk-11-jdk -y
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update && sudo apt install jenkins -y
sudo systemctl start jenkins
Get Jenkins initial admin password:

bash
Copy
Edit
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
✅ 2. Configure Jenkins
Install required plugins

Create a Freestyle or Pipeline job named upload-log-freestyle

Add a build step that:

Uploads log to S3

Clears log file using > /path/to/log

Example Jenkins job script:

bash
Copy
Edit
#!/bin/bash
aws s3 cp /var/log/apache2/access.log s3://your-bucket-name/
if [ $? -eq 0 ]; then
    echo "Upload successful"
    > /var/log/apache2/access.log
else
    echo "Upload failed"
    exit 1
fi
✅ 3. Create Jenkins API Token
Go to Jenkins → Your Profile → Configure → API Token

Click "Show API Token" or create a new one

Copy the token (you’ll use it in the shell script)

✅ 4. Create Monitoring Shell Script
Create a script log_monitor.sh:

bash
Copy
Edit
#!/bin/bash

LOG_FILE="/var/log/apache2/access.log"
LOG_THRESHOLD=$((1024 * 1024 * 1024))  # 1 GB
LOG="/home/ubuntu/log_monitor.log"
JENKINS_URL="http://localhost:8080/job/upload-log-freestyle/build"
JENKINS_USER="your-jenkins-username"
JENKINS_API_TOKEN="your-api-token"

if [ ! -f "$LOG_FILE" ]; then
  echo "$(date) - ERROR: Log file does not exist!" >> "$LOG"
  exit 1
fi

FILE_SIZE=$(stat -c%s "$LOG_FILE")

echo "$(date) - Log file size: $FILE_SIZE bytes" >> "$LOG"

if [ "$FILE_SIZE" -gt "$LOG_THRESHOLD" ]; then
  echo "$(date) - File is larger than 1GB. Triggering Jenkins..." >> "$LOG"
  
  curl -X POST "$JENKINS_URL" \
    --user "$JENKINS_USER:$JENKINS_API_TOKEN"
  
  if [ $? -eq 0 ]; then
    echo "$(date) - Jenkins job triggered successfully." >> "$LOG"
  else
    echo "$(date) - ERROR: Failed to trigger Jenkins job." >> "$LOG"
  fi
else
  echo "$(date) - Size within limit. No action taken." >> "$LOG"
fi
Make it executable:

bash
Copy
Edit
chmod +x ~/log_monitor.sh
✅ 5. Schedule the Script Using Cron
Open cron editor:

bash
Copy
Edit
crontab -e
Add this line to run every 5 mins:

ruby
Copy
Edit
*/5 * * * * /home/ubuntu/log_monitor.sh
Save and exit.

✅ 6. Test the Full Workflow
Simulate 1GB log:

bash
Copy
Edit
sudo fallocate -l 1100M /var/log/apache2/access.log
Wait 5 mins

Check:

bash
Copy
Edit
cat /home/ubuntu/log_monitor.log
Confirm Jenkins ran → check console output

Check log file cleared

Confirm file in S3:

bash
Copy
Edit
aws s3 ls s3://your-bucket-name
✅ Output Example
yaml
Copy
Edit
Mon Jul  7 10:59:06 UTC 2025 - Log file size: 1181116000 bytes
Mon Jul  7 10:59:06 UTC 2025 - File is larger than 1GB. Triggering Jenkins...
Mon Jul  7 10:59:06 UTC 2025 - Jenkins job triggered successfully.
📸 Screenshots (add these)
Jenkins console output of build

S3 bucket showing uploaded file

Cleared /var/log/apache2/access.log

Terminal showing cron logs

🌐 GitHub Repository
🔗 https://github.com/shinderushi2363/jenkins-log-monitor

💼 LinkedIn (Share Your Work!)
🔗 https://www.linkedin.com/in/rushikesh-shinde

🧠 Learning Outcome
Jenkins REST API usage

Cron automation

File monitoring with bash

Integration with S3

Error logging and production-ready scripts

🔐 Security Tips
Never expose your Jenkins API token or AWS credentials

Use .env files and secure storage for secrets

Consider rotating API tokens regularly

🙌 Author
Rushikesh Shinde – DevOps & Cloud Enthusiast
🔗 LinkedIn

✅ Status
✅ Project Successfully Implemented & Tested
📌 Ready for Deployment
📸 Screenshots captured
📦 Uploaded to GitHub
