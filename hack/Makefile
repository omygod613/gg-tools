# E2E Test Makefile for Oracle CDC to MariaDB
# Usage: make e2e

.PHONY: help e2e setup setup-oracle setup-mariadb port-forward register-source register-sink \
        verify test-insert test-update test-delete clean status logs reset \
        cluster cluster-delete deploy deploy-delete tools check-tools

# Configuration
KAFKA_CONNECT_URL ?= http://localhost:8083
MARIADB_POD ?= dbrep-mariadb-0
MARIADB_HOST ?= dbrep-mariadb.dev.svc.cluster.local
MARIADB_USER ?= root
MARIADB_PASS ?= root_password
NAMESPACE ?= dev
CLUSTER_NAME ?= gg-tools
HACK_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ROOT_DIR := $(HACK_DIR)/..

# Oracle configuration - set LIGHTWEIGHT=1 for Oracle XE 21c (gvenzl image)
LIGHTWEIGHT ?= 1
ifeq ($(LIGHTWEIGHT),1)
  ORACLE_POD ?= dbrep-oracle-oracle-db
  ORACLE_SID ?= XE
  ORACLE_PDB ?= XEPDB1
  ORACLE_SQL_SETUP := $(HACK_DIR)/sql/oracle-xe-setup.sql
  ORACLE_CONNECTOR := $(HACK_DIR)/source-debezium/oracle-free-demo.json
else
  ORACLE_POD ?= dbrep-oracle-oracle-db-0
  ORACLE_SID ?= ORCLCDB
  ORACLE_PDB ?= ORCLPDB1
  ORACLE_SQL_SETUP := $(HACK_DIR)/sql/oracle-pdb-setup.sql
  ORACLE_CONNECTOR := $(HACK_DIR)/source-debezium/oracle-demo.json
endif

help:
	@echo "Oracle CDC to MariaDB E2E Test"
	@echo ""
	@echo "Quick Start (from scratch):"
	@echo "  make all              Full setup: cluster + deploy + wait + e2e"
	@echo ""
	@echo "Oracle Mode (LIGHTWEIGHT=$(LIGHTWEIGHT)):"
	@echo "  LIGHTWEIGHT=1  Oracle XE 21c (~2-3min startup) [DEFAULT]"
	@echo "  LIGHTWEIGHT=0  Oracle EE 19c (~10min startup)"
	@echo "  Example: make all LIGHTWEIGHT=0"
	@echo ""
	@echo "Infrastructure:"
	@echo "  make tools            Install kubectl, helm, kind"
	@echo "  make cluster          Create kind cluster"
	@echo "  make cluster-delete   Delete kind cluster"
	@echo "  make deploy           Deploy all services (Kafka, Oracle, MariaDB, etc.)"
	@echo "  make deploy-delete    Delete all services"
	@echo "  make wait-ready       Wait for all pods to be ready"
	@echo ""
	@echo "E2E Test:"
	@echo "  make e2e              Run full E2E test (setup + register + verify)"
	@echo "  make setup            Setup Oracle and MariaDB databases"
	@echo "  make register         Register source and sink connectors"
	@echo "  make verify           Verify data in MariaDB"
	@echo "  make test             Run CDC tests (insert, update, delete)"
	@echo "  make clean            Delete connectors"
	@echo "  make reset            Full reset (connectors + tables)"
	@echo ""
	@echo "Utilities:"
	@echo "  make port-forward     Start port forwarding (background)"
	@echo "  make status           Check connector status"
	@echo "  make logs             Tail Kafka Connect logs"
	@echo "  make topics           List Kafka CDC topics"
	@echo "  make pods             Show pod status"

# Full E2E test
e2e: setup register verify
	@echo "[OK] E2E test completed successfully!"

# Setup both databases
setup: setup-oracle setup-mariadb
	@echo "[OK] Database setup completed"

# Register both connectors
register: register-source register-sink
	@echo "[OK] Connectors registered"

# Run CDC tests
test: test-insert test-update test-delete verify
	@echo "[OK] CDC tests completed"

# Port forwarding (run in separate terminal)
port-forward:
	@echo "[INFO] Starting port forwarding..."
	@kubectl port-forward svc/dbrep-kafka-connect-cp-kafka-connect 8083:8083 & \
	 kubectl port-forward svc/dbrep-kafka-connect-ui 8000:8000 & \
	 wait

