-- HW4. Запросы SELECT и JOIN

-- 1. SELECT

-- 1.1. Выборка всех данных из таблицы

-- Запрос 1. Вывести всю информацию о блюдах.

SELECT *
FROM dishes;

-- Запрос 2. Вывести всю информацию о курьерах.

SELECT *
FROM couriers;

-- 1.2. Выборка отдельных столбцов

-- Запрос 1. Вывести названия и цены блюд.

SELECT name, price
FROM dishes;

-- Запрос 2. Вывести имена и адреса электронной почты пользователей.

SELECT name, email
FROM users;

-- 1.3. Присвоение новых имен столбцам при формировании выборки

-- Запрос 1. Вывести названия ресторанов и их рейтинги, переименовав оба столбца.

SELECT name AS restaurant_name,
       rating AS restaurant_rating
FROM restaurants;

-- Запрос 2. Вывести имена курьеров и тип их транспорта под новыми именами столбцов.

SELECT name AS courier_name,
       transport_type AS delivery_transport
FROM couriers;

-- 1.4. Выборка данных с созданием вычисляемого столбца

-- Запрос 1. Вывести позиции заказов и посчитать стоимость каждой позиции (цена за единицу, умноженная на количество).

SELECT order_id,
       dish_id,
       quantity,
       price,
       quantity * price AS item_total
FROM order_items;

-- Запрос 2. Рассчитать условную цену блюда со скидкой 10%.

SELECT name,
       price,
       price * 0.90 AS discounted_price
FROM dishes;

-- 1.5. Выборка данных, вычисляемые столбцы, математические функции

-- Запрос 1. Вывести цену блюда со скидкой 15%, округлив результат до двух знаков после запятой с помощью ROUND, и округлить исходную цену вверх до целого с помощью CEIL.

SELECT name,
       price,
       ROUND(price * 0.85, 2) AS discounted_price,
       CEIL(price) AS rounded_up_price
FROM dishes;

-- Запрос 2. Для каждого ресторана посчитать абсолютное отклонение рейтинга от 4.5 и квадрат рейтинга, округлённый до двух знаков.

SELECT name,
       rating,
       ABS(rating - 4.5) AS rating_difference,
       ROUND(POWER(rating, 2), 2) AS rating_squared
FROM restaurants;

-- 1.6. Выборка данных по условию

-- Запрос 1. Найти блюда дешевле 400 рублей.

SELECT name, price
FROM dishes
WHERE price < 400;

-- Запрос 2. Вывести рестораны с рейтингом выше 4.5.

SELECT name, rating
FROM restaurants
WHERE rating > 4.5;

-- 1.7. Выборка данных, логические операции

-- Запрос 1. Найти свободных курьеров, которые доставляют заказы пешком или на велосипеде.

SELECT name, status, transport_type
FROM couriers
WHERE status = 'свободен'
  AND (transport_type = 'пешком' OR transport_type = 'велосипед');

-- Запрос 2. Найти заказы стоимостью более 500 рублей, которые ещё не доставлены.

SELECT id, status, total_price
FROM orders
WHERE total_price > 500
  AND NOT (status = 'доставлен');

-- 1.8. Выборка данных, операторы BETWEEN, IN

-- BETWEEN — запрос 1. Вывести блюда с ценой от 350 до 600 рублей включительно.

SELECT name, price
FROM dishes
WHERE price BETWEEN 350 AND 600;

-- BETWEEN — запрос 2. Вывести рестораны с рейтингом от 4.5 до 4.7 включительно.

SELECT name, rating
FROM restaurants
WHERE rating BETWEEN 4.5 AND 4.7;

-- IN — запрос 1. Вывести заказы со статусом «в пути» или «готовится».

SELECT id, status, order_date
FROM orders
WHERE status IN ('в пути', 'готовится');

-- IN — запрос 2. Вывести курьеров, которые передвигаются пешком или на велосипеде.

SELECT name, transport_type
FROM couriers
WHERE transport_type IN ('пешком', 'велосипед');

-- 1.9. Выборка данных с сортировкой

-- Запрос 1. Вывести блюда в порядке убывания цены; при одинаковой цене сортировать по названию.

SELECT name, price
FROM dishes
ORDER BY price DESC, name ASC;

-- Запрос 2. Вывести рестораны по убыванию рейтинга и по алфавиту внутри одинаковых рейтингов.

SELECT name, rating
FROM restaurants
ORDER BY rating DESC, name ASC;

-- 1.10. Выборка данных, оператор LIKE

-- Запрос 1. Найти блюда, названия которых начинаются с буквы «П».

SELECT name, price
FROM dishes
WHERE name LIKE 'П%';

-- Запрос 2. Найти пользователей, в имени которых встречается последовательность «ов».

SELECT name, email
FROM users
WHERE name LIKE '%ов%';

-- 1.11. Выбор уникальных элементов столбца

-- Запрос 1. Вывести все уникальные статусы заказов.

SELECT DISTINCT status
FROM orders;

-- Запрос 2. Вывести все уникальные виды транспорта курьеров.

SELECT DISTINCT transport_type
FROM couriers;

-- 1.12. Выбор ограниченного количества возвращаемых строк

-- Запрос 1. Показать два ресторана с самым высоким рейтингом.

SELECT name, rating
FROM restaurants
ORDER BY rating DESC, id ASC
LIMIT 2;

-- Запрос 2. Пропустить самое дорогое блюдо и вывести два следующих по цене.

SELECT name, price
FROM dishes
ORDER BY price DESC, id ASC
LIMIT 2 OFFSET 1;

-- 1.13. Выборка данных, вычисляемые столбцы, логические функции (CASE)

