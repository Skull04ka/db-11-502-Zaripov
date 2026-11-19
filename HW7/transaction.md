# HW7. Транзакции в PostgreSQL

## 1. Базовые операции с транзакциями

**Запрос 1.** Создать заказ и отметить назначенного курьера как занятого. Зафиксировать оба изменения.

Проверить статус курьера № 1 и наличие нового заказа.

```sql
SELECT c.status, COUNT(o.id) AS new_orders
FROM couriers c
LEFT JOIN orders o ON o.courier_id = c.id AND o.id = -702
WHERE c.id = 1
GROUP BY c.id;
```

Создать заказ № −702 и изменить статус курьера.

```sql
BEGIN;

INSERT INTO orders (id, user_id, restaurant_id, courier_id, status, total_price, delivery_address)
VALUES (-702, 1, 1, 1, 'в пути', 369.00, 'Казань, ул. Баумана, 10');

UPDATE couriers
SET status = 'занят'
WHERE id = 1;

SELECT c.status, COUNT(o.id) AS new_orders
FROM couriers c
LEFT JOIN orders o ON o.courier_id = c.id AND o.id = -702
WHERE c.id = 1
GROUP BY c.id;
```

Зафиксировать транзакцию и проверить обе таблицы.

```sql
COMMIT;

SELECT c.status, COUNT(o.id) AS new_orders
FROM couriers c
LEFT JOIN orders o ON o.courier_id = c.id AND o.id = -702
WHERE c.id = 1
GROUP BY c.id;
```

**Результат.** У курьера сохранился статус «занят», запрос нашёл один новый заказ.

Вернуть исходные данные для следующего примера.

```sql
BEGIN;

DELETE FROM orders WHERE id = -702;

UPDATE couriers
SET status = 'свободен'
WHERE id = 1;

COMMIT;
```

**Запрос 2.** Добавить в меню греческий салат и заменить им «Цезарь» в заказе № 4 по той же цене. Зафиксировать оба изменения.

Проверить, какое блюдо входит в заказ и есть ли новый салат в меню.

```sql
SELECT d.name AS dish_in_order,
       EXISTS (SELECT 1 FROM dishes WHERE id = -702) AS new_dish_in_menu
FROM order_items i
JOIN dishes d ON d.id = i.dish_id
WHERE i.order_id = 4
ORDER BY i.id;
```

Добавить блюдо в меню ресторана № 4 и обновить позицию заказа.

```sql
BEGIN;

INSERT INTO dishes (id, name, price, restaurant_id)
VALUES (-702, 'Греческий салат', 399.00, 4);

UPDATE order_items
SET dish_id = -702
WHERE order_id = 4 AND dish_id = 4;

SELECT d.name AS dish_in_order,
       EXISTS (SELECT 1 FROM dishes WHERE id = -702) AS new_dish_in_menu
FROM order_items i
JOIN dishes d ON d.id = i.dish_id
WHERE i.order_id = 4
ORDER BY i.id;
```

Зафиксировать транзакцию и проверить обе таблицы.

```sql
COMMIT;

SELECT d.name AS dish_in_order,
       EXISTS (SELECT 1 FROM dishes WHERE id = -702) AS new_dish_in_menu
FROM order_items i
JOIN dishes d ON d.id = i.dish_id
WHERE i.order_id = 4
ORDER BY i.id;
```

**Результат.** В меню появился греческий салат. В заказе № 4 теперь он же.

Вернуть исходные данные для следующего примера.

```sql
BEGIN;

UPDATE order_items
SET dish_id = 4
WHERE order_id = 4 AND dish_id = -702;

DELETE FROM dishes WHERE id = -702;

COMMIT;
```

**Запрос 3.** Создать заказ и отметить назначенного курьера как занятого. Отменить оба изменения.

Проверить статус курьера № 1 и наличие нового заказа.

```sql
SELECT c.status, COUNT(o.id) AS new_orders
FROM couriers c
LEFT JOIN orders o ON o.courier_id = c.id AND o.id = -702
WHERE c.id = 1
GROUP BY c.id;
```

Создать заказ № −702 и изменить статус курьера.