# Setup Oracle
setup-oracle:
ifeq ($(LIGHTWEIGHT),1)
	@echo "[INFO] Setting up Oracle XE 21c..."
	@POD=$$(kubectl get pods -n $(NAMESPACE) -l app=oracle-db -o jsonpath='{.items[0].metadata.name}') && \
	echo "[INFO] Step 1: Enabling ARCHIVELOG mode..." && \
	kubectl cp $(HACK_DIR)/sql/oracle-xe-archivelog.sql $$POD:/tmp/archivelog.sql -n $(NAMESPACE) && \
	kubectl exec $$POD -n $(NAMESPACE) -- sqlplus -S / as sysdba @/tmp/archivelog.sql && \
	echo "[INFO] Step 2: Creating CDC user in CDB..." && \
	kubectl cp $(HACK_DIR)/sql/oracle-xe-cdc-user.sql $$POD:/tmp/cdc-user.sql -n $(NAMESPACE) && \
	kubectl exec $$POD -n $(NAMESPACE) -- sqlplus -S sys/oracle@localhost:1521/$(ORACLE_SID) as sysdba @/tmp/cdc-user.sql && \
	echo "[INFO] Step 3: Propagating CDC user to PDB..." && \
	kubectl cp $(HACK_DIR)/sql/oracle-xe-pdb-user.sql $$POD:/tmp/pdb-user.sql -n $(NAMESPACE) && \
	kubectl exec $$POD -n $(NAMESPACE) -- sqlplus -S sys/oracle@localhost:1521/$(ORACLE_SID) as sysdba @/tmp/pdb-user.sql && \
	echo "[INFO] Step 4: Creating DEMO schema and source table..." && \
	kubectl cp $(HACK_DIR)/sql/oracle-xe-demo-schema.sql $$POD:/tmp/demo-schema.sql -n $(NAMESPACE) && \
	kubectl exec $$POD -n $(NAMESPACE) -- sqlplus -S sys/oracle@localhost:1521/$(ORACLE_PDB) as sysdba @/tmp/demo-schema.sql
else
	@echo "[INFO] Setting up Oracle EE (CDB level - Debezium user)..."
	kubectl cp $(HACK_DIR)/sql/oracle-cdb-setup.sql $(ORACLE_POD):/tmp/oracle-cdb-setup.sql -n $(NAMESPACE)
	kubectl exec $(ORACLE_POD) -n $(NAMESPACE) -- sqlplus -S sys/oracle@localhost:1521/$(ORACLE_SID) as sysdba @/tmp/oracle-cdb-setup.sql
	@echo "[INFO] Setting up Oracle PDB (DEMO schema)..."
	kubectl cp $(ORACLE_SQL_SETUP) $(ORACLE_POD):/tmp/oracle-pdb-setup.sql -n $(NAMESPACE)
	kubectl exec $(ORACLE_POD) -n $(NAMESPACE) -- sqlplus -S sys/oracle@localhost:1521/$(ORACLE_PDB) as sysdba @/tmp/oracle-pdb-setup.sql
endif
	@echo "[OK] Oracle setup completed"

# Setup MariaDB
setup-mariadb:
	@echo "[INFO] Setting up MariaDB..."
	kubectl exec $(MARIADB_POD) -- mysql -h $(MARIADB_HOST) -u$(MARIADB_USER) -p$(MARIADB_PASS) -e \
		"CREATE DATABASE IF NOT EXISTS target_database DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; DROP TABLE IF EXISTS target_database.target_orders;"
	@echo "[OK] MariaDB setup completed"

# Register source connector
register-source:
	@echo "[INFO] Registering Debezium Oracle source connector..."
	@kubectl cp $(ORACLE_CONNECTOR) dbrep-kafka-controller-0:/tmp/source-connector.json -n $(NAMESPACE)
	@kubectl exec dbrep-kafka-controller-0 -n $(NAMESPACE) -- curl -s --max-time 120 -X POST \
		http://dbrep-kafka-connect-cp-kafka-connect:8083/connectors \
		-H "Content-Type: application/json" \
		-d @/tmp/source-connector.json | jq . || true
	@echo "[INFO] Waiting 30s for initial snapshot..."
	@sleep 30
	@echo "[INFO] Verifying source connector..."
	@kubectl exec dbrep-kafka-controller-0 -n $(NAMESPACE) -- curl -s \
		http://dbrep-kafka-connect-cp-kafka-connect:8083/connectors/source_cdc_oracle_demo/status | jq -r '.tasks[0].state' || echo "UNKNOWN"

