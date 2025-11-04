
helm repo add grafana https://grafana.github.io/helm-charts
helm install loki grafana/loki-stack \
    --namespace monitoring \
    --set grafana.enabled=false \
    --set promtail.enabled=true \
    --set loki.persistence.enabled=false

kubectl apply -f - <<EOF
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


kubectl rollout restart deployment kube-prometheus-grafana -n monitoring


kubectl apply -f - <<EOF
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


kubectl port-forward -n monitoring svc/kube-prometheus-grafana 3000:80 &

t
sleep 5

echo ""
echo "Setup Complete!"

echo ""
echo "📊 Grafana Access:"
echo "   URL: http://localhost:3000"
echo "   Username: admin"
echo "   Password: drdroid2024"
echo ""
echo "🛍️  Frontend: http://localhost:8080"
echo ""
echo "✅ Check everything is running:"
echo "   kubectl get pods -A"
echo ""
echo "📝 Next Steps:"
echo "   1. Open http://localhost:3000 in browser"
echo "   2. Login with admin/drdroid2024"

