#!/bin/bash

echo "📊 Importing Custom Business Dashboard to Grafana..."

# Port-forward Grafana
kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80 > /dev/null 2>&1 &
GRAFANA_PID=$!
sleep 5

echo "Dashboard JSON has been created in ../dashboards/"
echo "To import manually:"
echo "1. Open Grafana: http://localhost:3000"
echo "2. Go to Dashboards → Import"
echo "3. Upload the JSON file from dashboards/business-metrics-dashboard.json"
echo ""
echo "Or use Grafana API to auto-import (requires admin credentials)"

# Cleanup
# kill $GRAFANA_PID 2>/dev/null
