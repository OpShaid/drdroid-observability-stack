# 🔥 Chaos Engineering Guide

## Overview

This project implements chaos engineering to test system resilience and alerting mechanisms.

## Chaos Experiments

### 1. CPU Stress Test
**File:** `manifests/chaos/cpu-stress-chaos.yaml`

Injects high CPU load into recommendation service to test:
- Alert firing (HighPodCPU)
- System performance under load
- Auto-recovery
```bash
# Run experiment
kubectl apply -f manifests/chaos/cpu-stress-chaos.yaml

# Watch in real-time
kubectl get stresschaos -n chaos-testing -w
```

### 2. Pod Failure Test
**File:** `manifests/chaos/pod-failure-chaos.yaml`

Kills cart service pods to test:
- Kubernetes self-healing
- Pod restart alerts
- Service availability
```bash
# Run experiment
kubectl apply -f manifests/chaos/pod-failure-chaos.yaml

# Monitor restarts
kubectl get pods -l app=cartservice -w
```

### 3. Network Latency Test
**File:** `manifests/chaos/network-delay-chaos.yaml`

Injects network delays between services to test:
- Latency tolerance
- Timeout handling
- User experience degradation
```bash
# Run experiment
kubectl apply -f manifests/chaos/network-delay-chaos.yaml

# Check latency metrics in Grafana
```

### 4. Code Exception Test
**File:** `manifests/chaos/code-exception-chaos.yaml`

Forces HTTP errors in checkout service to test:
- Error handling
- Error rate alerts
- Service degradation
```bash
# Run experiment
kubectl apply -f manifests/chaos/code-exception-chaos.yaml

# Watch error logs
kubectl logs -l app=checkoutservice -f
```

## Running All Experiments
```bash
# Start all chaos experiments
kubectl apply -f manifests/chaos/

# Monitor chaos dashboard in Grafana

# Stop all experiments
kubectl delete -f manifests/chaos/
```

## Expected Alerts

| Chaos Type | Alert | Timeline |
|------------|-------|----------|
| CPU Stress | HighPodCPU | ~2 minutes |
| Pod Kill | PodNotRunning | Immediate |
| Pod Kill | PodFrequentRestarts | ~5 minutes |
| Network Delay | None (latency only) | N/A |
| Code Exception | High Error Rate | ~1 minute |

## Monitoring During Chaos

1. **Grafana Dashboard:** Chaos Engineering - Live Monitoring
2. **Prometheus Alerts:** http://localhost:9090/alerts
3. **Slack Notifications:** #drdroid-alerts channel
4. **DrDroid Platform:** Real-time incident tracking

## Safety Features

- All experiments have time limits (2-3 minutes)
- Experiments target single pods (mode: one)
- Can be stopped anytime: `kubectl delete <chaos-type> <name> -n chaos-testing`
- No data loss - database unaffected

## Chaos Testing Best Practices

✅ **DO:**
- Run experiments during business hours
- Monitor alerts closely
- Document findings
- Test recovery procedures

❌ **DON'T:**
- Run multiple experiments simultaneously (initially)
- Target critical services without backup
- Ignore alert notifications
- Run indefinitely without monitoring

---

**Tip:** Run one experiment at a time initially. Once comfortable, create complex scenarios with multiple concurrent chaos experiments.
