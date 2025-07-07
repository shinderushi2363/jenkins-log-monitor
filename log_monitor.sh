#!/bin/bash

# === Configuration ===
LOG_FILE="/var/log/apache2/access.log"   # Change this path if needed
SIZE_LIMIT=$((1024 * 1024 * 1024))     # 1GB in bytes
JENKINS_URL="http://localhost:8080"
JENKINS_JOB="upload-to-s3"
JENKINS_USER="admin"                   # Your Jenkins username
JENKINS_API_TOKEN=" 1142d774910557a89f454081b783258904"
LOG_MONITOR_OUTPUT="/home/ubuntu/log_monitor.log"

# === Log File Size Check ===
if [ -f "$LOG_FILE" ]; then
    FILE_SIZE=$(stat -c%s "$LOG_FILE")

    echo "$(date) - Log file size: $FILE_SIZE bytes" >> $LOG_MONITOR_OUTPUT

    if [ "$FILE_SIZE" -gt "$SIZE_LIMIT" ]; then
        echo "$(date) - Size exceeds 1GB. Triggering Jenkins job..." >> $LOG_MONITOR_OUTPUT

        curl -X POST "$JENKINS_URL/job/$JENKINS_JOB/build" \
        --user "$JENKINS_USER:$JENKINS_API_TOKEN"

        echo "$(date) - Jenkins job triggered." >> $LOG_MONITOR_OUTPUT
    else
        echo "$(date) - Size within limit. No action taken." >> $LOG_MONITOR_OUTPUT
    fi
else
    echo "$(date) - ERROR: Log file does not exist!" >> $LOG_MONITOR_OUTPUT
fi