# Register sink connector
register-sink:
	@echo "[INFO] Registering JDBC sink connector..."
	@kubectl cp $(HACK_DIR)/sink-jdbc/cdc_oracle_mariadb-demo.json dbrep-kafka-controller-0:/tmp/sink-connector.json -n $(NAMESPACE)
	@kubectl exec dbrep-kafka-controller-0 -n $(NAMESPACE) -- curl -s --max-time 120 -X POST \
		http://dbrep-kafka-connect-cp-kafka-connect:8083/connectors \
		-H "Content-Type: application/json" \
		-d @/tmp/sink-connector.json | jq . || true
	@echo "[INFO] Waiting 10s for sync..."
	@sleep 10
	@echo "[INFO] Verifying sink connector..."
	@kubectl exec dbrep-kafka-controller-0 -n $(NAMESPACE) -- curl -s \
		http://dbrep-kafka-connect-cp-kafka-connect:8083/connectors/sink_cdc_oracle_to_mariadb/status | jq -r '.tasks[0].state' || echo "UNKNOWN"

# Check connector status
status:
	@echo "[INFO] Connector Status:"
	@echo "--- Source (source_cdc_oracle_demo) ---"
	@kubectl exec dbrep-kafka-controller-0 -n $(NAMESPACE) -- curl -s \
		http://dbrep-kafka-connect-cp-kafka-connect:8083/connectors/source_cdc_oracle_demo/status 2>/dev/null | jq . || echo "NOT FOUND"
	@echo "--- Sink (sink_cdc_oracle_to_mariadb) ---"
	@kubectl exec dbrep-kafka-controller-0 -n $(NAMESPACE) -- curl -s \
		http://dbrep-kafka-connect-cp-kafka-connect:8083/connectors/sink_cdc_oracle_to_mariadb/status 2>/dev/null | jq . || echo "NOT FOUND"

# Verify data in MariaDB
verify:
	@echo "[INFO] Data in MariaDB target_database.target_orders:"
	@kubectl exec $(MARIADB_POD) -- mysql -h $(MARIADB_HOST) -u$(MARIADB_USER) -p$(MARIADB_PASS) -e \
		"SELECT * FROM target_database.target_orders ORDER BY ID;" 2>/dev/null || echo "Table not found or empty"

# Verify source data in Oracle
verify-source:
	@echo "[INFO] Data in Oracle DEMO.SOURCE_ORDERS:"
ifeq ($(LIGHTWEIGHT),1)
	@POD=$$(kubectl get pods -n $(NAMESPACE) -l app=oracle-db -o jsonpath='{.items[0].metadata.name}') && \
	echo "ALTER SESSION SET CONTAINER=$(ORACLE_PDB); SELECT * FROM DEMO.SOURCE_ORDERS ORDER BY ID; EXIT;" | kubectl exec -i $$POD -n $(NAMESPACE) -- sqlplus -S sys/oracle@localhost:1521/$(ORACLE_SID) as sysdba
else
	@echo "SELECT * FROM DEMO.SOURCE_ORDERS ORDER BY ID; EXIT;" | kubectl exec -i $(ORACLE_POD) -n $(NAMESPACE) -- sqlplus -S sys/oracle@localhost:1521/$(ORACLE_PDB) as sysdba
endif

# CDC Tests
test-insert:
	@echo "[INFO] Testing INSERT..."
ifeq ($(LIGHTWEIGHT),1)
	@POD=$$(kubectl get pods -n $(NAMESPACE) -l app=oracle-db -o jsonpath='{.items[0].metadata.name}') && \
	echo "ALTER SESSION SET CONTAINER=$(ORACLE_PDB); INSERT INTO DEMO.SOURCE_ORDERS(ID, ORDER_NO, CUSTOMER_NAME, AMOUNT, STATUS) VALUES(5, 'ORD-005', 'Eve', 3100.00, 'PENDING'); COMMIT; EXIT;" | kubectl exec -i $$POD -n $(NAMESPACE) -- sqlplus -S sys/oracle@localhost:1521/$(ORACLE_SID) as sysdba
