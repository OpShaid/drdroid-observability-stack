# Alerting Configuration

## Overview
Custom Prometheus alert rules for the DrDroid microservices demo.

## Alert Rules

### HighPodCPU
- **Severity:** Warning
- **Condition:** Pod CPU > 80% for 2+ minutes
- **Action:** Investigate pod resource usage

### HighPodMemory
- **Severity:** Warning
- **Condition:** Pod memory > 500MB for 2+ minutes
- **Action:** Check for memory leaks

### PodNotRunning
- **Severity:** Critical
- **Condition:** Pod not in Running phase for 1+ minute
- **Action:** Check pod logs and events

### PodFrequentRestarts
- **Severity:** Warning
- **Condition:** Pod restarting > once per 15 min
- **Action:** Investigate crash loops

## Setup
```bash
# Apply alert rules
kubectl apply -f prometheus-rules-patch.yaml

# Verify rules are loaded
kubectl get prometheusrule -n monitoring drdroid-custom-alerts

# View in Prometheus UI
kubectl port-forward -n monitoring svc/kube-prometheus-kube-prome-prometheus 9090:9090
# Open: http://localhost:9090/alerts
```

## AlertManager Integration

In production, these alerts would be routed through AlertManager to:
- Slack channels
- PagerDuty
- Email
- Webhooks

Current setup: Alerts are defined but notifications not configured (demo environment)
