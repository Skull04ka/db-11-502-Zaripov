# HW6. CTE, UNION и оконные функции

## 1. CTE

**Запрос 1.** Вывести рестораны, средняя цена блюд в которых выше 400 рублей.

```sql
WITH restaurant_prices AS (
    SELECT restaurant_id,
           AVG(price) AS average_price
    FROM dishes
    GROUP BY restaurant_id
)
SELECT r.name,
       ROUND(rp.average_price, 2) AS average_price
FROM restaurants r
JOIN restaurant_prices rp ON rp.restaurant_id = r.id
WHERE rp.average_price > 400
ORDER BY r.name;
```

**Запрос 2.** Вывести пользователей, которые сделали не меньше двух заказов, и общую стоимость их заказов.

```sql
WITH user_orders AS (
    SELECT user_id,
           COUNT(*) AS orders_count,
           SUM(total_price) AS spent
    FROM orders
    GROUP BY user_id
),
active_users AS (
    SELECT *
    FROM user_orders
    WHERE orders_count >= 2
)
SELECT u.name,
       a.orders_count,
       a.spent
FROM active_users a
JOIN users u ON u.id = a.user_id
ORDER BY u.id;
```

**Запрос 3.** С помощью рекурсивного CTE последовательно получить номера заказов и их стоимость.

```sql
WITH RECURSIVE order_numbers(id) AS (
    SELECT MIN(id)
    FROM orders

    UNION ALL

    SELECT id + 1
    FROM order_numbers
    WHERE id < (SELECT MAX(id) FROM orders)
)
SELECT n.id,
       o.total_price
FROM order_numbers n
JOIN orders o ON o.id = n.id
ORDER BY n.id;
```

## 2. UNION, INTERSECT, EXCEPT

**Запрос 1.** Объединить имена пользователей и курьеров без повторений (UNION).

```sql
SELECT name AS person_name
FROM users
UNION
SELECT name
FROM couriers
ORDER BY person_name;
```

**Запрос 2.** Найти пользователей, которые делали заказ дороже или равный 600 рублей и имеют хотя бы один доставленный заказ (INTERSECT).

```sql
SELECT user_id
FROM orders
WHERE total_price >= 600
INTERSECT
SELECT user_id
FROM orders
WHERE status = 'доставлен'
ORDER BY user_id;
```

**Запрос 3.** Найти пользователей, у которых есть заказы, но ни один из них не доставлен (EXCEPT).

```sql
SELECT user_id
FROM orders
EXCEPT
SELECT user_id
FROM orders
WHERE status = 'доставлен'
ORDER BY user_id;
```

## 3. PARTITION BY

**Запрос 1.** Показать каждый заказ и общее количество заказов его пользователя.

```sql
SELECT id,
       user_id,
       total_price,
       COUNT(*) OVER (PARTITION BY user_id) AS user_orders_count
FROM orders
ORDER BY user_id, id;
```

**Запрос 2.** Показать каждый заказ и среднюю стоимость заказа в его ресторане.

```sql
SELECT id,
       restaurant_id,
       total_price,
       ROUND(AVG(total_price) OVER (PARTITION BY restaurant_id), 2) AS average_order_price
FROM orders
ORDER BY restaurant_id, id;
```

## 4. PARTITION BY + ORDER BY

**Запрос 1.** Получить накопительную сумму расходов каждого пользователя по времени.

```sql
SELECT id,
       user_id,
       order_date,
       total_price,
       SUM(total_price) OVER (
           PARTITION BY user_id
           ORDER BY order_date, id
       ) AS running_spent
FROM orders
ORDER BY user_id, order_date, id;
```

**Запрос 2.** Посчитать нарастающее число заказов для каждого ресторана.

```sql
SELECT id,
       restaurant_id,
       order_date,
       COUNT(*) OVER (
           PARTITION BY restaurant_id
           ORDER BY order_date, id
       ) AS running_orders_count
FROM orders
ORDER BY restaurant_id, order_date, id;
```

## 5. ROWS

**Запрос 1.** Вычислить среднюю стоимость текущего и предыдущего заказа пользователя.