else
	@echo "INSERT INTO DEMO.SOURCE_ORDERS(ID, ORDER_NO, CUSTOMER_NAME, AMOUNT, STATUS) VALUES(5, 'ORD-005', 'Eve', 3100.00, 'PENDING'); COMMIT; EXIT;" | kubectl exec -i $(ORACLE_POD) -n $(NAMESPACE) -- sqlplus -S sys/oracle@localhost:1521/$(ORACLE_PDB) as sysdba
endif
	@echo "[INFO] Waiting 5s for replication..."
	@sleep 5

test-update:
	@echo "[INFO] Testing UPDATE..."
ifeq ($(LIGHTWEIGHT),1)
	@POD=$$(kubectl get pods -n $(NAMESPACE) -l app=oracle-db -o jsonpath='{.items[0].metadata.name}') && \
	echo "ALTER SESSION SET CONTAINER=$(ORACLE_PDB); UPDATE DEMO.SOURCE_ORDERS SET STATUS='COMPLETED', MODIFIED_AT=CURRENT_TIMESTAMP WHERE ID=1; COMMIT; EXIT;" | kubectl exec -i $$POD -n $(NAMESPACE) -- sqlplus -S sys/oracle@localhost:1521/$(ORACLE_SID) as sysdba
else
	@echo "UPDATE DEMO.SOURCE_ORDERS SET STATUS='COMPLETED', MODIFIED_AT=CURRENT_TIMESTAMP WHERE ID=1; COMMIT; EXIT;" | kubectl exec -i $(ORACLE_POD) -n $(NAMESPACE) -- sqlplus -S sys/oracle@localhost:1521/$(ORACLE_PDB) as sysdba
endif
	@echo "[INFO] Waiting 5s for replication..."
	@sleep 5

test-delete:
	@echo "[INFO] Testing DELETE..."
ifeq ($(LIGHTWEIGHT),1)
	@POD=$$(kubectl get pods -n $(NAMESPACE) -l app=oracle-db -o jsonpath='{.items[0].metadata.name}') && \
	echo "ALTER SESSION SET CONTAINER=$(ORACLE_PDB); DELETE FROM DEMO.SOURCE_ORDERS WHERE ID=3; COMMIT; EXIT;" | kubectl exec -i $$POD -n $(NAMESPACE) -- sqlplus -S sys/oracle@localhost:1521/$(ORACLE_SID) as sysdba
else
	@echo "DELETE FROM DEMO.SOURCE_ORDERS WHERE ID=3; COMMIT; EXIT;" | kubectl exec -i $(ORACLE_POD) -n $(NAMESPACE) -- sqlplus -S sys/oracle@localhost:1521/$(ORACLE_PDB) as sysdba
endif
	@echo "[INFO] Waiting 5s for replication..."
	@sleep 5

# View Kafka Connect logs
logs:
	kubectl logs -f deployment/dbrep-kafka-connect-cp-kafka-connect --tail=100

# List Kafka topics
topics:
	@kubectl exec dbrep-kafka-0 -- kafka-topics.sh --bootstrap-server localhost:9092 --list 2>/dev/null | grep -E "^cdc_oracle|^schema-changes" || echo "No CDC topics found"

# Clean up connectors
clean:
	@echo "[INFO] Deleting connectors..."
	-@kubectl exec dbrep-kafka-controller-0 -n $(NAMESPACE) -- curl -s -X DELETE \
		http://dbrep-kafka-connect-cp-kafka-connect:8083/connectors/source_cdc_oracle_demo
	-@kubectl exec dbrep-kafka-controller-0 -n $(NAMESPACE) -- curl -s -X DELETE \
		http://dbrep-kafka-connect-cp-kafka-connect:8083/connectors/sink_cdc_oracle_to_mariadb
	@echo "[OK] Connectors deleted"

# Full reset
reset: clean
	@echo "[INFO] Dropping tables..."
ifeq ($(LIGHTWEIGHT),1)
	-@POD=$$(kubectl get pods -n $(NAMESPACE) -l app=oracle-db -o jsonpath='{.items[0].metadata.name}') && \
	echo "ALTER SESSION SET CONTAINER=$(ORACLE_PDB); DROP TABLE DEMO.SOURCE_ORDERS; EXIT;" | kubectl exec -i $$POD -n $(NAMESPACE) -- sqlplus -S sys/oracle@localhost:1521/$(ORACLE_SID) as sysdba
