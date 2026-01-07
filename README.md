# Kafka-DBSync: Database Replication & CDC Toolkit

A comprehensive Kubernetes-based toolkit for Change Data Capture (CDC) and database replication using Kafka, Debezium, and JDBC connectors.

## Overview

Kafka-DBSync provides infrastructure and automation for building multi-database CDC pipelines that stream changes from source databases to target databases in real-time. It supports Oracle, MariaDB, and MSSQL with flexible deployment options for development and testing.

### Key Features

- **Multi-Database CDC**: Oracle, MariaDB, MSSQL support
- **Real-time Streaming**: Kafka 4.0 with KRaft mode (no ZooKeeper)
- **Debezium Integration**: Log-based CDC connectors
- **JDBC Sink Connectors**: Write to any JDBC-compatible database
- **E2E Testing**: Automated setup and verification scripts
- **Kubernetes-Native**: Helm charts for all components
- **Lightweight Mode**: Fast Oracle XE for development

### Architecture

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Source    │────▶│    Kafka     │────▶│   Target    │
│  Database   │     │   Cluster    │     │  Database   │
│ (Oracle/    │     │              │     │ (MariaDB/   │
│  MSSQL)     │     │ Debezium CDC │     │  MSSQL)     │
└─────────────┘     └──────────────┘     └─────────────┘
```

**Data Flow:**
1. Debezium source connector captures changes from source database transaction logs
2. Changes are published to Kafka topics
3. JDBC sink connector consumes from Kafka and writes to target database

## Quick Start

### Prerequisites

- Docker Desktop or similar container runtime
- 8GB+ RAM recommended
- kubectl, helm, and kind (or use `make tools` to install)

### 1. Install Tools (Optional)

```bash
make tools
```

Installs kubectl, helm, and kind if not already present.

### 2. Create Cluster and Deploy Services

```bash
# Lightweight mode (Oracle XE 21c, faster startup)
make all

# Or Enterprise mode (Oracle EE 19c, full features)
make all LIGHTWEIGHT=0
```

This will:
- Create a kind Kubernetes cluster
- Deploy Kafka, Kafka Connect, Oracle, MariaDB, and supporting services
- Wait for all pods to be ready (~3-5 minutes)

### 3. Run E2E Test

```bash
# Start port forwarding (in separate terminal)
make port-forward

# Run E2E test
make e2e
```

The E2E test will:
- Setup Oracle and MariaDB databases
- Register Debezium source and JDBC sink connectors
- Verify data replication

### 4. Test CDC Operations

```bash
# Test INSERT, UPDATE, DELETE replication
make test
```

### 5. Cleanup

```bash
# Remove connectors only
make clean