```sql
SELECT id,
       user_id,
       total_price,
       ROUND(AVG(total_price) OVER (
           PARTITION BY user_id
           ORDER BY order_date, id
           ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
       ), 2) AS average_two_orders
FROM orders
ORDER BY user_id, order_date, id;
```

**Запрос 2.** Вычислить сумму текущего и следующего заказа в одном ресторане.

```sql
SELECT id,
       restaurant_id,
       total_price,
       SUM(total_price) OVER (
           PARTITION BY restaurant_id
           ORDER BY order_date, id
           ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING
       ) AS current_and_next_total
FROM orders
ORDER BY restaurant_id, order_date, id;
```

## 6. RANGE

**Запрос 1.** Для каждого заказа найти сумму заказов того же пользователя с ценой от текущей минус 100 рублей до текущей.

```sql
SELECT id,
       user_id,
       total_price,
       SUM(total_price) OVER (
           PARTITION BY user_id
           ORDER BY total_price
           RANGE BETWEEN 100 PRECEDING AND CURRENT ROW
       ) AS nearby_price_total
FROM orders
ORDER BY user_id, total_price, id;
```

**Запрос 2.** Посчитать заказы пользователя с текущей даты и всех последующих дат, включая заказы с одинаковой датой.

```sql
SELECT id,
       user_id,
       order_date,
       COUNT(*) OVER (
           PARTITION BY user_id
           ORDER BY order_date
           RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
       ) AS orders_from_date
FROM orders
ORDER BY user_id, order_date, id;
```

## 7. Ранжирующие функции

**Запрос 1.** Пронумеровать заказы внутри каждого ресторана от самых дорогих (ROW_NUMBER).

```sql
SELECT id,
       restaurant_id,
       total_price,
       ROW_NUMBER() OVER (
           PARTITION BY restaurant_id
           ORDER BY total_price DESC, id
       ) AS row_number
FROM orders
ORDER BY restaurant_id, row_number;
```

**Запрос 2.** Присвоить местам заказов внутри каждого пользователя ранги с пропусками при равной цене (RANK).

```sql
SELECT id,
       user_id,
       total_price,
       RANK() OVER (
           PARTITION BY user_id
           ORDER BY total_price DESC
       ) AS price_rank
FROM orders
ORDER BY user_id, price_rank, id;
```

**Запрос 3.** Присвоить местам заказов внутри каждого пользователя ранги без пропусков (DENSE_RANK).

```sql
SELECT id,
       user_id,
       total_price,
       DENSE_RANK() OVER (
           PARTITION BY user_id
           ORDER BY total_price DESC
       ) AS price_dense_rank
FROM orders
ORDER BY user_id, price_dense_rank, id;
```

## 8. Функции смещения

**Запрос 1.** Вывести стоимость предыдущего заказа каждого пользователя (LAG).

```sql
SELECT id,
       user_id,
       total_price,
       LAG(total_price) OVER (
           PARTITION BY user_id
           ORDER BY order_date, id
       ) AS previous_order_price
FROM orders
ORDER BY user_id, order_date, id;
```

**Запрос 2.** Вывести стоимость следующего заказа каждого пользователя (LEAD).

```sql
SELECT id,
       user_id,
       total_price,
       LEAD(total_price) OVER (
           PARTITION BY user_id
           ORDER BY order_date, id
       ) AS next_order_price
FROM orders
ORDER BY user_id, order_date, id;
```

**Запрос 3.** Показать стоимость первого заказа каждого пользователя (FIRST_VALUE).

```sql
SELECT id,
       user_id,
       total_price,
       FIRST_VALUE(total_price) OVER (
           PARTITION BY user_id
           ORDER BY order_date, id
       ) AS first_order_price
FROM orders
ORDER BY user_id, order_date, id;
```

**Запрос 4.** Показать стоимость последнего заказа каждого пользователя (LAST_VALUE).

```sql
SELECT id,
       user_id,
       total_price,
       LAST_VALUE(total_price) OVER (
           PARTITION BY user_id
           ORDER BY order_date, id
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS last_order_price
FROM orders
ORDER BY user_id, order_date, id;
```
