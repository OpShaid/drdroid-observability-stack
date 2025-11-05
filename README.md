# 🚀 DrDroid Observability Stack


**Author:** Shaid T  


---

## 🎯 Project Overview

This project demonstrates a comprehensive observability stack integrating:
- **11 microservices** (Google's microservices-demo)
- **Full monitoring** (Prometheus, Grafana, Loki, Jaeger)
- **Chaos engineering** (Chaos Mesh)
- **Multi-channel alerting** (Slack, AlertManager)
- **AI-powered incident management** (DrDroid platform)
- **Database persistence** (PostgreSQL)

---

## ✨ Features

| Feature | Description | Status |
|---------|-------------|--------|
| 📊 **Microservices Demo** | 11-service e-commerce application | ✅ Production |
| 🔍 **Prometheus Metrics** | Real-time metrics collection & alerting | ✅ Active |
| 📈 **Grafana Dashboards** | Business & technical metrics visualization | ✅ Live |
| 📝 **Loki Log Aggregation** | Centralized logging with Promtail | ✅ Streaming |
| 🎯 **Jaeger Tracing** | Distributed request tracing | ✅ Bonus Feature |
| 💾 **PostgreSQL Database** | Persistent order data storage | ✅ Integrated |
| 🌪️ **Chaos Engineering** | 4 fault injection scenarios | ✅ Active |
| 🚨 **Multi-Channel Alerts** | Slack + DrDroid integration | ✅ Connected |
| 🤖 **DrDroid AI Platform** | Intelligent incident analysis | ✅ Integrated |

---

## 🏗️ Architecture
```
┌─────────────────────────────────────────────────────────┐
│              k3d Cluster (3 nodes)                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Microservices Layer (11 services)                     │
│  ├─ frontend                                           │
│  ├─ cartservice                                        │
│  ├─ checkoutservice                                    │
│  ├─ productcatalogservice                              │
│  └─ 7 more services...                                 │
│                                                         │
│  Data Layer                                            │
│  └─ PostgreSQL (Order persistence)                     │
│                                                         │
│  Observability Stack                                   │
│  ├─ Prometheus → Metrics & Alerting                    │
│  ├─ Grafana → Dashboards & Visualization              │
│  ├─ Loki → Log Aggregation                            │
│  ├─ Jaeger → Distributed Tracing                      │
│  └─ AlertManager → Alert Routing                       │
│                                                         │
│  Chaos Engineering                                     │
│  └─ Chaos Mesh → Fault Injection                      │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 🚨 Alert Pipeline
```
Chaos Experiment
      ↓
Metrics Spike (CPU/Memory/Errors)
      ↓
Prometheus Scrapes (every 15s)
      ↓
Alert Rule Evaluates (2min threshold)
      ↓
AlertManager Routes Alert
      ↓
  ┌───┴────┐
  ↓        ↓
Slack   DrDroid
(Team)  (AI Analysis)
```

### Alert Rules

| Alert | Condition | Severity | Action |
|-------|-----------|----------|--------|
| HighPodCPU | CPU > 80% for 2min | Warning | Slack notification |
| HighPodMemory | Memory > 500MB | Warning | Slack notification |
| PodNotRunning | Pod not in Running state | Critical | Slack + Investigation |
| PodFrequentRestarts | >3 restarts in 5min | Warning | Auto-remediation trigger |

---

## 🌪️ Chaos Engineering Scenarios

### 1. CPU Stress Test
**Purpose:** Test high resource utilization handling  
**Target:** Frontend service  
**Expected Behavior:**
- CPU spikes above 80%
- Prometheus alert fires after 2 minutes
- Slack notification sent
- DrDroid correlates with metrics
```bash
kubectl apply -f manifests/chaos/cpu-stress-chaos.yaml
```

### 2. Pod Kill Test
**Purpose:** Test Kubernetes self-healing  
**Target:** Cart service  
**Expected Behavior:**
- Pod terminated
- Kubernetes restarts pod automatically
- Brief service disruption
- Alert fires for pod downtime
```bash
kubectl apply -f manifests/chaos/pod-kill-chaos.yaml
```

### 3. Network Latency Test
**Purpose:** Test degraded network performance  
**Target:** Checkout → Payment communication  
**Expected Behavior:**
- 500ms latency injected
- Request timeouts increase
- User experience degrades
- Tracing shows bottleneck
```bash
kubectl apply -f manifests/chaos/network-chaos.yaml
```

### 4. HTTP Error Injection
**Purpose:** Test error handling & logging  
**Target:** Product catalog service  
**Expected Behavior:**
- HTTP 500 errors injected
- Error rate spikes in metrics
- Logs capture exceptions
- Alert fires for high error rate
```bash
kubectl apply -f manifests/chaos/http-chaos.yaml
```

**Stop any chaos experiment:**
```bash
kubectl delete -f manifests/chaos/<chaos-file>.yaml
# Or delete all
kubectl delete podchaos,networkchaos,stresschaos,httpchaos --all -n default
```

---

## 🚀 Quick Start

### Prerequisites
- Docker
- kubectl
- helm
- k3d

### Installation
```bash
# 1. Clone the repository
git clone https://github.com/OpShaid/drdroid-observability-stack.git
cd drdroid-observability-stack

# 2. Run setup script (installs dependencies)
./setup.sh

# 3. Deploy everything
./s.sh

# 4. Wait for all pods to be ready (2-3 minutes)
kubectl get pods --all-namespaces -w
```

### Manual Setup
```bash
# 1. Create k3d cluster
k3d cluster create drdroid-demo --agents 2

# 2. Deploy microservices
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/main/release/kubernetes-manifests.yaml

# 3. Install monitoring stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install kube-prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --set grafana.adminPassword=drdroid2024

# 4. Install Loki for logs
helm repo add grafana https://grafana.github.io/helm-charts
helm install loki grafana/loki-stack -n monitoring \
  --set grafana.enabled=false \
  --set promtail.enabled=true

# 5. Deploy Jaeger for tracing
kubectl apply -f manifests/tracing/jaeger-all-in-one.yaml

# 6. Install Chaos Mesh
curl -sSL https://mirrors.chaos-mesh.org/v2.6.3/install.sh | bash

# 7. Deploy PostgreSQL database
kubectl apply -f manifests/database/postgres.yaml

# 8. Apply Prometheus alert rules
kubectl apply -f manifests/alerting/prometheus-rules-patch.yaml

# 9. Configure AlertManager for Slack
kubectl apply -f manifests/alerting/alertmanager-config.yaml
```

---

## 🌐 Access Services

### Local Access

| Service | URL | Credentials |
|---------|-----|-------------|
| Grafana | http://localhost:3000 | admin / drdroid2024 |
| Prometheus | http://localhost:9090 | - |
| AlertManager | http://localhost:9093 | - |
| Jaeger | http://localhost:16686 | - |
| Microservices Frontend | http://localhost:8080 | - |

**Port-forward commands:**
```bash
# Grafana
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80 &

# Prometheus
kubectl port-forward -n monitoring svc/kube-prometheus-prometheus 9090:9090 &

# AlertManager
kubectl port-forward -n monitoring svc/alertmanager-operated 9093:9093 &

# Jaeger
kubectl port-forward -n default svc/jaeger-query 16686:16686 &

# Frontend
kubectl port-forward -n default svc/frontend 8080:80 &
```

### External Access (via ngrok)
```bash
# Expose Grafana externally
ngrok http 3000

# Expose Prometheus
ngrok http 9090

# Use these URLs in DrDroid integrations
```

---

## 🔗 DrDroid Integrations

### Connected Integrations

| Integration | Status | URL/Configuration |
|-------------|--------|-------------------|
| Kubernetes | 🟢 Active | Agent deployed via proxy token |
| Grafana | 🟢 Active | https://xxx.ngrok-free.app |
| Prometheus | 🟢 Active | http://xxx.ngrok-free.app |
| Slack | 🟢 Active | #drdroid-alerts channel |
| GitHub | 🟢 Active | Repository connected |

### Integration Setup

**Kubernetes Agent:**
```bash
cd drd-vpc-agent
./deploy_k8s.sh <PROXY_TOKEN>
```

**Grafana + Prometheus:**
- Use ngrok URLs or IP-based endpoints
- Add in DrDroid platform under Integrations

**Slack:**
- Webhook URL configured in AlertManager
- Channel: #drdroid-alerts

---

## 📊 Monitoring & Dashboards

### Pre-configured Dashboards

1. **Kubernetes Cluster Overview**
   - CPU, Memory, Network across all nodes
   - Pod count and status
   - Resource utilization trends

2. **Microservices Performance**
   - Request rate per service
   - Latency percentiles (p50, p95, p99)
   - Error rates

3. **Business Metrics** (Custom)
   - Total orders processed
   - Order success rate
   - Revenue per hour
   - Checkout conversion funnel

4. **Alert Dashboard**
   - Active alerts by severity
   - Alert frequency over time
   - MTTD and MTTR metrics

### Key Metrics
```promql
# CPU Usage
rate(container_cpu_usage_seconds_total[5m])

# Memory Usage
container_memory_usage_bytes

# Request Rate
rate(http_requests_total[5m])

# Error Rate
rate(http_requests_total{status=~"5.."}[5m])

# Pod Restarts
kube_pod_container_status_restarts_total
```

---

## 💾 Database Integration

### PostgreSQL Setup

**Connection Details:**
- Host: `postgres-service.default.svc.cluster.local`
- Port: `5432`
- Database: `orders`
- User: `postgres`

**Schema:**
```sql
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255),
    order_total DECIMAL(10,2),
    items JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);
