# 🚨 Incident Response Playbook

## Quick Triage Steps

### 1. Is it a Pod Issue?
```bash
# Check pod status
kubectl get pods -n default

# If pod is crashing
kubectl describe pod <pod-name>
kubectl logs <pod-name> --tail=100
kubectl logs <pod-name> --previous  # if crashed

# Quick fix: restart
kubectl rollout restart deployment/<deployment-name>
```

### 2. Is it High CPU/Memory?
**Dashboard:** Business Metrics → CPU/Memory panels
```bash
# Top CPU pods
kubectl top pods -n default --sort-by=cpu

# Top Memory pods
kubectl top pods -n default --sort-by=memory

# Quick fix: scale up
kubectl scale deployment <name> --replicas=3
```

### 3. Is it Network Issues?
**Dashboard:** Business Metrics → Network panels
```bash
# Check service endpoints
kubectl get endpoints -n default

# Test connectivity
kubectl exec -it <pod-name> -- curl <service-url>
```

### 4. Is Traffic Down?
```bash
# Check k6 job
kubectl logs job/k6-traffic-generator --tail=50

# Restart traffic
kubectl delete job k6-traffic-generator
kubectl apply -f manifests/microservices/k6-traffic.yaml
```

## Alert Response Guide

| Alert | Likely Cause | Action |
|-------|-------------|--------|
| **HighPodCPU** | Traffic spike or inefficient code | Scale up or investigate code |
| **HighPodMemory** | Memory leak | Restart pod, investigate logs |
| **PodNotRunning** | Crash loop or failed deployment | Check logs, rollback if needed |
| **PodFrequentRestarts** | OOMKilled or application bug | Increase memory limits |

## Debugging Workflow
```
Alert Fires
    ↓
Check Grafana Dashboard (Is it real?)
    ↓
Check Prometheus Targets (Is monitoring working?)
    ↓
Check Pod Logs (What's the error?)
    ↓
Check Recent Changes (Was there a deployment?)
    ↓
Fix → Monitor → Document
```

## Common Issues & Fixes

### Pod OOMKilled
```bash
# Increase memory limit
kubectl edit deployment <name>
# Change: resources.limits.memory: "512Mi" → "1Gi"
```

### ImagePullBackOff
```bash
# Check image name
kubectl describe pod <pod-name>
# Fix typo in deployment YAML
```

### CrashLoopBackOff
```bash
# Get crash logs
kubectl logs <pod-name> --previous

# Common causes:
# - Missing environment variables
# - Dependency not ready (e.g., database)
# - Application bug on startup
```

## Post-Incident

1. **Document what happened** (root cause)
2. **Update monitoring** (add alert if missed)
3. **Automate fix** (if possible)
4. **Share learnings** (team postmortem)

---

**Remember:** Observability is useless if we don't ACT on it.
