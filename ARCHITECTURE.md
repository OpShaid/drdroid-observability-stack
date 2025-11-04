# Architecture Overview

## System Diagram
```
┌─────────────────────────────────────────────────────────┐
│                    k3d Cluster (3 nodes)                 │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ Microservices│  │  Monitoring  │  │ Observability│ │
│  │  Namespace   │  │  Namespace   │  │  Namespace   │ │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘ │
│         │                  │                  │          │
│  ┌──────▼──────────────────▼──────────────────▼──────┐ │
│  │                                                     │ │
│  │  • frontend          • Prometheus (metrics)        │ │
│  │  • cartservice       • Grafana (dashboards)        │ │
│  │  • checkoutservice   • Loki (logs)                 │ │
│  │  • paymentservice    • Promtail (log shipping)     │ │
│  │  • productcatalog    • AlertManager (alerts)       │ │
│  │  • recommendation    • Jaeger (traces)             │ │
│  │  • adservice         • k6 (traffic gen)            │ │
│  │  • currencyservice                                 │ │
│  │  • shippingservice                                 │ │
│  │  • emailservice                                    │ │
│  │  • redis                                           │ │
│  │                                                     │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
└─────────────────────────────────────────────────────────┘

         │                    │                    │
         ▼                    ▼                    ▼
    localhost:3000      localhost:9090      localhost:16686
     (Grafana)         (Prometheus)          (Jaeger)
```

## Data Flow

### Metrics Flow
1. Microservices expose `/metrics` endpoints
2. Prometheus scrapes metrics every 15s
3. Grafana queries Prometheus for visualization
4. AlertManager fires alerts based on rules

### Logs Flow
1. Containers write logs to stdout/stderr
2. Promtail collects logs from each node
3. Promtail ships logs to Loki
4. Grafana queries Loki for log visualization

### Traces Flow
1. Services instrumented with OpenTelemetry
2. Traces sent to Jaeger collector
3. Jaeger stores and indexes traces
4. Query UI provides search and visualization

### Traffic Flow
1. k6 generates HTTP requests
2. Hits frontend service
3. Frontend calls backend services
4. All activity generates metrics/logs/traces

## Components

| Component | Purpose | Port | Namespace |
|-----------|---------|------|-----------|
| Prometheus | Metrics collection & storage | 9090 | monitoring |
| Grafana | Metrics/logs visualization | 3000 | monitoring |
| Loki | Log aggregation | 3100 | monitoring |
| Promtail | Log shipping agent | - | monitoring |
| AlertManager | Alert routing | 9093 | monitoring |
| Jaeger | Distributed tracing | 16686 | observability |
| k6 | Traffic generation | - | default |

## Observability Stack Benefits

### For Developers
- Debug issues faster with logs + metrics + traces
- Understand system behavior in real-time
- Identify bottlenecks and performance issues

### For Operations
- Monitor system health 24/7
- Get alerted before users notice problems
- Capacity planning with historical data

### For Business
- Track application performance
- Measure user experience (latency, errors)
- Data-driven decisions on infrastructure