```

**Query Orders:**
```bash
kubectl exec -it <postgres-pod> -n default -- psql -U postgres -d orders -c "SELECT * FROM orders LIMIT 10;"
```

---

## 🧪 Testing Scenarios

### End-to-End Test
```bash
# 1. Trigger chaos
kubectl apply -f manifests/chaos/cpu-stress-chaos.yaml

# 2. Monitor in Grafana
# Open: http://localhost:3000
# Navigate to: Kubernetes / Compute Resources / Cluster

# 3. Wait for alert (2-3 minutes)
# Check: http://localhost:9090/alerts

# 4. Verify Slack notification
# Check #drdroid-alerts channel

# 5. Check DrDroid incident
# Open: https://aiops.drdroid.io/incidents

# 6. Clean up
kubectl delete -f manifests/chaos/cpu-stress-chaos.yaml
```

---

## 📈 Production Considerations

### What's Production-Ready
✅ High availability deployments  
✅ Resource limits and requests configured  
✅ Health checks and readiness probes  
✅ Structured logging with correlation IDs  
✅ Metrics instrumentation  
✅ Alert rules with proper thresholds  

### What Would Be Added for Production
- **Persistent Storage**: Thanos for long-term Prometheus metrics, S3 for Loki
- **High Availability**: Multi-replica AlertManager, Grafana, Prometheus
- **Security**: Vault for secrets, RBAC policies, network policies, mTLS
- **Disaster Recovery**: Velero for cluster backups, cross-region replication
- **Cost Optimization**: OpenCost integration, resource right-sizing
- **Distributed Tracing**: Full service instrumentation with OpenTelemetry
- **Incident Management**: PagerDuty/Opsgenie integration with on-call rotations
- **CI/CD**: ArgoCD for GitOps deployments
- **Service Mesh**: Istio for advanced traffic management and security

---

## 🛠️ Troubleshooting

### Common Issues

**Pods not starting:**
```bash
kubectl get pods --all-namespaces
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
```

**Grafana not accessible:**
```bash
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80
# Access: http://localhost:3000
```

**Alerts not firing:**
```bash
# Check Prometheus targets
kubectl port-forward -n monitoring svc/kube-prometheus-prometheus 9090:9090
# Open: http://localhost:9090/targets