# Remove entire cluster
make cluster-delete
```

## Project Structure

```
kafka-dbsync/
├── deployment/          # Helm wrapper charts for deployment
│   ├── kafka/          # Kafka cluster (Bitnami)
│   ├── kafka-connect/  # Confluent Kafka Connect
│   ├── oracle/         # Oracle Database (XE/EE)
│   ├── mariadb/        # MariaDB
│   ├── mssql/          # Microsoft SQL Server
│   └── curl-client/    # Curl client for verification
├── helm-chart/         # Source Helm charts
│   └── */              # Actual chart implementations
├── hack/               # E2E testing and development utilities
│   ├── Makefile        # Automated E2E test orchestration
│   ├── E2E_TEST_ORACLE_CDC.md  # Detailed E2E guide
│   ├── source-debezium/  # Debezium connector configs
│   ├── sink-jdbc/        # JDBC sink connector configs
│   └── sql/              # Database setup scripts
├── tools/              # Tool installers (kubectl, helm, kind, etc.)
└── doc/                # Architecture diagrams (PlantUML)
```

### Deployment Architecture

The project uses a **wrapper chart pattern**:
- `/deployment/*` - Thin wrapper charts that customize base charts for specific deployments
- `/helm-chart/*` - Source charts with full configurations and templates

This allows environment-specific customization without modifying base charts.

## Available Make Targets

### Infrastructure Management

```bash
make tools              # Install kubectl, helm, kind
make cluster            # Create kind cluster
make cluster-delete     # Delete kind cluster
make deploy             # Deploy all services
make deploy-delete      # Remove all services
make wait-ready         # Wait for pods to be ready
make all                # Full setup: cluster + deploy + wait + e2e
```

### E2E Testing

```bash
make e2e                # Run full E2E test
make setup              # Setup databases only
make register           # Register connectors only
make verify             # Verify data replication
make test               # Test CDC operations (INSERT/UPDATE/DELETE)
make clean              # Delete connectors
make reset              # Full reset (connectors + tables)
```

### Utilities

```bash
make port-forward       # Forward Kafka Connect (8083) and UI (8000) ports
make status             # Check connector status
make logs               # Tail Kafka Connect logs
make topics             # List Kafka CDC topics
make pods               # Show pod status
```

## Configuration Modes

### Lightweight Mode (Default)

```bash
make all LIGHTWEIGHT=1
```

- Oracle XE 21c Free (gvenzl/oracle-xe)
- Fast startup (~2-3 minutes)
- Lower resource requirements
- Ideal for development and testing

### Enterprise Mode

```bash
make all LIGHTWEIGHT=0
```

- Oracle EE 19c
- Slower startup (~10 minutes)
- Full Oracle features
- Production-like testing

## Supported CDC Scenarios

### Source Connectors (Debezium)

- **Oracle**: LogMiner-based CDC
- **MSSQL**: SQL Server CDC

### Sink Connectors (JDBC)

- **MariaDB**: JDBC sink with upsert
- Any JDBC-compatible database

### Example Pipelines

1. **Oracle → Kafka → MariaDB** (E2E tested)
2. **MSSQL → Kafka → MariaDB**
3. Custom combinations via connector configs in `hack/`

## Documentation

- [E2E Test Guide](hack/E2E_TEST_ORACLE_CDC.md) - Detailed Oracle CDC to MariaDB walkthrough
- [Makefile Reference](hack/Makefile) - All automation targets and configuration
- Connector Configurations:
  - [Source Debezium Connectors](hack/source-debezium/)
  - [JDBC Sink Connectors](hack/sink-jdbc/)
  - [Database Setup Scripts](hack/sql/)

## Troubleshooting

### Check Pod Status

```bash
make pods
# or
kubectl get pods -n dev
```

### View Connector Logs

```bash
make logs
# or
kubectl logs -f deployment/dbrep-kafka-connect-cp-kafka-connect -n dev
```

### Check Connector Status

```bash
make status
# or
curl http://localhost:8083/connectors/<connector-name>/status | jq
```

### Common Issues

| Issue | Solution |
|-------|----------|
| Pods not starting | Check resources: `docker stats`, increase Docker memory |
| Oracle startup timeout | Use `LIGHTWEIGHT=1` or increase timeout in values |
| Connector FAILED state | Check logs: `make logs`, verify database connectivity |
| No data replicating | Verify topic exists: `make topics`, check connector status |
| Port forwarding fails | Ensure pods are ready: `make pods` |

### Reset Everything

```bash
# Delete cluster and start fresh
make cluster-delete
make all
```

## Development

### Adding New Connectors

1. Create connector config in `hack/source-debezium/` or `hack/sink-jdbc/`
2. Add SQL setup script in `hack/sql/`
3. Add Makefile targets for setup and registration
4. Test with `make e2e`

### Customizing Deployments

Edit values in `deployment/*/values.yaml`:
- Resource limits
- Storage sizes
- Database passwords
- Connector configurations

### Running Manual Tests

```bash
# Start port forwarding
make port-forward

# Register connector manually
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d @hack/source-debezium/oracle-demo.json

# Check status
curl http://localhost:8083/connectors/source_cdc_oracle_demo/status | jq
```

## Contributing

When adding features:
1. Update relevant documentation
2. Add Makefile targets for automation
3. Test in both LIGHTWEIGHT and Enterprise modes
4. Follow existing naming conventions

## License

[Add your license here]

## References

- [Apache Kafka](https://kafka.apache.org/)
- [Debezium](https://debezium.io/)
- [Confluent Kafka Connect](https://docs.confluent.io/platform/current/connect/index.html)
- [Kubernetes](https://kubernetes.io/)
- [Helm](https://helm.sh/)
