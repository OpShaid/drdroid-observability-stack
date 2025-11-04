# 🚀 DrDroid Observability Stack

![Kubernetes](https://img.shields.io/badge/kubernetes-1.31-326CE5?style=flat-square&logo=kubernetes&logoColor=white)
![Prometheus](https://img.shields.io/badge/prometheus-enabled-E6522C?style=flat-square&logo=prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/grafana-10.0+-F46800?style=flat-square&logo=grafana&logoColor=white)
![Jaeger](https://img.shields.io/badge/jaeger-tracing-60D0E4?style=flat-square&logo=jaeger&logoColor=white)

---

## 🎯 What's Inside

| Feature | Description | Status |
|---------|-------------|--------|
| 📊 **Custom Dashboard** | Business metrics (CPU, memory, network, logs) | ✅ Production |
| ⚠️ **Alert Rules** | 4 production-ready monitoring alerts | ✅ Active |
| 🔍 **Distributed Tracing** | Jaeger for request tracking | ✅ Bonus Feature |
| 📝 **Centralized Logs** | Loki + Grafana integration | ✅ Streaming |
| 🎨 **Pre-built Dashboards** | Cluster, pod, node monitoring | ✅ Imported |
| 🔄 **Traffic Generation** | k6 simulating realistic load | ✅ Running |

---

## 🚨 Incident Response Playbook
[Here](INCIDENT-RESPONSE.md)

---

## ⚡ Quick Start

```bash
# 1. Start cluster
k3d cluster create drdroid-demo --agents 2

# 2. Deploy microservices
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/main/release/kubernetes-manifests.yaml

# 3. Install monitoring stack
helm install kube-prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --set grafana.adminPassword=drdroid2024

# 4. Install Loki (logs)
helm install loki grafana/loki-stack -n monitoring \
  --set grafana.enabled=false --set promtail.enabled=true

# 5. Deploy Jaeger (tracing)
kubectl apply -f manifests/tracing/jaeger-all-in-one.yaml

# 6. Apply alerts
kubectl apply -f manifests/alerting/prometheus-rules-patch.yaml
🌐 Access Everything
bash
Copy code
# Easiest way:
1. Clone the repo
2. ./setup.sh (installs requirements)
3. ./s.sh (runs everything)
Or manually:

Service	URL	Credentials
📊 Grafana	http://localhost:3000	admin / drdroid2024
⚠️ Prometheus	http://localhost:9090	-
🔍 Jaeger	http://localhost:16686	-
```
🏗️ Architecture
scss
```
┌─────────────────────────────────────────┐
│         k3d Cluster (3 nodes)           │
├─────────────────────────────────────────┤
│                                         │
│  Microservices (services)           │
│  ├─ frontend                            │
│  ├─ cartservice                         │
│  ├─ checkoutservice                     │
│  └─ 8 more...                           │
│                                         │
│  Observability Stack                    │
│  ├─ Prometheus  → Metrics               │
│  ├─ Grafana     → Dashboards            │
│  ├─ Loki        → Logs                  │
│  ├─ Jaeger      → Traces                │
│  └─ k6          → Traffic               │
│                                         │
└─────────────────────────────────────────┘
```
[Full Architecture Details →](./ARCHITECTURE.md)

---
```
⚠️ Alert Rules
Alert	Trigger	Severity
HighPodCPU	Pod CPU > 80% for 2 min	Warning
HighPodMemory	Pod memory > 500MB	Warning
PodNotRunning	Pod not in Running state	Critical
PodFrequentRestarts	Pod restarting repeatedly	Warning
production would tune them per SLA/SLO.
```
View live: http://localhost:9090/alerts
---
---
🚀 Future Enhancements
 Persistent storage (Thanos for metrics, S3 for Loki)

 AlertManager → Slack/PagerDuty integration

 Service mesh (Istio) for native tracing

 Multi-cluster federation
---
🤝 Built For
DrDroid Platform Engineer Assignment

Deploy microservices-demo with monitoring, logging, tracing, and cost analysis.
