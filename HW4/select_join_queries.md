# HW4. Запросы SELECT и JOIN

## 1\. SELECT

### 1.1. Выборка всех данных из таблицы

**Запрос 1.** Вывести всю информацию о блюдах.

```sql
SELECT \\\*
FROM dishes;
```

**Запрос 2.** Вывести всю информацию о курьерах.

```sql
SELECT \\\*
FROM couriers;
```

### 1.2. Выборка отдельных столбцов

**Запрос 1.** Вывести названия и цены блюд.

```sql
SELECT name, price
FROM dishes;
```

**Запрос 2.** Вывести имена и адреса электронной почты пользователей.

```sql
SELECT name, email
FROM users;
```

### 1.3. Присвоение новых имен столбцам при формировании выборки

**Запрос 1.** Вывести названия ресторанов и их рейтинги, переименовав оба столбца.

```sql
SELECT name AS restaurant\\\_name,
rating AS restaurant\\\_rating
FROM restaurants;
```

**Запрос 2.** Вывести имена курьеров и тип их транспорта под новыми именами столбцов.

```sql
SELECT name AS courier\\\_name,
transport\\\_type AS delivery\\\_transport
FROM couriers;
```

### 1.4. Выборка данных с созданием вычисляемого столбца

**Запрос 1.** Вывести позиции заказов и посчитать стоимость каждой позиции (цена за единицу, умноженная на количество).

```sql
SELECT order\\\_id,
dish\\\_id,
quantity,
price,
quantity \\\* price AS item\\\_total
FROM order\\\_items;
```

**Запрос 2.** Рассчитать условную цену блюда со скидкой 10%.

```sql
SELECT name,
price,
price \\\* 0.90 AS discounted\\\_price
FROM dishes;
```

### 1.5. Выборка данных, вычисляемые столбцы, математические функции

**Запрос 1.** Вывести цену блюда со скидкой 15%, округлив результат до двух знаков после запятой с помощью ROUND, и округлить исходную цену вверх до целого с помощью CEIL.

```sql
SELECT name,
price,
ROUND(price \\\* 0.85, 2) AS discounted\\\_price,
CEIL(price) AS rounded\\\_up\\\_price
FROM dishes;
```

**Запрос 2.** Для каждого ресторана посчитать абсолютное отклонение рейтинга от 4.5 и квадрат рейтинга, округлённый до двух знаков.

```sql
SELECT name,
rating,
ABS(rating - 4.5) AS rating\\\_difference,
ROUND(POWER(rating, 2), 2) AS rating\\\_squared
FROM restaurants;
```

### 1.6. Выборка данных по условию

**Запрос 1.** Найти блюда дешевле 400 рублей.

```sql
SELECT name, price
FROM dishes
WHERE price < 400;
```

**Запрос 2.** Вывести рестораны с рейтингом выше 4.5.

```sql
SELECT name, rating
FROM restaurants
WHERE rating > 4.5;
```

### 1.7. Выборка данных, логические операции

**Запрос 1.** Найти свободных курьеров, которые доставляют заказы пешком или на велосипеде.

```sql
SELECT name, status, transport\\\_type
FROM couriers
WHERE status = 'свободен'
AND (transport\\\_type = 'пешком' OR transport\\\_type = 'велосипед');
```

**Запрос 2.** Найти заказы стоимостью более 500 рублей, которые ещё не доставлены.

```sql
SELECT id, status, total\\\_price
FROM orders
WHERE total\\\_price > 500
AND NOT (status = 'доставлен');
```

### 1.8. Выборка данных, операторы BETWEEN, IN

**BETWEEN, запрос 1.** Вывести блюда с ценой от 350 до 600 рублей включительно.

```sql
SELECT name, price
FROM dishes
WHERE price BETWEEN 350 AND 600;
```

**BETWEEN, запрос 2.** Вывести рестораны с рейтингом от 4.5 до 4.7 включительно.

```sql
SELECT name, rating
FROM restaurants
WHERE rating BETWEEN 4.5 AND 4.7;
```

**IN, запрос 1.** Вывести заказы со статусом «в пути» или «готовится».

