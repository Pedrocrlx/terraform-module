#!/bin/bash

echo "⚠️  WARNING: This will delete all resources related to the Notes App."
read -p "Are you sure? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Cleanup cancelled."
    exit 1
fi

echo "Delete local docker images..."
docker rmi notes-backend:1.0 notes-frontend:1.0 --force

echo "Deleting Minikube..."
minikube delete 

echo "Done! Environment is clean."