```sql
BEGIN;

INSERT INTO orders (id, user_id, restaurant_id, courier_id, status, total_price, delivery_address)
VALUES (-702, 1, 1, 1, 'в пути', 369.00, 'Казань, ул. Баумана, 10');

UPDATE couriers
SET status = 'занят'
WHERE id = 1;

SELECT c.status, COUNT(o.id) AS new_orders
FROM couriers c
LEFT JOIN orders o ON o.courier_id = c.id AND o.id = -702
WHERE c.id = 1
GROUP BY c.id;
```

Откатить транзакцию и проверить обе таблицы.

```sql
ROLLBACK;

SELECT c.status, COUNT(o.id) AS new_orders
FROM couriers c
LEFT JOIN orders o ON o.courier_id = c.id AND o.id = -702
WHERE c.id = 1
GROUP BY c.id;
```

**Результат.** Внутри транзакции запрос находил новый заказ и показывал статус «занят». После ROLLBACK заказ исчез, курьер снова свободен.

**Запрос 4.** Добавить в меню греческий салат и заменить им «Цезарь» в заказе № 4 по той же цене. Отменить оба изменения.

Проверить, какое блюдо входит в заказ и есть ли новый салат в меню.

```sql
SELECT d.name AS dish_in_order,
       EXISTS (SELECT 1 FROM dishes WHERE id = -702) AS new_dish_in_menu
FROM order_items i
JOIN dishes d ON d.id = i.dish_id
WHERE i.order_id = 4
ORDER BY i.id;
```

Добавить блюдо в меню ресторана № 4 и обновить позицию заказа.

```sql
BEGIN;

INSERT INTO dishes (id, name, price, restaurant_id)
VALUES (-702, 'Греческий салат', 399.00, 4);

UPDATE order_items
SET dish_id = -702
WHERE order_id = 4 AND dish_id = 4;

SELECT d.name AS dish_in_order,
       EXISTS (SELECT 1 FROM dishes WHERE id = -702) AS new_dish_in_menu
FROM order_items i
JOIN dishes d ON d.id = i.dish_id
WHERE i.order_id = 4
ORDER BY i.id;
```

Откатить транзакцию и проверить обе таблицы.

```sql
ROLLBACK;

SELECT d.name AS dish_in_order,
       EXISTS (SELECT 1 FROM dishes WHERE id = -702) AS new_dish_in_menu
FROM order_items i
JOIN dishes d ON d.id = i.dish_id
WHERE i.order_id = 4
ORDER BY i.id;
```

**Результат.** Внутри транзакции заказ содержал греческий салат. После ROLLBACK в заказе снова «Цезарь», греческого салата в меню нет.

**Запрос 5.** Создать заказ и отметить назначенного курьера как занятого. Проверить откат обоих изменений при ошибке.

Проверить статус курьера № 1 и наличие нового заказа.

```sql
SELECT c.status, COUNT(o.id) AS new_orders
FROM couriers c
LEFT JOIN orders o ON o.courier_id = c.id AND o.id = -702
WHERE c.id = 1
GROUP BY c.id;
```

Создать заказ № −702 и изменить статус курьера.

```sql
BEGIN;

INSERT INTO orders (id, user_id, restaurant_id, courier_id, status, total_price, delivery_address)
VALUES (-702, 1, 1, 1, 'в пути', 369.00, 'Казань, ул. Баумана, 10');

UPDATE couriers
SET status = 'занят'
WHERE id = 1;

SELECT c.status, COUNT(o.id) AS new_orders
FROM couriers c
LEFT JOIN orders o ON o.courier_id = c.id AND o.id = -702
WHERE c.id = 1
GROUP BY c.id;
```

Вызвать ошибку деления на ноль.

```sql
SELECT 1 / 0;
```

Откатить транзакцию и проверить обе таблицы.

```sql
ROLLBACK;

SELECT c.status, COUNT(o.id) AS new_orders
FROM couriers c
LEFT JOIN orders o ON o.courier_id = c.id AND o.id = -702
WHERE c.id = 1
GROUP BY c.id;
```

