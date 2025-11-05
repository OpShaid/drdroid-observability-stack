# 📬 Slack Alerting Integration

## Setup

### Workspace
- **Name:** drdroid-chaos-ops
- **Channel:** #alerts
- **App:** DrDroid AlertManager

### Webhook Configuration
Webhook URL configured in AlertManager secret:
```
monitoring/alertmanager-kube-prometheus-kube-prome-alertmanager
```

## Alert Flow
```
Prometheus Alert Fires
        ↓
AlertManager receives alert
        ↓
Groups by alertname/severity
        ↓
Routes to appropriate receiver
        ↓
Formats with Slack template
        ↓
Sends to #alerts channel
        ↓
Team gets notified! 🔔
```

## Alert Types in Slack

### 🔴 Critical Alerts
- Red color
- @channel mention
- Requires immediate action
- Examples: PodNotRunning, Service Down

### ⚠️  Warning Alerts
- Yellow color
- No @channel mention
- Monitor and investigate
- Examples: HighPodCPU, HighMemory

### ✅ Resolved Alerts
- Green color
- Confirms issue is fixed
- Includes resolution time

## Testing Slack Integration

### Manual Test
```bash
kubectl run test-alert --rm -i --restart=Never --image=curlimages/curl -- \
  curl -XPOST http://alertmanager-operated.monitoring.svc:9093/api/v1/alerts \
  -H "Content-Type: application/json" \
  -d '[{
    "labels": {"alertname": "TestAlert", "severity": "info"},
    "annotations": {"summary": "Test alert"}
  }]'
```

### Trigger Real Alert
```bash
# Deploy CPU stress pod
kubectl apply -f manifests/chaos/cpu-stress-chaos.yaml

# Wait 2 minutes, check Slack for HighPodCPU alert
```

## Alert Message Format
```
🔥 Alert: HighPodCPU

Status: 🔴 FIRING

Alert Details:
- Summary: High CPU usage on pod recommendation-xxx
- Pod: recommendation-service-xxx
- Namespace: default
- Severity: warning
- Description: Pod CPU usage is above 80% for 2+ minutes

Runbook: Check Grafana → Business Metrics Dashboard
Time: 2025-11-05 14:23:15
```

## Troubleshooting

### Alerts not reaching Slack?
```bash
# Check AlertManager logs
kubectl logs -n monitoring alertmanager-kube-prometheus-kube-prome-alertmanager-0

# Check AlertManager config
kubectl get secret alertmanager-kube-prometheus-kube-prome-alertmanager -n monitoring -o yaml

# Test webhook directly
curl -X POST YOUR_WEBHOOK_URL \
  -H 'Content-Type: application/json' \
  -d '{"text": "Test message"}'
```

### Webhook URL issues?
1. Verify webhook is active in Slack App settings
2. Check URL has no extra spaces/characters
3. Ensure AlertManager secret is updated
4. Restart AlertManager after config changes

## Best Practices

✅ **DO:**
- Keep #alerts channel focused (no chit-chat)
- Acknowledge alerts when investigating
- Update thread with resolution details
- Use alert severity appropriately

❌ **DON'T:**
- Ignore critical alerts
- Mute the channel permanently
- Spam with test alerts
- Delete alert history

---

**Slack Workspace Invite:** [Add team members via Slack settings]