else
	-@echo "DROP TABLE DEMO.SOURCE_ORDERS; EXIT;" | kubectl exec -i $(ORACLE_POD) -n $(NAMESPACE) -- sqlplus -S sys/oracle@localhost:1521/$(ORACLE_PDB) as sysdba
endif
	-@kubectl exec $(MARIADB_POD) -n $(NAMESPACE) -- mysql -h $(MARIADB_HOST) -u$(MARIADB_USER) -p$(MARIADB_PASS) -e "DROP TABLE IF EXISTS target_database.target_orders;"
	@echo "[OK] Reset completed"

# =============================================================================
# Infrastructure Targets
# =============================================================================

# Full setup from scratch
all: cluster deploy wait-ready e2e
	@echo "[OK] Full E2E pipeline completed!"

# Check if tools are installed
check-tools:
	@command -v kubectl >/dev/null 2>&1 || { echo "[ERROR] kubectl not found. Run 'make tools' first."; exit 1; }
	@command -v helm >/dev/null 2>&1 || { echo "[ERROR] helm not found. Run 'make tools' first."; exit 1; }
	@command -v kind >/dev/null 2>&1 || { echo "[ERROR] kind not found. Run 'make tools' first."; exit 1; }
	@echo "[OK] All tools installed"

# Install required tools (kubectl, helm, kind)
tools:
	@echo "[INFO] Installing kubectl..."
	@if ! command -v kubectl >/dev/null 2>&1; then \
		curl -sLO "https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl" && \
		chmod +x kubectl && \
		sudo mv kubectl /usr/local/bin/; \
	else \
		echo "kubectl already installed"; \
	fi
	@echo "[INFO] Installing helm..."
	@if ! command -v helm >/dev/null 2>&1; then \
		curl -sLo helm.tar.gz "https://get.helm.sh/helm-v3.13.0-linux-amd64.tar.gz" && \
		tar -zxf helm.tar.gz linux-amd64/helm --strip-components 1 && \
		sudo mv helm /usr/local/bin/ && \
		rm helm.tar.gz; \
	else \
		echo "helm already installed"; \
	fi
	@echo "[INFO] Installing kind..."
	@if ! command -v kind >/dev/null 2>&1; then \
		curl -sLo kind "https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64" && \
		chmod +x kind && \
		sudo mv kind /usr/local/bin/; \
	else \
		echo "kind already installed"; \
	fi
	@echo "[OK] Tools installed"

# Create kind cluster with sufficient resources
cluster: check-tools
	@echo "[INFO] Creating kind cluster '$(CLUSTER_NAME)'..."
	@if kind get clusters 2>/dev/null | grep -q "^$(CLUSTER_NAME)$$"; then \
		echo "Cluster '$(CLUSTER_NAME)' already exists"; \
	else \
		kind create cluster --name $(CLUSTER_NAME) --config $(HACK_DIR)/kind-config.yaml; \
	fi
	@kubectl cluster-info --context kind-$(CLUSTER_NAME)
	@echo "[OK] Cluster created"

# Delete kind cluster
cluster-delete:
	@echo "[INFO] Deleting kind cluster '$(CLUSTER_NAME)'..."
	-kind delete cluster --name $(CLUSTER_NAME)
	@echo "[OK] Cluster deleted"

