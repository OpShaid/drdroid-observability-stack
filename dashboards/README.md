# Custom Dashboards

## Business Metrics Dashboard

**Purpose:** Track application-level metrics and business KPIs

**Panels:**
- **Requests Per Second**: Network traffic as proxy for request volume
- **Active Pods**: Number of running pods in default namespace
- **CPU Usage by Pod**: Individual service CPU consumption
- **Memory Usage by Pod**: Memory footprint per service
- **Network Traffic**: Inbound/outbound traffic by pod

**Import:**
```bash
# Via Grafana UI
Dashboards → Import → Upload business-metrics-dashboard.json

# Or use the import script
../scripts/import-dashboards.sh
```

**Queries Used:**
- `sum(rate(container_network_receive_bytes_total{namespace="default"}[5m]))`
- `count(kube_pod_status_phase{namespace="default", phase="Running"})`
- `sum(rate(container_cpu_usage_seconds_total{namespace="default"}[5m])) by (pod)`
- `sum(container_memory_usage_bytes{namespace="default"}) by (pod)`