**Результат.** Деление на ноль прервало транзакцию (22012). После ROLLBACK заказ отсутствует, статус курьера — «свободен».

**Запрос 6.** Добавить в меню греческий салат и заменить им «Цезарь» в заказе № 4 по той же цене. Проверить откат обоих изменений при ошибке.

Проверить, какое блюдо входит в заказ и есть ли новый салат в меню.

```sql
SELECT d.name AS dish_in_order,
       EXISTS (SELECT 1 FROM dishes WHERE id = -702) AS new_dish_in_menu
FROM order_items i
JOIN dishes d ON d.id = i.dish_id
WHERE i.order_id = 4
ORDER BY i.id;
```

Добавить блюдо в меню ресторана № 4 и обновить позицию заказа.

```sql
BEGIN;

INSERT INTO dishes (id, name, price, restaurant_id)
VALUES (-702, 'Греческий салат', 399.00, 4);

UPDATE order_items
SET dish_id = -702
WHERE order_id = 4 AND dish_id = 4;

SELECT d.name AS dish_in_order,
       EXISTS (SELECT 1 FROM dishes WHERE id = -702) AS new_dish_in_menu
FROM order_items i
JOIN dishes d ON d.id = i.dish_id
WHERE i.order_id = 4
ORDER BY i.id;
```

Попробовать установить количество порций равным нулю.

```sql
UPDATE order_items
SET quantity = 0
WHERE order_id = 4 AND dish_id = -702;
```

Откатить транзакцию и проверить обе таблицы.

```sql
ROLLBACK;

SELECT d.name AS dish_in_order,
       EXISTS (SELECT 1 FROM dishes WHERE id = -702) AS new_dish_in_menu
FROM order_items i
JOIN dishes d ON d.id = i.dish_id
WHERE i.order_id = 4
ORDER BY i.id;
```

**Результат.** Ограничение chk_order_items_quantity отклонило количество 0 (23514). После ROLLBACK добавленное блюдо исчезло из меню, в заказе остался «Цезарь».

## 2. Уровни изоляции

T1 и T2 — два окна Query Tool, подключённые к одной базе. Блоки выполняются сверху вниз, каждый в указанном окне.

**Запрос 7.** Проверить, увидит ли второе соединение незафиксированную цену чизбургера при READ UNCOMMITTED.

**T1.** Изменить цену и оставить транзакцию открытой.

```sql
BEGIN;

UPDATE dishes
SET price = 389.00
WHERE id = 1;

SELECT price FROM dishes WHERE id = 1;
```

**T2.** Прочитать строку до завершения T1.

```sql
BEGIN ISOLATION LEVEL READ UNCOMMITTED;

SELECT price FROM dishes WHERE id = 1;
```

**T1.** Отменить изменение цены.

```sql
ROLLBACK;
```

**T2.** Прочитать строку ещё раз и завершить транзакцию.

```sql
SELECT price FROM dishes WHERE id = 1;

COMMIT;
```

**Результат.** T1 увидела цену 389 рублей. T2 прочитала 369 рублей как до отката T1, так и после него. Грязного чтения не произошло.

**Запрос 8.** Проверить, увидит ли второе соединение незафиксированный статус курьера при READ COMMITTED.

**T1.** Изменить статус и оставить транзакцию открытой.

```sql
BEGIN;

UPDATE couriers
SET status = 'занят'
WHERE id = 1;

SELECT status FROM couriers WHERE id = 1;
```

**T2.** Прочитать строку до завершения T1.

```sql
BEGIN ISOLATION LEVEL READ COMMITTED;

SELECT status FROM couriers WHERE id = 1;
```

**T1.** Зафиксировать новый статус.

```sql
COMMIT;
```

**T2.** Прочитать строку ещё раз и завершить транзакцию.

```sql
SELECT status FROM couriers WHERE id = 1;

COMMIT;
```

**Результат.** До фиксации T1 второе соединение видело «свободен», после фиксации — «занят». Незавершённое изменение ему не было видно.

Вернуть исходные данные для следующего примера.

```sql
BEGIN;

UPDATE couriers
SET status = 'свободен'
WHERE id = 1;

COMMIT;
```

