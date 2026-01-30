// День 2: Индексирование, Агрегация, MapReduce

// Функция для заполнения телефонов (из методички)
populatePhones = function (area, start, stop) {
    for (var i = start; i < stop; i++) {
        var country = 1 + ((Math.random() * 8) << 0);
        var num = (country * 1e10) + (area * 1e7) + i;
        var fullNumber = "+" + country + " " + area + "-" + i;
        db.phones.insert({
            _id: num,
            components: {
                country: country,
                area: area,
                prefix: (i * 1e-4) << 0,
                number: i
            },
            display: fullNumber
        });
        // print("Inserted number " + fullNumber); // Закомментировано для скорости
    }
    print("Done! Populated phones from " + start + " to " + stop);
}

// Задание: Заполнить коллекцию (небольшой диапазон для теста)
print("Populating phones collection...");
populatePhones(800, 5550000, 5550100); // 100 записей для теста

// Индексирование
print("Creating index on display...");
db.phones.ensureIndex({ display: 1 }, { unique: true, dropDups: true });

// Проверка explain
print("Explain query with index:");
printjson(db.phones.find({ display: "+1 800-5550001" }).explain("executionStats").executionStats);

// Агрегация (пример из методички)
// Подсчет количества телефонов > 5599999 (в нашем диапазоне их нет, но проверим)
print("Count phones > 5550050:");
print(db.phones.count({ 'components.number': { $gt: 5550050 } }));

// Задание 1: Реализовать метод finalize (для MapReduce), который выводит количество как общее значение.
// Пример MapReduce из методички (distinctDigits)
var map = function () {
    var digits = (this.components.number + '').split('');
    // упрощенная логика для теста - просто считаем цифры
    emit({ digits: digits.length, country: this.components.country }, { count: 1 });
}

var reduce = function (key, values) {
    var total = 0;
    for (var i = 0; i < values.length; i++) {
        total += values[i].count;
    }
    return { count: total };
}

var finalize = function (key, reducedValue) {
    return { total: reducedValue.count };
}

print("Running MapReduce...");
var results = db.runCommand({
    mapReduce: 'phones',
    map: map,
    reduce: reduce,
    finalize: finalize,
    out: 'phones.report'
});
printjson(results);

print("Check report:");
printjson(db.phones.report.findOne());
