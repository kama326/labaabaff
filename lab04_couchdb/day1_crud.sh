#!/bin/bash

# Настройки
COUCH_URL="http://admin:password@localhost:5984"
DB_NAME="music"

echo "Using CouchDB at $COUCH_URL"

# --- День 1 ---

# Создание базы данных
echo "--- Creating database '$DB_NAME' ---"
curl -X PUT "$COUCH_URL/$DB_NAME"

# Вставка документа (The Beatles)
echo -e "\n--- Inserting 'The Beatles' document ---"
response=$(curl -s -X POST "$COUCH_URL/$DB_NAME" \
 -H "Content-Type: application/json" \
 -d '{
   "name": "The Beatles",
   "albums": [
     {"title": "Help!", "year": 1965},
     {"title": "Sgt. Pepper'\''s Lonely Hearts Club Band", "year": 1967},
     {"title": "Abbey Road", "year": 1969}
   ]
 }')
echo $response
doc_id=$(echo $response | grep -o '"id":"[^"]*' | cut -d'"' -f4)
doc_rev=$(echo $response | grep -o '"rev":"[^"]*' | cut -d'"' -f4)

echo "Created document with ID: $doc_id and Rev: $doc_rev"

# Обновление документа (добавление альбома) - PUT требует ID
# Получаем документ
echo -e "\n--- Fetching document ---"
doc_content=$(curl -s "$COUCH_URL/$DB_NAME/$doc_id")
# Модифицируем (упрощенно добавим поле через sed для примера, в реальности лучше jq)
new_doc_content=$(echo $doc_content | sed 's/"name":"The Beatles"/"name":"The Beatles Changed"/')

echo -e "\n--- Updating document ---"
curl -X PUT "$COUCH_URL/$DB_NAME/$doc_id" \
 -H "Content-Type: application/json" \
 -d "$new_doc_content"

# Задание 10.1: Добавить документ с определенным ID
echo -e "\n--- Task 10.1: Add document with specific ID ---"
curl -X PUT "$COUCH_URL/$DB_NAME/my_custom_id" \
 -H "Content-Type: application/json" \
 -d '{"name": "Custom ID Artist"}'

# Задание 10.2: Создать и удалить БД
echo -e "\n--- Task 10.2: Create and Delete temp DB ---"
curl -X PUT "$COUCH_URL/temp_db"
echo "Deleting temp_db..."
curl -X DELETE "$COUCH_URL/temp_db"

# Задание 10.3: Вложения
echo -e "\n--- Task 10.3: Attachments ---"
# Сначала создаем документ
curl -X PUT "$COUCH_URL/$DB_NAME/doc_with_attach" \
 -H "Content-Type: application/json" \
 -d '{"info": "Document for attachment"}'
# Получаем ревизию
rev=$(curl -s "$COUCH_URL/$DB_NAME/doc_with_attach" | grep -o '"_rev":"[^"]*' | cut -d'"' -f4)
# Загружаем вложение
echo "This is a text attachment" > attachment.txt
curl -X PUT "$COUCH_URL/$DB_NAME/doc_with_attach/readme.txt?rev=$rev" \
 -H "Content-Type: text/plain" \
 --data-binary @attachment.txt

echo -e "\n--- Fetching attachment ---"
curl "$COUCH_URL/$DB_NAME/doc_with_attach/readme.txt"

echo -e "\n--- Day 1 Completed ---"