**Запрос 9.** Показать неповторяющееся чтение цены чизбургера при READ COMMITTED.

**T1.** Прочитать текущую цену чизбургера.

```sql
BEGIN ISOLATION LEVEL READ COMMITTED;

SELECT price FROM dishes WHERE id = 1;
```

**T2.** Изменить цену и зафиксировать изменение.

```sql
BEGIN;

UPDATE dishes
SET price = 389.00
WHERE id = 1;

COMMIT;
```

**T1.** Повторить SELECT в той же транзакции.

```sql
SELECT price FROM dishes WHERE id = 1;

COMMIT;
```

**Результат.** Первый SELECT вернул 369 рублей, второй — 389 рублей. Два чтения одной строки внутри T1 дали разные значения.

Вернуть исходные данные для следующего примера.

```sql
BEGIN;

UPDATE dishes
SET price = 369.00
WHERE id = 1;

COMMIT;
```

**Запрос 10.** Показать неповторяющееся чтение статуса заказа № 4 при READ COMMITTED.

**T1.** Прочитать текущий статус заказа.

```sql
BEGIN ISOLATION LEVEL READ COMMITTED;

SELECT status FROM orders WHERE id = 4;
```

**T2.** Изменить статус заказа и зафиксировать изменение.

```sql
BEGIN;

UPDATE orders
SET status = 'готовится'
WHERE id = 4;

COMMIT;
```

**T1.** Повторить SELECT в той же транзакции.

```sql
SELECT status FROM orders WHERE id = 4;

COMMIT;
```

**Результат.** Первый SELECT вернул «создан», второй — «готовится». Два чтения одной строки внутри T1 дали разные значения.

Вернуть исходные данные для следующего примера.

```sql
BEGIN;

UPDATE orders
SET status = 'создан'
WHERE id = 4;

COMMIT;
```

**Запрос 11.** Проверить, когда становится видна новая цена чизбургера при REPEATABLE READ.

**T1.** Прочитать текущую цену чизбургера.

```sql
BEGIN ISOLATION LEVEL REPEATABLE READ;

SELECT price FROM dishes WHERE id = 1;
```

**T2.** Изменить цену и зафиксировать изменение.

```sql
BEGIN;

UPDATE dishes
SET price = 389.00
WHERE id = 1;

COMMIT;
```

**T1.** Повторить SELECT в той же транзакции.

```sql
SELECT price FROM dishes WHERE id = 1;

COMMIT;
```

**T1.** Прочитать цену после завершения транзакции.

```sql
SELECT price FROM dishes WHERE id = 1;
```

**Результат.** Оба чтения внутри T1 вернули 369 рублей. Только SELECT после завершения T1 показал цену 389 рублей.

Вернуть исходные данные для следующего примера.

```sql
BEGIN;

UPDATE dishes
SET price = 369.00
WHERE id = 1;

COMMIT;
```

**Запрос 12.** Добавить блюдо между двумя чтениями меню и сравнить результат при READ COMMITTED и REPEATABLE READ.

**T1.** Получить меню ресторана № 1 при READ COMMITTED.

```sql
BEGIN ISOLATION LEVEL READ COMMITTED;

SELECT name
FROM dishes
WHERE restaurant_id = 1
ORDER BY id;
```

**T2.** Добавить блюдо в тот же ресторан и зафиксировать вставку.

```sql
BEGIN;

INSERT INTO dishes (id, name, price, restaurant_id)
VALUES (-702, 'Луковые кольца', 129.00, 1);

COMMIT;
```

**T1.** Повторить выборку в открытой транзакции.

```sql
SELECT name
FROM dishes
WHERE restaurant_id = 1
ORDER BY id;

COMMIT;
```

**Результат.** Во второй выборке появились луковые кольца. Новая строка подошла под прежнее условие — это фантомное чтение.

Вернуть исходные данные для следующего примера.

```sql
BEGIN;

DELETE FROM dishes WHERE id = -702;

COMMIT;
```

**T1.** Получить меню ресторана № 1 при REPEATABLE READ.