```sql
SELECT id, status, order\\\_date
FROM orders
WHERE status IN ('в пути', 'готовится');
```

**IN, запрос 2.** Вывести курьеров, которые передвигаются пешком или на велосипеде.

```sql
SELECT name, transport\\\_type
FROM couriers
WHERE transport\\\_type IN ('пешком', 'велосипед');
```

### 1.9. Выборка данных с сортировкой

**Запрос 1.** Вывести блюда в порядке убывания цены; при одинаковой цене сортировать по названию.

```sql
SELECT name, price
FROM dishes
ORDER BY price DESC, name ASC;
```

**Запрос 2.** Вывести рестораны по убыванию рейтинга и по алфавиту внутри одинаковых рейтингов.

```sql
SELECT name, rating
FROM restaurants
ORDER BY rating DESC, name ASC;
```

### 1.10. Выборка данных, оператор LIKE

**Запрос 1.** Найти блюда, названия которых начинаются с буквы «П».

```sql
SELECT name, price
FROM dishes
WHERE name LIKE 'П%';
```

**Запрос 2.** Найти пользователей, в имени которых встречается последовательность «ов».

```sql
SELECT name, email
FROM users
WHERE name LIKE '%ов%';
```

### 1.11. Выбор уникальных элементов столбца

**Запрос 1.** Вывести все уникальные статусы заказов.

```sql
SELECT DISTINCT status
FROM orders;
```

**Запрос 2.** Вывести все уникальные виды транспорта курьеров.

```sql
SELECT DISTINCT transport\\\_type
FROM couriers;
```

### 1.12. Выбор ограниченного количества возвращаемых строк

**Запрос 1.** Показать два ресторана с самым высоким рейтингом.

```sql
SELECT name, rating
FROM restaurants
ORDER BY rating DESC, id ASC
LIMIT 2;
```

**Запрос 2.** Пропустить самое дорогое блюдо и вывести два следующих по цене.

```sql
SELECT name, price
FROM dishes
ORDER BY price DESC, id ASC
LIMIT 2 OFFSET 1;
```

### 1.13. Выборка данных, вычисляемые столбцы, логические функции (CASE)

**Запрос 1.** Разделить блюда на ценовые категории с помощью CASE.

```sql
SELECT name,
price,
CASE
WHEN price < 400 THEN 'Бюджетное'
WHEN price <= 500 THEN 'Средняя цена'
ELSE 'Дорогое'
END AS price\\\_category
FROM dishes
ORDER BY price;
```

**Запрос 2.** Показать понятное описание этапа обработки каждого заказа с помощью CASE.

```sql
SELECT id,
status,
CASE status
WHEN 'создан' THEN 'Ожидает обработки'
WHEN 'готовится' THEN 'Готовится в ресторане'
WHEN 'в пути' THEN 'Передан курьеру'
WHEN 'доставлен' THEN 'Выполнен'
ELSE 'Неизвестный статус'
END AS status\\\_description
FROM orders
ORDER BY id;
```

## 2\. JOIN

### 2.1. Соединение INNER JOIN

**Запрос 1.** Вывести имена пользователей, номера и стоимость их заказов.

```sql
SELECT u.name AS user\\\_name,
o.id AS order\\\_id,
o.total\\\_price
FROM users AS u
INNER JOIN orders AS o ON o.user\\\_id = u.id
ORDER BY o.id;
```

**Запрос 2.** Вывести названия блюд и ресторанов, в которых они продаются.

```sql
SELECT d.name AS dish\\\_name,
r.name AS restaurant\\\_name,
d.price
FROM dishes AS d
INNER JOIN restaurants AS r ON r.id = d.restaurant\\\_id
ORDER BY d.id;
```

### 2.2. Внешнее соединение LEFT JOIN (LEFT OUTER JOIN)

**Запрос 1.** Вывести всех пользователей и номера их доставленных заказов (если таких заказов нет — NULL).

```sql
SELECT u.name AS user\\\_name,
o.id AS delivered\\\_order\\\_id
FROM users AS u
LEFT JOIN orders AS o
ON o.user\\\_id = u.id AND o.status = 'доставлен'
ORDER BY u.id;
```

