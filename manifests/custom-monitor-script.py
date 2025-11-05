#!/usr/bin/env python3
from prometheus_client import start_http_server, Gauge
import subprocess
import time
import os

# Metrics
total_pods = Gauge('cluster_total_pods', 'Total pods in cluster')
total_nodes = Gauge('cluster_total_nodes', 'Total nodes in cluster')
unhealthy_pods = Gauge('cluster_unhealthy_pods', 'Number of unhealthy pods')
warning_events = Gauge('cluster_warning_events', 'Number of warning events')

# Cluster name (from env)
CLUSTER_NAME = os.getenv("CLUSTER_NAME", "unknown")
PROXY_TOKEN = os.getenv("PROXY_TOKEN", "")[:20]

def get_metrics():
    pods = int(subprocess.getoutput("kubectl get pods --all-namespaces --no-headers 2>/dev/null | wc -l"))
    nodes = int(subprocess.getoutput("kubectl get nodes --no-headers 2>/dev/null | wc -l"))
    unhealthy = int(subprocess.getoutput("kubectl get pods --all-namespaces --field-selector=status.phase!=Running --no-headers 2>/dev/null | wc -l"))
    warnings = int(subprocess.getoutput("kubectl get events --all-namespaces --field-selector type=Warning --no-headers 2>/dev/null | wc -l"))
    total_pods.set(pods)
    total_nodes.set(nodes)
    unhealthy_pods.set(unhealthy)
    warning_events.set(warnings)
    print(f"🤖 DrDroid Custom Agent | Cluster: {CLUSTER_NAME} | Token: {PROXY_TOKEN}...")
    print(f"📊 Pods: {pods}, Nodes: {nodes}, Unhealthy Pods: {unhealthy}, Warnings: {warnings}")
    print("---")

if __name__ == "__main__":
    # Start HTTP server for Prometheus metrics
    start_http_server(8000)
    while True:
        get_metrics()
        time.sleep(30)