```sql
BEGIN ISOLATION LEVEL REPEATABLE READ;

SELECT name
FROM dishes
WHERE restaurant_id = 1
ORDER BY id;
```

**T2.** Добавить блюдо в тот же ресторан и зафиксировать вставку.

```sql
BEGIN;

INSERT INTO dishes (id, name, price, restaurant_id)
VALUES (-702, 'Луковые кольца', 129.00, 1);

COMMIT;
```

**T1.** Повторить выборку в открытой транзакции.

```sql
SELECT name
FROM dishes
WHERE restaurant_id = 1
ORDER BY id;

COMMIT;
```

**T1.** Прочитать меню после завершения транзакции.

```sql
SELECT name
FROM dishes
WHERE restaurant_id = 1
ORDER BY id;
```

**Результат.** Внутри T1 меню оба раза содержало только чизбургер. Луковые кольца стали видны после завершения T1.

Вернуть исходные данные для следующего примера.

```sql
BEGIN;

DELETE FROM dishes WHERE id = -702;

COMMIT;
```

**Запрос 13.** Попытаться зарегистрировать одного клиента в двух транзакциях SERIALIZABLE и повторить регистрацию после конфликта.

**T1.** Проверить, занят ли email.

```sql
BEGIN ISOLATION LEVEL SERIALIZABLE;

SELECT COUNT(*) AS users_found
FROM users
WHERE email = 'hw7@example.test';
```

**T2.** Проверить, занят ли email.

```sql
BEGIN ISOLATION LEVEL SERIALIZABLE;

SELECT COUNT(*) AS users_found
FROM users
WHERE email = 'hw7@example.test';
```

**T1.** Зарегистрировать клиента и зафиксировать запись.

```sql
INSERT INTO users (name, email)
VALUES ('Клиент HW7', 'hw7@example.test')
ON CONFLICT (email) DO NOTHING
RETURNING email;

COMMIT;
```

**T2.** Попробовать выполнить тот же INSERT в открытой транзакции.

```sql
INSERT INTO users (name, email)
VALUES ('Клиент HW7', 'hw7@example.test')
ON CONFLICT (email) DO NOTHING
RETURNING email;
```

**T2.** После ошибки откатить транзакцию и повторить её с самого начала.

```sql
ROLLBACK;

BEGIN ISOLATION LEVEL SERIALIZABLE;

SELECT COUNT(*) AS users_found
FROM users
WHERE email = 'hw7@example.test';

INSERT INTO users (name, email)
VALUES ('Клиент HW7', 'hw7@example.test')
ON CONFLICT (email) DO NOTHING
RETURNING email;

COMMIT;

SELECT COUNT(*) AS users_found
FROM users
WHERE email = 'hw7@example.test';
```

**Результат.** Оба соединения увидели свободный email. При попытке вставки в T2 PostgreSQL сообщил `40001: could not serialize access due to concurrent update`. При повторе T2 увидела занятую почту, и ON CONFLICT DO NOTHING пропустил вставку. В таблице остался один клиент с этим email.

Вернуть исходные данные для следующего примера.

```sql
BEGIN;

DELETE FROM users WHERE email = 'hw7@example.test';

COMMIT;
```

**Запрос 14.** Повысить цену одного блюда из двух транзакций SERIALIZABLE и повторить обновление после конфликта.

**T1.** Прочитать исходную цену.

```sql
BEGIN ISOLATION LEVEL SERIALIZABLE;

SELECT price FROM dishes WHERE id = 1;
```

**T2.** Прочитать исходную цену.

```sql
BEGIN ISOLATION LEVEL SERIALIZABLE;

SELECT price FROM dishes WHERE id = 1;
```

**T1.** Прибавить 10 рублей и зафиксировать цену.

```sql
UPDATE dishes
SET price = price + 10.00
WHERE id = 1
RETURNING price;

COMMIT;
```

**T2.** Попробовать прибавить 10 рублей в открытой транзакции.

```sql
UPDATE dishes
SET price = price + 10.00
WHERE id = 1
RETURNING price;
```

**T2.** После ошибки откатить транзакцию и повторить её с самого начала.

