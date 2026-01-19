#!/bin/bash
set -e

DOMAINS="frontend.local backend.local"
IP=$1

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)."
  exit 1
fi

if [ -z "$IP" ]; then
    echo "Error: usage $0 <minikube-ip>"
    exit 1
fi

echo "Configuring /etc/hosts for IP: $IP"

# Backup /etc/hosts
cp /etc/hosts /etc/hosts.bak

# Remove old entries for these domains to avoid duplicates
# Using sed with specific delimiters to avoid partial matches
sed -i "/frontend.local/d" /etc/hosts
sed -i "/backend.local/d" /etc/hosts

# Add new entry
echo "$IP $DOMAINS" >> /etc/hosts

echo "Success! Added '$IP $DOMAINS' to /etc/hosts."
