#!/bin/bash

# Указываем endpoint-url для локальной DynamoDB (внутри сети Docker)
AWS_CMD="aws dynamodb --endpoint-url http://dynamodb:8000 --region us-east-1"

# Настройка фиктивных кредов (если aws cli требует)
export AWS_ACCESS_KEY_ID=fake
export AWS_SECRET_ACCESS_KEY=fake

echo "--- Day 1: Tables and Items ---"

# 1. Создание таблицы ShoppingCart
echo -e "\nCreating ShoppingCart table..."
$AWS_CMD create-table \
    --table-name ShoppingCart \
    --attribute-definitions AttributeName=ItemName,AttributeType=S \
    --key-schema AttributeName=ItemName,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1

echo -e "\nListing tables..."
$AWS_CMD list-tables

# 2. CRUD
echo -e "\nPutting Item (Tickle Me Elmo)..."
$AWS_CMD put-item --table-name ShoppingCart --item '{"ItemName": {"S": "Tickle Me Elmo"}}'

echo -e "\nScanning table..."
$AWS_CMD scan --table-name ShoppingCart

echo -e "\nGetting Item..."
$AWS_CMD get-item --table-name ShoppingCart --key '{"ItemName": {"S": "Tickle Me Elmo"}}'

echo -e "\nDeleting Item..."
$AWS_CMD delete-item --table-name ShoppingCart --key '{"ItemName": {"S": "Tickle Me Elmo"}}'

# 3. Таблица Books с индексами (демонстрация сканирования/запроса)
echo -e "\nCreating Books table..."
$AWS_CMD create-table \
 --table-name Books \
 --attribute-definitions AttributeName=Title,AttributeType=S AttributeName=PublishYear,AttributeType=N \
 --key-schema AttributeName=Title,KeyType=HASH AttributeName=PublishYear,KeyType=RANGE \
 --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1

echo -e "\nPopulating Books..."
$AWS_CMD put-item --table-name Books --item '{"Title": {"S": "Moby Dick"}, "PublishYear": {"N": "1971"}, "ISBN": {"N": "23456"}}'
$AWS_CMD put-item --table-name Books --item '{"Title": {"S": "Moby Dick"}, "PublishYear": {"N": "2008"}, "ISBN": {"N": "34567"}}'

echo -e "\nQuerying Books (Moby Dick > 1980)..."
$AWS_CMD query --table-name Books \
 --expression-attribute-values '{":title": {"S": "Moby Dick"},":year": {"N": "1980"}}' \
 --key-condition-expression 'Title = :title AND PublishYear > :year'

echo -e "\n--- Creating SensorData Table for Day 2/3 ---"
$AWS_CMD create-table --cli-input-json file:///scripts/sensor_data_table.json

echo -e "\nDay 1 Completed."
