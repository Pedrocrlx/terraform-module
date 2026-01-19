#!/bin/bash

PROFILE="terraform-k8s-cluster"
PIDFILE="/tmp/minikube-tunnel-${PROFILE}.pid"

if [ ! -f "$PIDFILE" ]; then
    echo "Tunnel is not running (PID file not found)"
    exit 0
fi

PID=$(cat "$PIDFILE")

if ps -p "$PID" > /dev/null 2>&1; then
    echo "Stopping minikube tunnel (PID: $PID)..."
    sudo kill "$PID"
    rm -f "$PIDFILE"
    echo "Tunnel stopped successfully"
else
    echo "Tunnel process not found, cleaning up PID file"
    rm -f "$PIDFILE"
fi
