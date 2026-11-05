# HW6. Подзапросы

## 1. Подзапросы в SELECT

**Запрос 1.** Вывести названия и цены блюд, а также среднюю цену всех блюд.

```sql
SELECT d.name,
       d.price,
       (SELECT AVG(price) FROM dishes) AS average_price
FROM dishes d;
```

**Запрос 2.** Вывести номера и стоимость заказов вместе с общей суммой всех заказов.

```sql
SELECT o.id,
       o.total_price,
       (SELECT SUM(total_price) FROM orders) AS total_revenue
FROM orders o;
```

## 2. Подзапросы в FROM

**Запрос 1.** Вывести рестораны, средняя цена блюд в которых больше 400 рублей.

```sql
SELECT r.name,
       sub.average_price
FROM restaurants r
JOIN (
    SELECT restaurant_id,
           AVG(price) AS average_price
    FROM dishes
    GROUP BY restaurant_id
) sub ON sub.restaurant_id = r.id
WHERE sub.average_price > 400;
```

**Запрос 2.** Вывести курьеров, общая стоимость назначенных им заказов которых превышает 500 рублей.

```sql
SELECT c.name,
       sub.orders_count,
       sub.orders_total
FROM couriers c
JOIN (
    SELECT courier_id,
           COUNT(*) AS orders_count,
           SUM(total_price) AS orders_total
    FROM orders
    GROUP BY courier_id
) sub ON sub.courier_id = c.id
WHERE sub.orders_total > 500;
```

## 3. Подзапросы в WHERE

**Запрос 1.** Найти самые дорогие блюда.

```sql
SELECT name, price
FROM dishes
WHERE price = (SELECT MAX(price) FROM dishes);
```

**Запрос 2.** Вывести заказы, стоимость которых выше средней стоимости всех заказов.

```sql
SELECT id, total_price
FROM orders
WHERE total_price > (SELECT AVG(total_price) FROM orders);
```

## 4. Подзапросы в HAVING

**Запрос 1.** Вывести рестораны, средняя цена блюд в которых выше средней цены всех блюд.

```sql
SELECT r.name,
       AVG(d.price) AS average_price
FROM restaurants r
JOIN dishes d ON d.restaurant_id = r.id
GROUP BY r.id, r.name
HAVING AVG(d.price) > (SELECT AVG(price) FROM dishes);
```

**Запрос 2.** Найти заказы, суммарное количество блюд в которых больше среднего количества блюд в одной позиции заказа.

```sql
SELECT order_id,
       SUM(quantity) AS total_quantity
FROM order_items
GROUP BY order_id
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM order_items);
```

## 5. Подзапросы с ALL

**Запрос 1.** Найти блюда, которые дороже всех блюд ресторана Burger House.

```sql
SELECT name, price
FROM dishes
WHERE price > ALL (
    SELECT d.price
    FROM dishes d
    JOIN restaurants r ON r.id = d.restaurant_id
    WHERE r.name = 'Burger House'
);
```

**Запрос 2.** Вывести заказы, стоимость которых выше стоимости каждого доставленного заказа.

```sql
SELECT id, total_price
FROM orders
WHERE total_price > ALL (
    SELECT total_price
    FROM orders
    WHERE status = 'доставлен'
);
```

## 6. Подзапросы с IN

**Запрос 1.** Найти рестораны, в которых есть блюда дороже 450 рублей.

```sql
SELECT name
FROM restaurants
WHERE id IN (
    SELECT restaurant_id
    FROM dishes
    WHERE price > 450
);
```

**Запрос 2.** Вывести пользователей, которые заказывали хотя бы два экземпляра одного блюда в одной позиции заказа.

```sql
SELECT name
FROM users
WHERE id IN (
    SELECT o.user_id
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.id
    WHERE oi.quantity >= 2
);
```

## 7. Подзапросы с ANY

**Запрос 1.** Найти блюда, которые дороже хотя бы одного блюда ресторана Green Bowl.

```sql
SELECT name, price
FROM dishes
WHERE price > ANY (
    SELECT d.price
    FROM dishes d
    JOIN restaurants r ON r.id = d.restaurant_id
    WHERE r.name = 'Green Bowl'
);
```

**Запрос 2.** Вывести заказы, стоимость которых ниже стоимости хотя бы одного доставленного заказа.

```sql
SELECT id, total_price
FROM orders
WHERE total_price < ANY (
    SELECT total_price
    FROM orders
    WHERE status = 'доставлен'
);
```

## 8. Подзапросы с EXISTS и NOT EXISTS

**Запрос 1.** Найти рестораны, в которых есть хотя бы одно блюдо стоимостью от 500 рублей.

```sql
SELECT r.name
FROM restaurants r
WHERE EXISTS (
    SELECT 1
    FROM dishes d
    WHERE d.restaurant_id = r.id
      AND d.price >= 500
);
```

**Запрос 2.** Вывести пользователей, которые ни разу не делали заказ дороже 800 рублей.

```sql
SELECT u.name
FROM users u
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.user_id = u.id
      AND o.total_price > 800
);
```

## 9. Сравнение по нескольким столбцам

**Запрос 1.** Найти заказы, в которых хотя бы одно заказанное блюдо принадлежит ресторану, указанному в заказе.

```sql
SELECT o.id, o.restaurant_id
FROM orders o
WHERE (o.id, o.restaurant_id) IN (
    SELECT oi.order_id, d.restaurant_id
    FROM order_items oi
    JOIN dishes d ON d.id = oi.dish_id
);
```

**Запрос 2.** Вывести блюда, которые хотя бы раз заказывали по их текущей цене.

```sql
SELECT d.name, d.price
FROM dishes d
WHERE (d.id, d.price) IN (
    SELECT dish_id, price
    FROM order_items
);
```

## 10. Коррелированные подзапросы

**Запрос 1.** Для каждого пользователя вывести количество его заказов.

```sql
SELECT u.name,
       (SELECT COUNT(*)
        FROM orders o
        WHERE o.user_id = u.id) AS orders_count
FROM users u;
```

**Запрос 2.** Для каждого ресторана вывести среднюю цену его блюд.

```sql
SELECT r.name,
       (SELECT AVG(d.price)
        FROM dishes d
        WHERE d.restaurant_id = r.id) AS average_dish_price
FROM restaurants r;
```

**Запрос 3.** Вывести блюда, которых суммарно заказали не меньше двух штук.

```sql
SELECT d.name
FROM dishes d
WHERE (
    SELECT SUM(oi.quantity)
    FROM order_items oi
    WHERE oi.dish_id = d.id
) >= 2;
```

**Запрос 4.** Для каждого заказа вывести его стоимость и сумму стоимости всех его позиций.

```sql
SELECT o.id,
       o.total_price,
       (SELECT SUM(oi.quantity * oi.price)
        FROM order_items oi
        WHERE oi.order_id = o.id) AS items_total
FROM orders o;
```

**Запрос 5.** Найти курьеров, которым ни разу не назначали доставленный заказ.

```sql
SELECT c.name
FROM couriers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.courier_id = c.id
      AND o.status = 'доставлен'
);
```
