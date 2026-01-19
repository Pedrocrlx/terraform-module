#!/bin/bash
set -e

PROFILE="terraform-k8s-cluster"
PIDFILE="/tmp/minikube-tunnel-${PROFILE}.pid"
LOGFILE="/tmp/minikube-tunnel-${PROFILE}.log"

echo "Starting Minikube tunnel for profile: $PROFILE"

# Check if tunnel is already running
if [ -f "$PIDFILE" ]; then
    OLD_PID=$(cat "$PIDFILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo "Minikube tunnel already running with PID $OLD_PID"
        exit 0
    else
        echo "Removing stale PID file"
        rm -f "$PIDFILE"
    fi
fi

# Start tunnel in background
# The tunnel needs sudo, so we create a systemd user service or use nohup with sudo
echo "Starting tunnel (this requires sudo privileges)..."
echo "Note: You may need to enter your password"

# Start the tunnel and capture its PID
nohup sudo minikube tunnel -p "$PROFILE" --cleanup > "$LOGFILE" 2>&1 &
TUNNEL_PID=$!

# Save PID
echo "$TUNNEL_PID" > "$PIDFILE"

echo "Minikube tunnel started successfully with PID: $TUNNEL_PID"
echo "Logs available at: $LOGFILE"
echo ""
echo "Waiting for LoadBalancer IP assignment..."
sleep 5

# Check if LoadBalancer got an IP
for i in {1..15}; do
    EXTERNAL_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    if [ ! -z "$EXTERNAL_IP" ]; then
        echo "✓ LoadBalancer IP assigned: $EXTERNAL_IP"
        echo "✓ Access your app at: https://notes-app.local"
        exit 0
    fi
    echo "Attempt $i/15: Waiting..."
    sleep 2
done

echo "Warning: LoadBalancer IP not assigned yet, but tunnel is running"
echo "To stop the tunnel: sudo kill $(cat $PIDFILE)"
