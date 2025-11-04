# Distributed Tracing with Jaeger

## Overview
Jaeger is deployed for distributed tracing across microservices. This was a **bonus requirement** in the assignment.

## Architecture
- **Jaeger All-in-One**: Single deployment with collector, query, and agent
- **Namespace**: observability
- **Storage**: In-memory (demo mode)

## Access Jaeger UI
```bash
# Port-forward to Jaeger
kubectl port-forward -n observability svc/jaeger-query 16686:16686

# Open browser
open http://localhost:16686
```

## Components

### Jaeger Query (UI)
- Port: 16686
- View traces, search by service, analyze latency

### Jaeger Collector
- Port: 14268 (HTTP), 14250 (gRPC), 9411 (Zipkin)
- Receives traces from services

### Jaeger Agent
- Ports: 6831 (UDP), 6832 (UDP)
- Sidecar agent for trace collection

## Production Considerations

In production, you would:
1. Use persistent storage (Elasticsearch, Cassandra)
2. Deploy agent as DaemonSet on each node
3. Configure sampling rates
4. Instrument microservices to send traces
5. Set up trace retention policies

## Instrumentation

The microservices-demo doesn't natively send traces. In production:
- Add OpenTelemetry SDK to each service
- Configure JAEGER_AGENT_HOST environment variable
- Traces would automatically flow to Jaeger

## Why Tracing Matters

Distributed tracing helps:
- Track requests across multiple services
- Identify bottlenecks and slow services
- Debug complex distributed systems
- Understand service dependencies
