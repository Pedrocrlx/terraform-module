# Script to setup port forwarding for Ingress HTTPS access
# This is the official workaround for Minikube Docker driver with Ingress

PORT_HTTPS=443
NODEPORT_HTTPS=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')

echo "Forwarding HTTPS port $PORT_HTTPS to NodePort $NODEPORT_HTTPS"
echo "Access your app at: https://notes-app.local"
echo "Press Ctrl+C to stop"
echo ""

kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller ${PORT_HTTPS}:443