-- Запрос 1. Разделить блюда на ценовые категории с помощью CASE.

SELECT name,
       price,
       CASE
           WHEN price < 400 THEN 'Бюджетное'
           WHEN price <= 500 THEN 'Средняя цена'
           ELSE 'Дорогое'
       END AS price_category
FROM dishes
ORDER BY price;

-- Запрос 2. Показать понятное описание этапа обработки каждого заказа с помощью CASE.

SELECT id,
       status,
       CASE status
           WHEN 'создан' THEN 'Ожидает обработки'
           WHEN 'готовится' THEN 'Готовится в ресторане'
           WHEN 'в пути' THEN 'Передан курьеру'
           WHEN 'доставлен' THEN 'Выполнен'
           ELSE 'Неизвестный статус'
       END AS status_description
FROM orders
ORDER BY id;

-- 2. JOIN

-- 2.1. Соединение INNER JOIN

-- Запрос 1. Вывести имена пользователей, номера и стоимость их заказов.

SELECT u.name AS user_name,
       o.id AS order_id,
       o.total_price
FROM users AS u
INNER JOIN orders AS o ON o.user_id = u.id
ORDER BY o.id;

-- Запрос 2. Вывести названия блюд и ресторанов, в которых они продаются.

SELECT d.name AS dish_name,
       r.name AS restaurant_name,
       d.price
FROM dishes AS d
INNER JOIN restaurants AS r ON r.id = d.restaurant_id
ORDER BY d.id;

-- 2.2. Внешнее соединение LEFT JOIN (LEFT OUTER JOIN)

-- Запрос 1. Вывести всех пользователей и номера их доставленных заказов (если таких заказов нет — NULL).

SELECT u.name AS user_name,
       o.id AS delivered_order_id
FROM users AS u
LEFT JOIN orders AS o
    ON o.user_id = u.id AND o.status = 'доставлен'
ORDER BY u.id;

-- Запрос 2. Вывести все рестораны и их блюда дороже 500 рублей (если таких блюд нет — NULL).

SELECT r.name AS restaurant_name,
       d.name AS expensive_dish
FROM restaurants AS r
LEFT JOIN dishes AS d
    ON d.restaurant_id = r.id AND d.price > 500
ORDER BY r.id;

-- 2.3. Внешнее соединение RIGHT JOIN (RIGHT OUTER JOIN)

-- Запрос 1. Вывести всех курьеров и номера доставленных ими заказов (для курьеров без доставленных заказов — NULL).

SELECT c.name AS courier_name,
       o.id AS delivered_order_id
FROM orders AS o
RIGHT JOIN couriers AS c
    ON o.courier_id = c.id AND o.status = 'доставлен'
ORDER BY c.id;

-- Запрос 2. Вывести все рестораны и их блюда дешевле 400 рублей (при отсутствии таких блюд — NULL).

SELECT r.name AS restaurant_name,
       d.name AS cheap_dish
FROM dishes AS d
RIGHT JOIN restaurants AS r
    ON d.restaurant_id = r.id AND d.price < 400
ORDER BY r.id;

-- 2.4. Перекрёстное соединение CROSS JOIN

-- Запрос 1. Получить все возможные пары «ресторан — курьер»

SELECT r.name AS restaurant_name,
       c.name AS courier_name
FROM restaurants AS r
CROSS JOIN couriers AS c
ORDER BY r.id, c.id;

-- Запрос 2. Получить все возможные пары «пользователь — блюдо»

SELECT u.name AS user_name,
       d.name AS dish_name
FROM users AS u
CROSS JOIN dishes AS d
ORDER BY u.id, d.id;

-- 2.5. Полное внешнее соединение FULL OUTER JOIN

-- Запрос 1. Показать всех пользователей и все заказы, сопоставляя только доставленные. Сохраняются и пользователи без доставленных заказов, и заказы других статусов.

SELECT u.name AS user_name,
       o.id AS order_id,
       o.status
FROM users AS u
FULL OUTER JOIN orders AS o
    ON o.user_id = u.id AND o.status = 'доставлен'
ORDER BY u.id NULLS LAST, o.id NULLS LAST;

-- Запрос 2. Показать все рестораны и все блюда, сопоставляя только блюда дороже 500 рублей. Несопоставленные строки с обеих сторон остаются в результате.

SELECT r.name AS restaurant_name,
       d.name AS dish_name,
       d.price
FROM restaurants AS r
FULL OUTER JOIN dishes AS d
    ON d.restaurant_id = r.id AND d.price > 500
ORDER BY r.id NULLS LAST, d.id NULLS LAST;


-- 2.6. Запросы на выборку из нескольких таблиц

-- Запрос 1. Вывести для каждого заказа имя клиента, ресторан, назначенного курьера и статус заказа.

SELECT o.id AS order_id,
       u.name AS user_name,
       r.name AS restaurant_name,
       c.name AS courier_name,
       o.status
FROM orders AS o
INNER JOIN users AS u ON u.id = o.user_id
INNER JOIN restaurants AS r ON r.id = o.restaurant_id
LEFT JOIN couriers AS c ON c.id = o.courier_id
ORDER BY o.id;

-- Запрос 2. Показать состав заказов: номер заказа, название ресторана, блюдо, количество и итоговую стоимость позиции.

SELECT o.id AS order_id,
       r.name AS restaurant_name,
       d.name AS dish_name,
       oi.quantity,
       oi.quantity * oi.price AS item_total
FROM orders AS o
INNER JOIN restaurants AS r ON r.id = o.restaurant_id
INNER JOIN order_items AS oi ON oi.order_id = o.id
INNER JOIN dishes AS d ON d.id = oi.dish_id
ORDER BY o.id, d.name;
