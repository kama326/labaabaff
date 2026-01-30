// День 1: Графы и Cypher

// Создание узла Вино
CREATE (w:Wine {name:"Prancing Wolf", style: "ice wine", vintage: 2015});

// Создание узла Публикация
CREATE (p:Publication {name: "Wine Expert Monthly"});

// Создание отношения (Публикация сообщает о Вине)
MATCH (p:Publication {name: "Wine Expert Monthly"}),
      (w:Wine {name: "Prancing Wolf"})
CREATE (p)-[r:reported_on]->(w)
RETURN p, w, r;

// Добавление свойства к отношению
MATCH ()-[r:reported_on]-()
SET r.rating = 97;

// Создание узла Тип Винограда и связь
CREATE (g:GrapeType {name: "Riesling"});

MATCH (w:Wine {name: "Prancing Wolf"}), (g:GrapeType {name: "Riesling"})
CREATE (w)-[r:grape_type]->(g);

// Социальная сеть: Люди и их предпочтения
CREATE (alice:Person {name: "Alice"}),
       (tom:Person {name: "Tom"}),
       (patty:Person {name: "Patty"});

// Элис любит айсвайн
MATCH (p:Person {name: "Alice"}), (w:Wine {style: "ice wine"})
CREATE (p)-[:likes]->(w);

// Том доверяет Публикации
MATCH (p:Person {name: "Tom"}), (pub:Publication {name: "Wine Expert Monthly"})
CREATE (p)-[:trusts]->(pub);

// Патти дружит с Томом и Элис
MATCH (p1:Person {name: "Patty"}), (p2:Person {name: "Tom"})
CREATE (p1)-[:friends]->(p2);

MATCH (p1:Person {name: "Patty"}), (p2:Person {name: "Alice"})
CREATE (p1)-[:friends]->(p2);

// Запросы (SELECT)
// Кто с кем дружит (друзья Элис)
MATCH (p:Person {name: "Alice"})--(others)
RETURN p.name, labels(others), others.name;

// Друзья друзей Патти
MATCH (patty:Person {name: "Patty"})-[:friends]-(friend)-[:friends]-(fof)
WHERE fof.name <> "Patty"
RETURN fof.name AS FriendOfFriend;

// Очистка (для идемпотентности, если нужно начать заново, можно раскомментировать)
// MATCH (n) DETACH DELETE n;
