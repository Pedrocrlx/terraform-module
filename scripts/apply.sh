#!/bin/bash
echo "Applying Infrastructure..."

cd terraform

terraform apply k8s.plan 