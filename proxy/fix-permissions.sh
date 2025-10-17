#!/bin/bash

# Fix permissions for logs directory
# This script handles the permission issues with the logs directory

echo "Fixing permissions for logs directory..."

# Try to remove and recreate the logs directory
if [[ -d "logs" ]]; then
    echo "Removing existing logs directory..."
    rm -rf logs/ 2>/dev/null || {
        echo "Could not remove logs directory. Please run:"
        echo "sudo rm -rf logs/"
        echo "Then run this script again."
        exit 1
    }
fi

# Create new logs directory with proper permissions
echo "Creating new logs directory..."
mkdir -p logs/{analysis,filtered,backups}
chmod 755 logs/
chmod 755 logs/analysis
chmod 755 logs/filtered
chmod 755 logs/backups

echo "✓ Logs directory created with proper permissions"
echo "✓ Ready to deploy Caddy with logging"

