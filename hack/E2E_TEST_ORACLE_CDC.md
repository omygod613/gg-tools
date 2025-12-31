# E2E Test: Oracle CDC to MariaDB

This guide walks through testing the Debezium Oracle CDC pipeline that replicates data from Oracle to MariaDB via Kafka.

## Architecture

```
Oracle (ORCLPDB1.DEMO.SOURCE_ORDERS)
    │
    ▼ Debezium Oracle Connector (LogMiner)
    │
Kafka (cdc_oracle.DEMO.SOURCE_ORDERS)
    │
    ▼ JDBC Sink Connector
    │
MariaDB (target_database.target_orders)
```

## Prerequisites

- Kubernetes cluster with kubectl configured
- Helm 3.x installed
- All services deployed via `script/install_dbrs.sh`

## Step 1: Start Port Forwarding

```bash
bash script/port-forward.sh
```

This exposes:
- Kafka Connect REST API: http://localhost:8083
- Kafka Connect UI: http://localhost:8000

## Step 2: Setup Oracle Database

Connect to Oracle as SYSDBA:

```bash
kubectl exec -it dbrep-oracle-oracle-db-0 -- sqlplus sys/oracle@localhost:1521/ORCLCDB as sysdba
```

Run the following SQL to create Debezium user and grant privileges:

```sql
-- Enable Oracle script mode
alter session set "_ORACLE_SCRIPT"=true;

-- Create Debezium common user (CDB level)
CREATE USER c##dbzuser IDENTIFIED BY dbz DEFAULT TABLESPACE users QUOTA UNLIMITED ON users CONTAINER=ALL;

-- Grant LogMiner privileges
GRANT CREATE SESSION TO c##dbzuser CONTAINER=ALL;
GRANT SET CONTAINER TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ON V_$DATABASE TO c##dbzuser CONTAINER=ALL;
GRANT FLASHBACK ANY TABLE TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ANY TABLE TO c##dbzuser CONTAINER=ALL;
GRANT SELECT_CATALOG_ROLE TO c##dbzuser CONTAINER=ALL;
GRANT EXECUTE_CATALOG_ROLE TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ANY TRANSACTION TO c##dbzuser CONTAINER=ALL;
GRANT LOGMINING TO c##dbzuser CONTAINER=ALL;
GRANT CREATE TABLE TO c##dbzuser CONTAINER=ALL;
GRANT LOCK ANY TABLE TO c##dbzuser CONTAINER=ALL;
GRANT CREATE SEQUENCE TO c##dbzuser CONTAINER=ALL;
GRANT EXECUTE ON DBMS_LOGMNR TO c##dbzuser CONTAINER=ALL;
GRANT EXECUTE ON DBMS_LOGMNR_D TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ON V_$LOG TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ON V_$LOG_HISTORY TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ON V_$LOGMNR_LOGS TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ON V_$LOGMNR_CONTENTS TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ON V_$LOGMNR_PARAMETERS TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ON V_$LOGFILE TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ON V_$ARCHIVED_LOG TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ON V_$ARCHIVE_DEST_STATUS TO c##dbzuser CONTAINER=ALL;
GRANT SELECT ON V_$TRANSACTION TO c##dbzuser CONTAINER=ALL;

-- Switch to PDB
ALTER SESSION SET CONTAINER=ORCLPDB1;

-- Create DEMO schema
CREATE USER DEMO IDENTIFIED BY demo123 DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;
GRANT CONNECT, RESOURCE TO DEMO;
GRANT CREATE SESSION TO DEMO;

-- Create source table
CREATE TABLE DEMO.SOURCE_ORDERS (
    ID NUMBER(10) NOT NULL PRIMARY KEY,
    ORDER_NO VARCHAR2(50) NOT NULL,
    CUSTOMER_NAME VARCHAR2(100) NOT NULL,
    AMOUNT NUMBER(15,2) NOT NULL,
    STATUS VARCHAR2(20) DEFAULT 'PENDING' NOT NULL,
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    MODIFIED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Enable supplemental logging (required for CDC)
ALTER TABLE DEMO.SOURCE_ORDERS ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;

-- Insert test data
INSERT INTO DEMO.SOURCE_ORDERS(ID, ORDER_NO, CUSTOMER_NAME, AMOUNT, STATUS) VALUES(1, 'ORD-001', 'Alice', 1500.00, 'PENDING');
INSERT INTO DEMO.SOURCE_ORDERS(ID, ORDER_NO, CUSTOMER_NAME, AMOUNT, STATUS) VALUES(2, 'ORD-002', 'Bob', 2300.50, 'COMPLETED');
INSERT INTO DEMO.SOURCE_ORDERS(ID, ORDER_NO, CUSTOMER_NAME, AMOUNT, STATUS) VALUES(3, 'ORD-003', 'Charlie', 890.00, 'PENDING');
INSERT INTO DEMO.SOURCE_ORDERS(ID, ORDER_NO, CUSTOMER_NAME, AMOUNT, STATUS) VALUES(4, 'ORD-004', 'Diana', 4200.75, 'SHIPPED');
COMMIT;
```

