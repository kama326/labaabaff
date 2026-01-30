#!/bin/bash
COUCH_URL="http://admin:password@localhost:5984"
DB_NAME="music"

# Создание Design Document 'artists' с представлением 'by_name'
echo "--- Creating view 'artists/by_name' ---"
curl -X PUT "$COUCH_URL/$DB_NAME/_design/artists" \
 -H "Content-Type: application/json" \
 -d '{
   "views": {
     "by_name": {
       "map": "function(doc) { if (doc.name) { emit(doc.name, doc._id); } }"
     }
   }
 }'

# Создание Design Document 'albums' с представлением 'by_name'
echo -e "\n--- Creating view 'albums/by_name' ---"
curl -X PUT "$COUCH_URL/$DB_NAME/_design/albums" \
 -H "Content-Type: application/json" \
 -d '{
   "views": {
     "by_name": {
       "map": "function(doc) { if (doc.name && doc.albums) { doc.albums.forEach(function(album){ emit(album.title, {by: doc.name, album: album}); }); } }"
     }
   }
 }'

# Задание: Создание представления с случайным ключом (Task 11)
echo -e "\n--- Creating view 'random/artist' ---"
curl -X PUT "$COUCH_URL/$DB_NAME/_design/random" \
 -H "Content-Type: application/json" \
 -d '{
   "views": {
     "artist": {
       "map": "function(doc) { if (doc.random) { emit(doc.random, doc.name); } }"
     }
   }
 }'

# Запрос данных
echo -e "\n--- Querying artists/by_name (limit 5) ---"
curl "$COUCH_URL/$DB_NAME/_design/artists/_view/by_name?limit=5"

echo -e "\n--- Querying random/artist (find random) ---"
# Генерируем случайное число на bash
rand="0.$RANDOM"
echo "Random startkey: $rand"
curl "$COUCH_URL/$DB_NAME/_design/random/_view/artist?startkey=$rand&limit=1"

echo -e "\n--- Day 2 Completed ---"
