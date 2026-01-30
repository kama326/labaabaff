// День 1: CRUD и вложенность

// Задание 1: Вывести JSON-документ, содержащий { "hello": "world" }
printjson({ "hello": "world" });

// Создаем коллекцию towns 
db.towns.insert({
 name: "New York",
 population: 22200000,
 lastCensus: ISODate("2016-07-01"),
 famousFor: ["the MOMA", "food", "Derek Jeter"],
 mayor: {
 name: "Bill de Blasio",
 party: "D"
 }
});

db.towns.insert({
 name: "Punxsutawney",
 population: 6200,
 lastCensus: ISODate("2016-01-31"),
 famousFor: ["Punxsutawney Phil"],
 mayor: { name: "Richard Alexander" }
});

db.towns.insert({
 name: "Portland",
 population: 582000,
 lastCensus: ISODate("2016-09-20"),
 famousFor: ["beer", "food", "Portlandia"],
 mayor: { name: "Ted Wheeler", party: "D" }
});

// Задание 2: Выбрать город через регистронезависимое регулярное выражение, содержащее слово new.
print("--- Task 2: Cities matching /new/i ---");
var cursor = db.towns.find({ name: /new/i });
cursor.forEach(printjson);

// Задание 3: Найти все города, названия которых содержат букву 'e' и известны своей едой или пивом.
print("--- Task 3: Cities with 'e' and famous for food or beer ---");
cursor = db.towns.find({
    name: /e/,
    famousFor: { $in: ['food', 'beer'] }
});
cursor.forEach(printjson);

// Задание 4: Создать новую базу данных под названием blogger с коллекцией articles.
// В Mongo базы данных создаются лениво при вставке данных.
// Переключаемся на blogger: use blogger (в скрипте используем объект db.getSiblingDB)
var bloggerDb = db.getSiblingDB('blogger');

print("--- Task 4: Insert article into blogger database ---");
var article = {
    author: "John Doe",
    email: "john@example.com",
    date: new Date(),
    text: "This is my first blog post about MongoDB."
};
bloggerDb.articles.insert(article);
printjson(bloggerDb.articles.findOne());

// Задание 5: Обновить статью массивом комментариев.
print("--- Task 5: Update article with comments ---");
var comment = {
    author: "Jane Smith",
    text: "Great post!"
};

bloggerDb.articles.update(
    { author: "John Doe" },
    { $push: { comments: comment } }
);
printjson(bloggerDb.articles.findOne());

// Задание 6: Запустить запрос из внешнего файла JavaScript (этот файл и есть внешний скрипт).
print("--- Task 6: Script execution complete ---");
