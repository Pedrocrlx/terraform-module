#!/bin/bash
set -e

DOMAIN="notes-app.local"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)."
  exit 1
fi

echo "Getting Minikube IP..."
# Get Minikube IP (we might need run this as the regular user if root doesn't have minikube in path/env, 
# but usually it's fine if fully qualified or envs are preserved. Let's assume 'minikube' is available)
# If sudo doesn't see minikube, user might need to pass it or we try to find it.
if ! command -v minikube &> /dev/null; then
    # Fallback: Try to get it from SUDO_USER if available or warn.
    # For now, let's assume the user has minikube in the path or runs this with sudo -E
    echo "Warning: 'minikube' command not found in PATH. Make sure to run with 'sudo -E env \"PATH=\$PATH\" ./hosts.sh' or provide IP manually."
    
    # Try to grab IP from argument if automatic fetch fail
    IP=$1
else 
    IP=$(minikube ip)
fi

if [ -z "$IP" ]; then
    echo "Error: Could not determine Minikube IP. Is minikube running?"
    echo "Usage fallback: $0 <minikube-ip>"
    exit 1
fi

echo "Minikube IP is: $IP"
echo "Configuring /etc/hosts for $DOMAIN"

# Backup /etc/hosts
cp /etc/hosts /etc/hosts.bak

# Remove old entries for the domain to avoid duplicates
sed -i "/$DOMAIN/d" /etc/hosts

# Add new entry
echo "$IP $DOMAIN" >> /etc/hosts

echo "Success! Added '$IP $DOMAIN' to /etc/hosts."

# Attempt to announce where to go
echo "You can now access https://$DOMAIN in your browser."

# Try to open browser if strictly requested (might fail as root on some deskops, but we can try dropping privs or just notify)
if [ -n "$SUDO_USER" ]; then
    # Create the URL
    URL="https://$DOMAIN"
    echo "Opening $URL..."
    # Run xdg-open as the original user
    sudo -u "$SUDO_USER" xdg-open "$URL" 2>/dev/null || echo "Could not auto-open browser, please manually visit $URL"
else
    echo "Please visit https://$DOMAIN"
fi