## Step 3: Setup MariaDB Database

Connect to MariaDB:

```bash
kubectl exec -it dbrep-mariadb-0 -- mysql -h dbrep-mariadb.devns3.svc.cluster.local -uroot -proot_password
```

Create the target database:

```sql
CREATE DATABASE IF NOT EXISTS `target_database` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Note: The `target_orders` table will be auto-created by the sink connector.

## Step 4: Register Source Connector (Debezium Oracle)

```bash
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d @hack/source-debezium/oracle-demo.json
```

Verify connector status:

```bash
curl http://localhost:8083/connectors/source_cdc_oracle_demo/status | jq
```

## Step 5: Register Sink Connector (JDBC MariaDB)

Wait for the source connector to complete initial snapshot (check status), then:

```bash
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d @hack/sink-jdbc/cdc_oracle_mariadb-demo.json
```

Verify connector status:

```bash
curl http://localhost:8083/connectors/sink_cdc_oracle_to_mariadb/status | jq
```

## Step 6: Verify Initial Sync

Check MariaDB for replicated data:

```bash
kubectl exec -it dbrep-mariadb-0 -- mysql -h dbrep-mariadb.devns3.svc.cluster.local -uroot -proot_password -e "SELECT * FROM target_database.target_orders;"
```

Expected output: 4 rows matching Oracle source data.

## Step 7: Test CDC (Change Data Capture)

### Test INSERT

In Oracle (ORCLPDB1):

```sql
INSERT INTO DEMO.SOURCE_ORDERS(ID, ORDER_NO, CUSTOMER_NAME, AMOUNT, STATUS) VALUES(5, 'ORD-005', 'Eve', 3100.00, 'PENDING');
COMMIT;
```

### Test UPDATE

```sql
UPDATE DEMO.SOURCE_ORDERS SET STATUS='COMPLETED', MODIFIED_AT=CURRENT_TIMESTAMP WHERE ID=1;
COMMIT;
```

### Test DELETE

```sql
DELETE FROM DEMO.SOURCE_ORDERS WHERE ID=3;
COMMIT;
```

### Verify Changes in MariaDB

```bash
kubectl exec -it dbrep-mariadb-0 -- mysql -h dbrep-mariadb.devns3.svc.cluster.local -uroot -proot_password -e "SELECT * FROM target_database.target_orders ORDER BY ID;"
```

Expected:
- Row ID=5 should appear (INSERT)
- Row ID=1 should have STATUS='COMPLETED' (UPDATE)
- Row ID=3 should be deleted (DELETE)

## Troubleshooting

### Check Connector Logs

```bash
kubectl logs -f deployment/dbrep-kafka-connect-cp-kafka-connect --tail=100
```

### Check Kafka Topics

```bash
kubectl exec -it dbrep-kafka-0 -- kafka-topics.sh --bootstrap-server localhost:9092 --list | grep cdc_oracle
```

### Consume Messages from Topic

```bash
kubectl exec -it dbrep-kafka-0 -- kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic cdc_oracle.DEMO.SOURCE_ORDERS \
  --from-beginning \
  --max-messages 5
```

### Delete Connectors (Reset)

```bash
curl -X DELETE http://localhost:8083/connectors/source_cdc_oracle_demo
curl -X DELETE http://localhost:8083/connectors/sink_cdc_oracle_to_mariadb
```

### Common Issues

| Issue | Solution |
|-------|----------|
| ORA-01031: insufficient privileges | Re-run GRANT statements as SYSDBA |
| Connector FAILED state | Check logs, verify database connectivity |
| No data in MariaDB | Verify topic exists, check sink connector status |
| Schema mismatch errors | Drop target table, let auto.create recreate it |

## Connector Configuration Reference

### Source: `hack/source-debezium/oracle-demo.json`

| Property | Value | Description |
|----------|-------|-------------|
| connector.class | io.debezium.connector.oracle.OracleConnector | Debezium Oracle connector |
| database.pdb.name | ORCLPDB1 | Pluggable database name |
| table.include.list | DEMO.SOURCE_ORDERS | Tables to capture |
| topic.prefix | cdc_oracle | Kafka topic prefix |
| log.mining.strategy | online_catalog | Use online catalog for mining |

### Sink: `hack/sink-jdbc/cdc_oracle_mariadb-demo.json`

| Property | Value | Description |
|----------|-------|-------------|
| connector.class | io.confluent.connect.jdbc.JdbcSinkConnector | Confluent JDBC sink |
| topics | cdc_oracle.DEMO.SOURCE_ORDERS | Source Kafka topic |
| insert.mode | upsert | Handle duplicates via upsert |
| pk.mode | record_key | Use message key as primary key |
| auto.create | true | Auto-create target table |
| delete.enabled | true | Process delete events |
