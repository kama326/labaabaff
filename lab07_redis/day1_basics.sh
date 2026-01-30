#!/bin/bash

# Ожидание готовности Redis
echo "Waiting for Redis..."
sleep 3

HOST="nosql_lab_redis"
PORT="6379"
CLI="redis-cli -h $HOST -p $PORT"

echo "--- Day 1: Redis Data Types ---"

# 1. Strings
echo -e "\n1. STRINGS (Key-Value)"
$CLI SET user:1:name "Alice"
$CLI GET user:1:name
$CLI INCR user:1:visits
$CLI INCRBY user:1:visits 5
echo "Visits for Alice:"
$CLI GET user:1:visits

# 2. Lists (Queue/Stack)
echo -e "\n2. LISTS (Recent Actions)"
$CLI RPUSH actions:user:1 "login"
$CLI RPUSH actions:user:1 "view_page"
$CLI RPUSH actions:user:1 "logout"
echo "All actions:"
$CLI LRANGE actions:user:1 0 -1
echo "Pop last action:"
$CLI RPOP actions:user:1

# 3. Sets (Unique items)
echo -e "\n3. SETS (Unique IP visits)"
$CLI SADD page:home:ips "192.168.1.1"
$CLI SADD page:home:ips "192.168.1.2"
$CLI SADD page:home:ips "192.168.1.1" # Duplicate ignored
echo "Unique IPs:"
$CLI SMEMBERS page:home:ips

# 4. Hashes (Objects)
echo -e "\n4. HASHES (User Profile)"
$CLI HSET user:100 name "Bob" age "30" email "bob@example.com"
echo "User 100:"
$CLI HGETALL user:100
echo "User 100 email:"
$CLI HGET user:100 email

# 5. Sorted Sets (Leaderboard)
echo -e "\n5. SORTED SETS (Game Leaderboard)"
$CLI ZADD leaderboard 100 "PlayerA"
$CLI ZADD leaderboard 200 "PlayerB"
$CLI ZADD leaderboard 150 "PlayerC"
echo "Top 3 Players:"
$CLI ZREVRANGE leaderboard 0 2 WITHSCORES

echo -e "\nDay 1 Completed."
