#!/bin/bash

SERVICE_NAME="IPMIFanControl.service"

# Check if the service exists
if systemctl status "$SERVICE_NAME" &> /dev/null; then
    echo "Attempting to reload $SERVICE_NAME..."
    sudo systemctl reload "$SERVICE_NAME"
    if [ $? -eq 0 ]; then
        echo "$SERVICE_NAME reloaded successfully."
    else
        echo "Failed to reload $SERVICE_NAME. Attempting restart..."
        sudo systemctl restart "$SERVICE_NAME"
        if [ $? -eq 0 ]; then
            echo "$SERVICE_NAME restarted successfully."
        else
            echo "Failed to restart $SERVICE_NAME."
        fi
    fi
else
    echo "Service $SERVICE_NAME not found."
fi
