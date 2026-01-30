// День 3: Геопространственные запросы

// Переключаемся на базу test (где настроен шардинг и будет импорт)
db = db.getSiblingDB('test');

// Создаем геоиндекс (если бы данные были)
// db.cities.createIndex({ location: "2d" });

// Вставка тестовых данных для гео-запроса (Лондон и окрестности)
db.cities.insert({ name: "London", location: [51.5074, -0.1278] });
db.cities.insert({ name: "Watford", location: [51.6565, -0.3903] }); // ~15 miles
db.cities.insert({ name: "Brighton", location: [50.8225, -0.1372] }); // ~50 miles
db.cities.insert({ name: "Paris", location: [48.8566, 2.3522] }); // Far away

// Индекс
db.cities.createIndex({ location: "2d" });

// Задание 1: Найдите все города в радиусе 50 миль от центра Лондона.
// Координаты Лондона: 51.5074, -0.1278.
// 1 градус широты ~ 69 миль. 50 миль ~ 0.72 градуса (грубо, для плоского 2d индекса).
// Используем $geoWithin с $center

print("Cities within radius of London:");
var cursor = db.cities.find({
    location: {
        $geoWithin: {
            $center: [[51.5074, -0.1278], 0.72]
        }
    }
});
cursor.forEach(printjson);

print("Done Day 3 Tasks.");
