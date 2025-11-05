#!/bin/bash
set -e

echo "🚀 DrDroid Platform Engineer Assignment Setup (Linux - Sudo Mode)"
echo "=================================================================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    print_warning "This script needs sudo access. Running with sudo..."
    exec sudo bash "$0" "$@"
fi

ORIGINAL_USER=${SUDO_USER:-$(whoami)}
USER_HOME=$(eval echo ~$ORIGINAL_USER)

print_step "Installing required dependencies..."

# Install kubectl
if ! command -v kubectl &> /dev/null; then
    print_step "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/
fi

# Install helm
if ! command -v helm &> /dev/null; then
    print_step "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Install k3d
if ! command -v k3d &> /dev/null; then
    print_step "Installing k3d..."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi


systemctl start docker
systemctl enable docker

print_success "All dependencies installed"


print_step "Creating k3d cluster..."
k3d cluster create drdroid-demo \
    --agents 2 \
    --port "8080:80@loadbalancer" \
    --port "8443:443@loadbalancer" \
    --port "3000:30000@server:0" \
    --api-port 6443


mkdir -p $USER_HOME/.kube
k3d kubeconfig get drdroid-demo > $USER_HOME/.kube/config
chown -R $ORIGINAL_USER:$ORIGINAL_USER $USER_HOME/.kube


print_step "Waiting for cluster to be ready..."
sudo -u $ORIGINAL_USER kubectl wait --for=condition=Ready nodes --all --timeout=300s
print_success "Cluster created and ready"


print_step "Deploying Google microservices-demo..."
sudo -u $ORIGINAL_USER kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/main/release/kubernetes-manifests.yaml


sudo -u $ORIGINAL_USER kubectl patch svc frontend-external -p '{"spec": {"type": "NodePort", "ports": [{"port": 80, "nodePort": 30000}]}}'

print_step "Waiting for pods to be ready (this may take 3-5 minutes)..."
for i in {1..60}; do
    READY=$(sudo -u $ORIGINAL_USER kubectl get pods --field-selector=status.phase=Running 2>/dev/null | grep -c "Running" || echo "0")
    TOTAL=$(sudo -u $ORIGINAL_USER kubectl get pods --no-headers 2>/dev/null | wc -l)
    echo -ne "\rPods ready: $READY/$TOTAL"
    if [ "$READY" -eq "$TOTAL" ] && [ "$TOTAL" -gt 0 ]; then
        echo ""
        break
    fi
    sleep 5
done
print_success "Microservices deployed"

print_step "Installing Prometheus and Grafana..."
sudo -u $ORIGINAL_USER helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
sudo -u $ORIGINAL_USER helm repo update

sudo -u $ORIGINAL_USER helm install kube-prometheus prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --create-namespace \
    --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
    --set grafana.adminPassword=drdroid2024 \
    --set grafana.service.type=NodePort \
    --set grafana.service.nodePort=30001

print_step "Waiting for monitoring stack to be ready..."
sudo -u $ORIGINAL_USER kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=300s
print_success "Monitoring stack installed"

# Step 4: Install Loki
print_step "Installing Loki for log aggregation..."
sudo -u $ORIGINAL_USER helm repo add grafana https://grafana.github.io/helm-charts
sudo -u $ORIGINAL_USER helm install loki grafana/loki-stack \
    --namespace monitoring \
    --set grafana.enabled=false \
    --set promtail.enabled=true \
    --set loki.persistence.enabled=false

print_success "Loki installed"

print_step "Configuring Loki data source..."
cat <<EOF | sudo -u $ORIGINAL_USER kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-loki-datasource
  namespace: monitoring
  labels:
    grafana_datasource: "1"
data:
  loki-datasource.yaml: |-
    apiVersion: 1
    datasources:
    - name: Loki
      type: loki
      access: proxy
      url: http://loki:3100
      isDefault: false
EOF

sudo -u $ORIGINAL_USER kubectl rollout restart deployment kube-prometheus-grafana -n monitoring
sleep 10


print_step "Creating k6 traffic generator..."
cat <<EOF | sudo -u $ORIGINAL_USER kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: k6-script
data:
  script.js: |
    import http from 'k6/http';
    import { sleep } from 'k6';
    
    export let options = {
      stages: [
        { duration: '2m', target: 5 },
        { duration: '30m', target: 10 },
      ],
    };
    
    const products = ['OLJCESPC7Z', '66VCHSJNUP', '1YMWWN1N4O', 'L9ECAV7KIM'];
    
    export default function() {
      const baseUrl = 'http://frontend.default.svc.cluster.local';
      http.get(baseUrl);
      sleep(1);
      const productId = products[Math.floor(Math.random() * products.length)];
      http.get(\`\${baseUrl}/product/\${productId}\`);
      sleep(2);
      if (Math.random() < 0.3) {
        http.post(\`\${baseUrl}/cart\`, JSON.stringify({
          product_id: productId,
          quantity: 1
        }), { headers: { 'Content-Type': 'application/json' }});
      }
      sleep(3);
    }
---
apiVersion: batch/v1
kind: Job
metadata:
  name: k6-traffic-generator
spec:
  template:
    spec:
      containers:
      - name: k6
        image: grafana/k6:latest
        command: ["k6", "run", "/scripts/script.js"]
        volumeMounts:
        - name: k6-script
          mountPath: /scripts
      restartPolicy: Never
      volumes:
      - name: k6-script
        configMap:
          name: k6-script
EOF

print_success "Traffic generator deployed"


print_step "Setting up port forwarding..."
sudo -u $ORIGINAL_USER nohup kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80 > /tmp/grafana-pf.log 2>&1 &
sleep 3

echo ""
echo "=============================================="
print_success "🎉 Setup Complete!"
echo "=============================================="
echo ""
echo "📊 Grafana Access:"
echo "   URL: http://localhost:3000"
echo "   Username: admin"
echo "   Password: drdroid2024"
echo ""
echo "🛍️  Frontend: http://localhost:8080"
echo ""
echo "📝 Next Steps (run as $ORIGINAL_USER):"
echo "   1. Open http://localhost:3000"
echo "   2. Import dashboards: 315, 6417, 13639"
echo "   3. Add siddarth@drdroid.io as viewer"
echo ""
echo "⚠️  To stop port-forward later:"
echo "   sudo pkill -f 'port-forward.*grafana'"
echo ""
