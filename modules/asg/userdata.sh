#!/bin/bash
set -xe

# Update system
yum update -y

# Install Apache
yum install -y httpd

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create a simple web page
echo "<h1>Healthy instance: $(hostname)</h1>" > /var/www/html/index.html

# Ensure proper permissions
chmod 644 /var/www/html/index.html