# Check AlertManager
kubectl logs -n monitoring alertmanager-kube-prometheus-kube-prome-alertmanager-0
```

**Slack notifications not working:**
```bash
# Verify webhook URL
kubectl get secret -n monitoring alertmanager-kube-prometheus-alertmanager -o yaml

# Test webhook manually
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"Test alert"}' \
  https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

---

## 📚 Documentation Structure
```
.
├── README.md                          # This file
├── manifests/
│   ├── alerting/
│   │   ├── alertmanager-config.yaml
│   │   └── prometheus-rules-patch.yaml
│   ├── chaos/
│   │   ├── cpu-stress-chaos.yaml
│   │   ├── pod-kill-chaos.yaml
│   │   ├── network-chaos.yaml
│   │   └── http-chaos.yaml
│   ├── database/
│   │   └── postgres.yaml
│   └── tracing/
│       └── jaeger-all-in-one.yaml
├── scripts/
│   ├── setup.sh                       # Initial setup
│   └── s.sh                           # Start everything
└── screenshots/                       # Demo screenshots
    ├── grafana-dashboard.png
    ├── prometheus-alerts.png
    └── slack-notification.png
```

---

## 🎓 Key Learnings

### Technical Insights
1. **Observability is not just monitoring** - Requires logs, metrics, traces, and context
2. **Alert fatigue is real** - Proper thresholds and routing are critical
3. **Chaos engineering catches issues** before customers do
4. **Database integration** adds stateful complexity but enables better analysis
5. **Multi-channel alerting** ensures the right people get notified at the right time

### Best Practices Demonstrated
- Infrastructure as Code (IaC) with Kubernetes manifests
- Declarative configuration management
- Separation of concerns (monitoring, application, data layers)
- Comprehensive documentation
- Automated testing through chaos engineering

---

## 🤝 About This Project

**Built for:** DrDroid Platform Engineer Assignment  
**Timeline:** [Your timeline]  
**Technologies:** Kubernetes, Prometheus, Grafana, Loki, Jaeger, Chaos Mesh, PostgreSQL, Python

**Contact:**
- GitHub: [@OpShaid](https://github.com/OpShaid)
- Email: [Your email]

---

## 📄 License

This project is for demonstration purposes as part of a technical assignment.

---

## 🙏 Acknowledgments

- [Google Cloud Platform](https://github.com/GoogleCloudPlatform/microservices-demo) 
- [Prometheus Community](https://prometheus.io/) - Monitoring ecosystem
- [Grafana Labs](https://grafana.com/) - Visualization platform
- [Chaos Mesh](https://chaos-mesh.org/) - Chaos engineering platform
- [DrDroid](https://drdroid.io/) - AI-powered incident management

---

