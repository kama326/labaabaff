#!/bin/bash

# Указываем endpoint-url для локальной DynamoDB (внутри сети Docker)
AWS_CMD="aws dynamodb --endpoint-url http://dynamodb:8000 --region us-east-1"
export AWS_ACCESS_KEY_ID=fake
export AWS_SECRET_ACCESS_KEY=fake

echo "--- Day 3: IoT Queries ---"

# Получаем временные метки для запроса
# В реальном сценарии мы бы брали их динамически, но здесь возьмем примерный диапазон из симуляции
START_TIME=$(date -d '-50 minutes' +%s)
END_TIME=$(date +%s)

echo "Querying sensor-1 data between timestamps..."

$AWS_CMD query --table-name SensorData \
 --expression-attribute-values "{
   \":sensorId\": {\"S\": \"sensor-1\"}, 
   \":t1\": {\"N\": \"0\"}, 
   \":t2\": {\"N\": \"9999999999\"}
 }" \
 --key-condition-expression 'SensorId = :sensorId AND CurrentTime BETWEEN :t1 AND :t2' \
 --projection-expression 'CurrentTime, Temperature' \
 --limit 5

# Запрос с использованием Local Secondary Index (TemperatureIndex)
# Найти моменты, когда температура была выше определенной (например, > 80)
# В DynamoDB Local поддержка LSI полная.

echo -e "\nQuerying High Temperatures (Temperature > 70) using LSI..."
$AWS_CMD query --table-name SensorData \
 --index-name TemperatureIndex \
 --expression-attribute-values "{
   \":sensorId\": {\"S\": \"sensor-1\"},
   \":temp\": {\"N\": \"70\"}
 }" \
 --key-condition-expression 'SensorId = :sensorId AND Temperature > :temp' \
 --limit 5

echo -e "\nDay 3 Queries Completed."