**Запрос 2.** Вывести все рестораны и их блюда дороже 500 рублей (если таких блюд нет — NULL).

```sql
SELECT r.name AS restaurant\\\_name,
d.name AS expensive\\\_dish
FROM restaurants AS r
LEFT JOIN dishes AS d
ON d.restaurant\\\_id = r.id AND d.price > 500
ORDER BY r.id;
```

### 2.3. Внешнее соединение RIGHT JOIN (RIGHT OUTER JOIN)

**Запрос 1.** Вывести всех курьеров и номера доставленных ими заказов (для курьеров без доставленных заказов — NULL).

```sql
SELECT c.name AS courier\\\_name,
o.id AS delivered\\\_order\\\_id
FROM orders AS o
RIGHT JOIN couriers AS c
ON o.courier\\\_id = c.id AND o.status = 'доставлен'
ORDER BY c.id;
```

**Запрос 2.** Вывести все рестораны и их блюда дешевле 400 рублей (при отсутствии таких блюд — NULL).

```sql
SELECT r.name AS restaurant\\\_name,
d.name AS cheap\\\_dish
FROM dishes AS d
RIGHT JOIN restaurants AS r
ON d.restaurant\\\_id = r.id AND d.price < 400
ORDER BY r.id;
```

### 2.4. Перекрёстное соединение CROSS JOIN

**Запрос 1.** Получить все возможные пары «ресторан — курьер».

```sql
SELECT r.name AS restaurant\\\_name,
c.name AS courier\\\_name
FROM restaurants AS r
CROSS JOIN couriers AS c
ORDER BY r.id, c.id;
```

**Запрос 2.** Получить все возможные пары «пользователь — блюдо».

```sql
SELECT u.name AS user\\\_name,
d.name AS dish\\\_name
FROM users AS u
CROSS JOIN dishes AS d
ORDER BY u.id, d.id;
```

### 2.5. Полное внешнее соединение FULL OUTER JOIN

**Запрос 1.** Показать всех пользователей и все заказы, сопоставляя только доставленные. Сохраняются и пользователи без доставленных заказов, и заказы других статусов.

```sql
SELECT u.name AS user\\\_name,
o.id AS order\\\_id,
o.status
FROM users AS u
FULL OUTER JOIN orders AS o
ON o.user\\\_id = u.id AND o.status = 'доставлен'
ORDER BY u.id NULLS LAST, o.id NULLS LAST;
```

**Запрос 2.** Показать все рестораны и все блюда, сопоставляя только блюда дороже 500 рублей. Несопоставленные строки с обеих сторон остаются в результате.

```sql
SELECT r.name AS restaurant\\\_name,
d.name AS dish\\\_name,
d.price
FROM restaurants AS r
FULL OUTER JOIN dishes AS d
ON d.restaurant\\\_id = r.id AND d.price > 500
ORDER BY r.id NULLS LAST, d.id NULLS LAST;
```

### 2.6. Запросы на выборку из нескольких таблиц

**Запрос 1.** Вывести для каждого заказа имя клиента, ресторан, назначенного курьера и статус заказа.

```sql
SELECT o.id AS order\\\_id,
u.name AS user\\\_name,
r.name AS restaurant\\\_name,
c.name AS courier\\\_name,
o.status
FROM orders AS o
INNER JOIN users AS u ON u.id = o.user\\\_id
INNER JOIN restaurants AS r ON r.id = o.restaurant\\\_id
LEFT JOIN couriers AS c ON c.id = o.courier\\\_id
ORDER BY o.id;
```

**Запрос 2.** Показать состав заказов: номер заказа, название ресторана, блюдо, количество и итоговую стоимость позиции.

```sql
SELECT o.id AS order\\\_id,
r.name AS restaurant\\\_name,
d.name AS dish\\\_name,
oi.quantity,
oi.quantity \\\* oi.price AS item\\\_total
FROM orders AS o
INNER JOIN restaurants AS r ON r.id = o.restaurant\\\_id
INNER JOIN order\\\_items AS oi ON oi.order\\\_id = o.id
INNER JOIN dishes AS d ON d.id = oi.dish\\\_id
ORDER BY o.id, d.name;
```

