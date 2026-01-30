#!/bin/bash
COUCH_URL1="http://admin:password@localhost:5984" # Для локального curl, но внутри контейнера надо переопределить или запускать иначе
# Фактически скрипт запускается внутри container couchdb1.
# Для него localhost:5984 это он сам.
# Второй контейнер доступен как couchdb2:5984.

# URLs for curl commands (running inside couchdb1 container)
COUCH_URL1_CURL="http://admin:password@127.0.0.1:5984"
COUCH_URL2_CURL="http://admin:password@couchdb2:5984"

# URLs for replication payloads (how containers see each other names)
COUCH_URL1_INTERNAL="http://admin:password@couchdb1:5984"
COUCH_URL2_INTERNAL="http://admin:password@couchdb2:5984"

DB_NAME="music"
DB_REPL="music-repl"

# --- Репликация ---
echo "--- Enabling Replication from CouchDB1 ($DB_NAME) to CouchDB2 ($DB_REPL) ---"

# Создаем целевую БД на втором узле
curl -X PUT "$COUCH_URL2_CURL/$DB_REPL"

# Запускаем репликацию (на узле 2, источник - узел 1)
curl -X POST "$COUCH_URL2_CURL/_replicate" \
 -H "Content-Type: application/json" \
 -d "{
   \"source\": \"$COUCH_URL1_INTERNAL/$DB_NAME\",
   \"target\": \"$DB_REPL\",
   \"create_target\": true
 }"

echo -e "\n--- Checking replication result ---"
# Проверяем кол-во документов
count1=$(curl -s "$COUCH_URL1_CURL/$DB_NAME" | grep -o '"doc_count":[0-9]*' | cut -d':' -f2)
count2=$(curl -s "$COUCH_URL2_CURL/$DB_REPL" | grep -o '"doc_count":[0-9]*' | cut -d':' -f2)
echo "CouchDB1 docs: $count1"
echo "CouchDB2 docs: $count2"

# --- Конфликты ---
echo -e "\n--- Creating Conflicts ---"
# Создаем документ на обоих узлах с разным содержимым
DOC_ID="conflict_doc"
# Сначала удалим если есть, чтобы начать чисто
curl -X DELETE "$COUCH_URL1_CURL/$DB_NAME/$DOC_ID?rev=$(curl -s "$COUCH_URL1_CURL/$DB_NAME/$DOC_ID" | grep -o '"_rev":"[^"]*' | cut -d'"' -f4)" > /dev/null 2>&1

curl -X PUT "$COUCH_URL1_CURL/$DB_NAME/$DOC_ID" -H "Content-Type: application/json" -d '{"name": "Original"}'
# Реплицируем чтобы он появился везде
curl -X POST "$COUCH_URL2_CURL/_replicate" -H "Content-Type: application/json" -d "{\"source\": \"$COUCH_URL1_INTERNAL/$DB_NAME\", \"target\": \"$DB_REPL\"}" > /dev/null

# Получаем текущую ревизию
rev1=$(curl -s "$COUCH_URL1_CURL/$DB_NAME/$DOC_ID" | grep -o '"_rev":"[^"]*' | cut -d'"' -f4)
rev2=$(curl -s "$COUCH_URL2_CURL/$DB_REPL/$DOC_ID" | grep -o '"_rev":"[^"]*' | cut -d'"' -f4)

# Обновляем на узле 1
curl -X PUT "$COUCH_URL1_CURL/$DB_NAME/$DOC_ID?rev=$rev1" -H "Content-Type: application/json" -d '{"name": "Version 1", "node": 1}'
# Обновляем на узле 2
curl -X PUT "$COUCH_URL2_CURL/$DB_REPL/$DOC_ID?rev=$rev2" -H "Content-Type: application/json" -d '{"name": "Version 2", "node": 2}'

# Реплицируем изменения обратно (Узел 2 -> Узел 1)
echo -e "\n--- Replicating back (conflict generation) ---"
curl -X POST "$COUCH_URL1_CURL/_replicate" \
 -H "Content-Type: application/json" \
 -d "{
   \"source\": \"$COUCH_URL2_INTERNAL/$DB_REPL\",
   \"target\": \"$DB_NAME\"
 }"

# Проверяем конфликты
echo -e "\n--- Checking for conflicts ---"
curl "$COUCH_URL1_CURL/$DB_NAME/$DOC_ID?conflicts=true"

echo -e "\n--- Day 3 Replication Script Completed ---"
