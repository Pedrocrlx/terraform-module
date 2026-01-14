#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Automated Tests...${NC}"

# 1. Verifying Pod Status
echo "Checking Pod status..."
if kubectl get pods | grep -q "Running"; then
    echo -e "${GREEN}[OK] Pods are running.${NC}"
else
    echo -e "${RED}[FAIL] No running pods found!${NC}"
    exit 1
fi

# 2. Configuring port-forwarding for testing
echo "Setting up temporary tunnels..."
# Redirect output to /dev/null to keep it clean
kubectl port-forward svc/backend-service 8000:8000 > /dev/null 2>&1 &
PID_BACKEND=$!

kubectl port-forward svc/frontend-service 3000:3000 > /dev/null 2>&1 &
PID_FRONTEND=$!

# Wait 5 seconds for port-forwarding to establish
sleep 5

# 3. Testing Backend
echo "Testing Backend API connectivity..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/docs) 

if [ "$HTTP_CODE" -eq 200 ]; then
    echo -e "${GREEN}[OK] Backend is reachable (HTTP 200).${NC}"
else
    echo -e "${RED}[FAIL] Backend returned HTTP $HTTP_CODE.${NC}"
fi

# 4. Testing Frontend
echo "Testing Frontend connectivity..."
HTTP_CODE_FRONT=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000)

if [ "$HTTP_CODE_FRONT" -eq 200 ]; then
    echo -e "${GREEN}[OK] Frontend is reachable (HTTP 200).${NC}"
else
    echo -e "${RED}[FAIL] Frontend returned HTTP $HTTP_CODE_FRONT.${NC}"
fi

# 5. Cleaning up test tunnels
kill $PID_BACKEND
kill $PID_FRONTEND

echo -e "${GREEN}Tests Completed.${NC}"