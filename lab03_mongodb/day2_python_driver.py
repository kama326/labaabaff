from pymongo import MongoClient
import random

# Задание 2: Установить драйвер Mongo и подключиться к базе данных.
# Заполнить коллекцию через него и проиндексируйте одно из полей.

client = MongoClient('mongodb://nosql_lab_mongo:27017/')
db = client.test_database
collection = db.python_collection

# Очистка
collection.drop()

print("Inserting documents via Python...")
docs = []
for i in range(100):
    docs.append({
        "name": f"User_{i}",
        "age": random.randint(18, 90),
        "active": random.choice([True, False])
    })

collection.insert_many(docs)
print(f"Inserted {collection.count_documents({})} documents.")

# Индексация
print("Creating index on 'age'...")
collection.create_index("age")

# Проверка
print("Querying users > 50 years old...")
count = collection.count_documents({"age": {"$gt": 50}})
print(f"Found {count} users.")