```sql
ROLLBACK;

BEGIN ISOLATION LEVEL SERIALIZABLE;

SELECT price FROM dishes WHERE id = 1;

UPDATE dishes
SET price = price + 10.00
WHERE id = 1
RETURNING price;

COMMIT;

SELECT price FROM dishes WHERE id = 1;
```

**Результат.** При первом обновлении T2 получила ошибку 40001, поскольку T1 уже изменила эту строку. При повторе T2 прочитала цену 379 рублей и повысила её до 389. Оба повышения учтены.

Вернуть исходные данные для следующего примера.

```sql
BEGIN;

UPDATE dishes
SET price = 369.00
WHERE id = 1;

COMMIT;
```

## 3. Точки сохранения

**Запрос 15.** Начать приготовление заказа и отменить только последующую замену курьера.

Проверить исходный статус и номер курьера.

```sql
SELECT status, courier_id FROM orders WHERE id = 4;
```

Изменить статус заказа № 4, создать точку сохранения и назначить курьера № 1.

```sql
BEGIN;

UPDATE orders
SET status = 'готовится'
WHERE id = 4;

SAVEPOINT before_courier;

UPDATE orders
SET courier_id = 1
WHERE id = 4;

SELECT status, courier_id FROM orders WHERE id = 4;
```

Вернуться к точке перед заменой курьера, зафиксировать транзакцию и проверить заказ.

```sql
ROLLBACK TO SAVEPOINT before_courier;

COMMIT;

SELECT status, courier_id FROM orders WHERE id = 4;
```

**Результат.** У заказа сохранился статус «готовится». После отката к точке сохранения за ним снова закреплён прежний курьер № 3.

Вернуть исходные данные для следующего примера.

```sql
BEGIN;

UPDATE orders
SET status = 'создан'
WHERE id = 4;

COMMIT;
```

**Запрос 16.** Трижды повысить цену чизбургера и проверить возврат к каждой из двух точек сохранения.

Повысить цену с 369 до 379 рублей и создать первую точку сохранения.

```sql
BEGIN;

UPDATE dishes
SET price = price + 10.00
WHERE id = 1
RETURNING price;

SAVEPOINT first_price;
```

Повысить цену до 389 рублей, создать вторую точку и повысить цену ещё раз.

```sql
UPDATE dishes
SET price = price + 10.00
WHERE id = 1
RETURNING price;

SAVEPOINT second_price;

UPDATE dishes
SET price = price + 10.00
WHERE id = 1
RETURNING price;
```

Вернуться ко второй точке и проверить цену.

```sql
ROLLBACK TO SAVEPOINT second_price;

SELECT price FROM dishes WHERE id = 1;
```

Вернуться к первой точке, зафиксировать транзакцию и проверить итоговую цену.

```sql
ROLLBACK TO SAVEPOINT first_price;

COMMIT;

SELECT price FROM dishes WHERE id = 1;
```

**Результат.** Со второй точки восстановилась цена 389 рублей, с первой — 379 рублей. После COMMIT в таблице осталось 379 рублей.

Вернуть исходные данные для следующего примера.

```sql
BEGIN;

UPDATE dishes
SET price = 369.00
WHERE id = 1;

COMMIT;
```

## 4. Выводы

COMMIT сохранил оба связанных изменения. ROLLBACK отменил их целиком, в том числе после ошибки. ROLLBACK TO SAVEPOINT отменил только изменения после выбранной точки, поэтому удалось сохранить новый статус заказа и вернуть прежнего курьера.

В PostgreSQL READ UNCOMMITTED работает как READ COMMITTED. Оба уровня скрывают чужие незафиксированные изменения. При READ COMMITTED каждый SELECT получает новый снимок данных, поэтому повторное чтение может показать новую цену или дополнительное блюдо. При REPEATABLE READ оба SELECT внутри одной транзакции видели один и тот же снимок.

На уровне SERIALIZABLE обе транзакции в каждой паре начали со старого состояния. После фиксации первой PostgreSQL прервал вторую при конфликте. Полный повтор позволил принять решение по актуальным данным.
