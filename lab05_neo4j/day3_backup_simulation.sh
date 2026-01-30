#!/bin/bash

# Поскольку мы используем Community Edition в Docker, полноценный HA кластер (Causal Clustering) недоступен без Enterprise лицензии.
# Однако мы можем продемонстрировать команды для бэкапа (dump/load) и описать процесс HA.

echo "--- Day 3: Distributed High Availability & Backup ---"

# 1. Резервное копирование (Backup/Dump)
# В Neo4j 5 команда `neo4j-admin database dump` используется для создания бэкапа офлайн (при остановленной базе) 
# или `neo4j-admin database backup` (онлайн, только Enterprise).
# Мы продемонстрируем dump.

echo -e "\n[Simulation] Stopping database for offline dump..."
# В реальном сценарии: 
# docker stop nosql_lab_neo4j

echo -e "\n[Simulation] Creating dump..."
# В реальном сценарии: 
# docker run --rm --volumes-from nosql_lab_neo4j neo4j:5.16.0-community neo4j-admin database dump neo4j --to-path=/backups

echo "Command to run (hypothetical): neo4j-admin database dump neo4j --to-path=/backups"
echo "Dump created at /backups/neo4j.dump"

# 2. Восстановление (Restore/Load)
echo -e "\n[Simulation] Loading dump..."
echo "Command to run (hypothetical): neo4j-admin database load neo4j --from-path=/backups --overwrite-destination=true"

# 3. Высокая доступность (HA / Causal Clustering)
echo -e "\n--- High Availability (HA) Concepts ---"
echo "В Neo4j (Enterprise) HA реализуется через Causal Clustering."
echo "Кластер состоит из:"
echo "1. Core Servers: Обеспечивают консенсус (Raft protocol), реплицируют данные, обслуживают чтение/запись."
echo "2. Read Replicas: Асинхронно реплицируют данные с Core серверов, обслуживают только чтение (масштабирование графа)."
echo ""
echo "Конфигурация (neo4j.conf):"
echo "dbms.mode=CORE"
echo "initial_discovery_members=node1:5000,node2:5000,node3:5000"
echo ""
echo "В случае падения лидера, происходит перевыборы (Raft)."

echo -e "\n--- Day 3 Script Completed ---"
