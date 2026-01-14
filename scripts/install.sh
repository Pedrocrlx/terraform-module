#!/bin/bash
echo "Starting environment..."

minikube start

echo "Enabling Ingress..."
minikube addons enable ingress

echo "Enabling Registry..."
minikube addons enable registry

echo "Building images..."
docker build -t notes-backend:1.0 -f ./backend/Dockerfile ./backend
docker build -t notes-frontend:1.0 -f ./frontend/Dockerfile ./frontend

echo "Loading images into Minikube..."
minikube image load notes-backend:1.0 notes-frontend:1.0

echo "✅ Installation complete!"