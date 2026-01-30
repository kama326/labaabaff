#!/bin/bash

HOST="nosql_lab_redis"
PORT="6379"
CLI="redis-cli -h $HOST -p $PORT"

echo "--- Day 3: Advanced Redis (Transactions & Persistence) ---"

# 1. Transactions (Atomic transfer)
echo -e "\n1. TRANSACTIONS (Banking Transfer)"
$CLI MSET user:A:balance 1000 user:B:balance 0
echo "Initial balances:"
$CLI MGET user:A:balance user:B:balance

echo "Transferring 100 from A to B..."
# Using redis-cli non-interactive is tricky for transactions, so we simulate by sending multiline input
$CLI <<EOF
MULTI
DECRBY user:A:balance 100
INCRBY user:B:balance 100
EXEC
EOF

echo "Final balances:"
$CLI MGET user:A:balance user:B:balance

# 2. Persistence
echo -e "\n2. PERSISTENCE CONFIG"
echo "Checking Persistence (AOF/RDB)..."
$CLI CONFIG GET appendonly
$CLI CONFIG GET save

echo "Triggering manual snapshot..."
$CLI BGSAVE
echo "Snapshot triggered."

# 3. Key Expiration & Eviction (Simulation)
echo -e "\n3. TTL & POLICIES"
$CLI SET temp:key "I will die soon" EX 2
echo "Key set with 2s TTL. Value:"
$CLI GET temp:key
echo "Sleeping 3s..."
sleep 3
echo "Value after 3s:"
$CLI GET temp:key

echo -e "\nDay 3 Completed."
