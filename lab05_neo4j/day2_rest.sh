#!/bin/bash

NEO4J_URL="http://localhost:7474"
AUTH="Authorization: Basic bmVvNGo6cGFzc3dvcmQ=" # neo4j:password base64

echo "--- Checking Neo4j Status ---"
curl -s -H "$AUTH" "$NEO4J_URL/db/neo4j/tx/commit" -d '{"statements":[]}' | grep "errors"

echo -e "\n\n--- Creating Node via REST (P.G. Wodehouse) ---"
# В neo4j 4+ API changed to transactional endpoint mostly, legacy REST /db/data/node is deprecated/removed in 4.x
# Используем Transactional Cypher HTTP API для всего
curl -s -H "$AUTH" -H "Content-Type: application/json" -X POST "$NEO4J_URL/db/neo4j/tx/commit" -d '{
  "statements": [
    {
      "statement": "CREATE (n:Author {name: $name, genre: $genre}) RETURN n",
      "parameters": {
        "name": "P.G. Wodehouse",
        "genre": "British Humour"
      }
    }
  ]
}'

echo -e "\n\n--- Creating another node and relationship via REST ---"
curl -s -H "$AUTH" -H "Content-Type: application/json" -X POST "$NEO4J_URL/db/neo4j/tx/commit" -d '{
  "statements": [
    {
      "statement": "CREATE (b:Book {title: \"Jeeves Takes Charge\"}) WITH b MATCH (a:Author {name: \"P.G. Wodehouse\"}) CREATE (a)-[:WROTE]->(b) RETURN a, b"
    }
  ]
}'

echo -e "\n\n--- Fulltext Search (Simulated via Cypher CONTAINS/Starts WITH) ---"
# Legacy indexing via REST is replaced by Cypher indexes.
# Creating index via Cypher
curl -s -H "$AUTH" -H "Content-Type: application/json" -X POST "$NEO4J_URL/db/neo4j/tx/commit" -d '{
  "statements": [
    {
      "statement": "CREATE FULLTEXT INDEX bookTitles IF NOT EXISTS FOR (n:Book) ON EACH [n.title]"
    }
  ]
}'

# Searching
echo -e "\nRunning search for 'Jeeves':"
curl -s -H "$AUTH" -H "Content-Type: application/json" -X POST "$NEO4J_URL/db/neo4j/tx/commit" -d '{
  "statements": [
    {
      "statement": "CALL db.index.fulltext.queryNodes(\"bookTitles\", \"Jeeves\") YIELD node, score RETURN node.title, score"
    }
  ]
}'
