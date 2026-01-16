#!/bin/bash
terraform plan -out k8s.plan

terraform apply k8s.plan