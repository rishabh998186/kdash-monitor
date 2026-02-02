# Multi-Cluster Kubernetes Health Monitoring Dashboard

A real-time Go web dashboard providing unified visibility into health and performance of **multiple Kubernetes clusters** via Prometheus metrics. Connect to any cluster - cloud-hosted (GKE, EKS, AKS) or on-premise.

![Dashboard Preview](https://via.placeholder.com/800x400?text=Multi-Cluster+Dashboard)

## Key Features

- 🌐 **Multi-Cluster Support**: Monitor 2-5+ Kubernetes clusters from a single dashboard
- ☁️ **Cloud-Ready**: Connect to GKE, EKS, AKS, DigitalOcean, or any Kubernetes cluster
- 📊 **Prometheus Integration**: Real-time CPU/Memory metrics via PromQL queries
- 🔍 **Live Monitoring**: Auto-refresh every 5 seconds via HTMX
- 🚨 **Alert System**: Automatic alerts when CPU/Memory exceeds thresholds
- 📈 **Historical Metrics**: 24-hour charts stored in SQLite
- 🎨 **Modern UI**: Dark/light theme with glassmorphism design
- 📱 **Responsive**: Works on desktop and mobile

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│              Go Dashboard (Gin + HTMX + Chart.js)           │
├─────────────────────────────────────────────────────────────┤
│  Handlers  │  K8s Service  │  Prometheus Client  │  Store   │
└─────────────────────────────────────────────────────────────┘
                    │                    │
        ┌───────────┴───────────┐        │
        ▼                       ▼        ▼
┌───────────────┐    ┌───────────────┐  ┌────────────────┐
│  GKE Cluster  │    │  EKS Cluster  │  │  Prometheus    │
│  (Cloud)      │    │  (Cloud)      │  │  Endpoints     │
└───────────────┘    └───────────────┘  └────────────────┘
```

## Prerequisites

- Go 1.21+
- kubectl configured with cluster contexts
- Access to Kubernetes clusters with Prometheus installed

## Quick Start

### 1. Clone and Setup

```bash
cd multi-cluster-dashboard
go mod tidy
```

### 2. Configure Your Clusters

Edit `k8s-configs/clusters.yaml` to add your clusters:

```yaml
clusters:
  - name: production
    displayName: "GKE Production"
    context: "gke_my-project_us-central1_prod-cluster"
    prometheusURL: "http://prometheus.prod.example.com:9090"
    enabled: true
    
  - name: staging
    displayName: "EKS Staging"
    context: "arn:aws:eks:us-east-1:123456789:cluster/staging"
    prometheusURL: "http://prometheus.staging.example.com:9090"
    enabled: true
```

**Note**: The `context` must match your kubeconfig context name. The `prometheusURL` should be the Prometheus endpoint accessible from where you run the dashboard.

### 3. Run the Dashboard

```bash
go run cmd/server/main.go
```

Open http://localhost:8080 in your browser.

## Cluster Configuration

| Field | Description |
|-------|-------------|
| `name` | Unique identifier for the cluster |
| `displayName` | Human-readable name shown in UI |
| `context` | Kubeconfig context name |
| `prometheusURL` | Prometheus server endpoint |
| `enabled` | Set to `true` to monitor this cluster |

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/clusters` | GET | List all clusters with health status |
| `/api/clusters/:name` | GET | Detailed cluster info |
| `/api/clusters/:name/nodes` | GET | Nodes in cluster |
| `/api/clusters/:name/pods` | GET | Pods in cluster |
| `/api/clusters/:name/history` | GET | Historical metrics (24h) |
| `/api/alerts` | GET | Active alerts |

## Alert Thresholds

| Condition | Severity |
|-----------|----------|
| CPU > 80% | Warning |
| CPU > 95% | Critical |
| Memory > 80% | Warning |
| Memory > 95% | Critical |
| Pod failures > 0 | Warning |

## Project Structure

```
multi-cluster-dashboard/
├── cmd/server/main.go           # Application entrypoint
├── internal/
│   ├── handlers/                # HTTP request handlers
│   ├── services/                # Kubernetes & Prometheus clients
│   ├── models/                  # Data structures
│   └── store/                   # SQLite database layer
├── templates/                   # HTML templates (HTMX)
├── static/css/                  # Stylesheets
├── k8s-configs/                 # Cluster configuration
└── README.md
```

## Development

### Run Tests

```bash
go test ./... -v
```

### Build

```bash
go build -o dashboard cmd/server/main.go
```

## Tech Stack

| Component | Technology |
|-----------|------------|
| Backend | Go, Gin |
| Frontend | HTMX, Alpine.js, Chart.js |
| Database | SQLite (GORM) |
| Kubernetes | client-go |
| Metrics | Prometheus HTTP API |

## License

MIT
