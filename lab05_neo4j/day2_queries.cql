// Загрузка данных (если бы мы загружали movie-graph, но мы создадим мини-граф для теста здесь)
// Создаем данные для "6 рукопожатий" (миниверсия)

CREATE (kb:Actor {name: "Kevin Bacon"}),
       (a1:Actor {name: "Actor One"}),
       (a2:Actor {name: "Actor Two"}),
       (m1:Movie {title: "Movie One"}),
       (m2:Movie {title: "Movie Two"});

CREATE (kb)-[:ACTED_IN]->(m1),
       (a1)-[:ACTED_IN]->(m1),
       (a1)-[:ACTED_IN]->(m2),
       (a2)-[:ACTED_IN]->(m2);

// Найти кратчайший путь от Actor Two до Kevin Bacon
MATCH (start:Actor {name: "Actor Two"}), (end:Actor {name: "Kevin Bacon"})
MATCH p = shortestPath((start)-[*..15]-(end))
RETURN p, length(p);