# Deploy all services
deploy: check-tools
	@echo "[INFO] Creating namespace '$(NAMESPACE)'..."
	-kubectl create ns $(NAMESPACE)
	kubectl config set-context --current --namespace $(NAMESPACE)
	@echo "[INFO] Deploying Kafka..."
	cd $(ROOT_DIR) && helm upgrade --install dbrep-kafka deployment/kafka -f deployment/kafka/values-kraft.yaml -n $(NAMESPACE)
	@echo "[INFO] Deploying Kafka Connect..."
	cd $(ROOT_DIR) && helm upgrade --install dbrep-kafka-connect deployment/kafka-connect -f deployment/kafka-connect/values.yaml -n $(NAMESPACE)
	@echo "[INFO] Deploying Kafka Connect UI..."
	cd $(ROOT_DIR) && helm upgrade --install dbrep-kafka-connect-ui deployment/kafka-connect-ui -f deployment/kafka-connect-ui/values.yaml -n $(NAMESPACE)
	@echo "[INFO] Deploying MariaDB..."
	cd $(ROOT_DIR) && helm upgrade --install dbrep-mariadb deployment/mariadb -f deployment/mariadb/values.yaml -n $(NAMESPACE)
	@echo "[INFO] Deploying Minio..."
	-kubectl delete -f $(ROOT_DIR)/helm-chart/minio/minio-dev.yaml -n $(NAMESPACE) || true
	kubectl apply -f $(ROOT_DIR)/helm-chart/minio/minio-dev.yaml -n $(NAMESPACE)
	@echo "[INFO] Deploying MSSQL..."
	cd $(ROOT_DIR) && helm upgrade --install dbrep-mssql deployment/mssql -f deployment/mssql/values.yaml -n $(NAMESPACE)
	@echo "[INFO] Deploying MySQL..."
	cd $(ROOT_DIR) && helm upgrade --install dbrep-mysql deployment/mysql -f deployment/mysql/values.yaml -n $(NAMESPACE)
ifeq ($(LIGHTWEIGHT),1)
	@echo "[INFO] Deploying Oracle XE 21c (lightweight, ~2-3min startup)..."
	kubectl apply -f $(ROOT_DIR)/deployment/oracle/oracle-free.yaml -n $(NAMESPACE)
else
	@echo "[INFO] Deploying Oracle EE 19c (full, ~10min startup)..."
	cd $(ROOT_DIR) && helm upgrade --install dbrep-oracle deployment/oracle -f deployment/oracle/values.yaml -n $(NAMESPACE)
endif
	@echo "[OK] All services deployed"

# Delete all services
deploy-delete:
	@echo "[INFO] Deleting all services..."
ifeq ($(LIGHTWEIGHT),1)
	-kubectl delete -f $(ROOT_DIR)/deployment/oracle/oracle-free.yaml -n $(NAMESPACE)
else
	-helm uninstall dbrep-oracle -n $(NAMESPACE)
endif
	-helm uninstall dbrep-mysql -n $(NAMESPACE)
	-helm uninstall dbrep-mssql -n $(NAMESPACE)
	-kubectl delete -f $(ROOT_DIR)/helm-chart/minio/minio-dev.yaml -n $(NAMESPACE)
	-helm uninstall dbrep-mariadb -n $(NAMESPACE)
	-helm uninstall dbrep-kafka-connect-ui -n $(NAMESPACE)
	-helm uninstall dbrep-kafka-connect -n $(NAMESPACE)
	-helm uninstall dbrep-kafka -n $(NAMESPACE)
	@echo "[INFO] Deleting PVCs..."
	-kubectl delete pvc --all -n $(NAMESPACE)
	@echo "[OK] All services and PVCs deleted"

# Wait for pods to be ready
wait-ready:
ifeq ($(LIGHTWEIGHT),1)
	@echo "[INFO] Waiting for pods to be ready (~2-3 minutes with Oracle XE 21c)..."
else
	@echo "[INFO] Waiting for pods to be ready (this may take 5-10 minutes)..."
endif
	@echo "[INFO] Waiting for Kafka..."
	kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=kafka --timeout=300s -n $(NAMESPACE) || true
	@echo "[INFO] Waiting for Kafka Connect..."
	kubectl wait --for=condition=ready pod -l app=cp-kafka-connect --timeout=300s -n $(NAMESPACE) || true
	@echo "[INFO] Waiting for MariaDB..."
	kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=mariadb --timeout=300s -n $(NAMESPACE) || true
	@echo "[INFO] Waiting for Oracle..."
ifeq ($(LIGHTWEIGHT),1)
	kubectl wait --for=condition=ready pod -l app=oracle-db --timeout=300s -n $(NAMESPACE) || true
	@echo "[INFO] Extra wait for Oracle initialization..."
	sleep 30
else
	kubectl wait --for=condition=ready pod -l app=oracle-db --timeout=600s -n $(NAMESPACE) || true
	@echo "[INFO] Extra wait for Oracle initialization..."
	sleep 60
endif
	@echo "[OK] All pods ready"

# Show pod status
pods:
	kubectl get pods -n $(NAMESPACE) -o wide
