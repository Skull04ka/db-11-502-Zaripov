# HW5. Агрегатные функции и группировка данных

## a. Агрегатные функции

### COUNT()

**Запрос 1.** Подсчитать общее количество заказов.

```sql
SELECT COUNT(*) AS orders_count
FROM orders;
```

**Запрос 2.** Подсчитать количество различных курьеров, которым назначались заказы.

```sql
SELECT COUNT(DISTINCT courier_id) AS couriers_count
FROM orders;
```

### SUM()

**Запрос 1.** Рассчитать общую стоимость всех заказов.

```sql
SELECT SUM(total_price) AS total_revenue
FROM orders;
```

**Запрос 2.** Рассчитать суммарную стоимость позиций всех заказов с учетом количества блюд.

```sql
SELECT SUM(quantity * price) AS items_total
FROM order_items;
```

### AVG()

**Запрос 1.** Вывести среднюю цену блюда.

```sql
SELECT AVG(price) AS average_dish_price
FROM dishes;
```

**Запрос 2.** Вывести средний рейтинг ресторанов.

```sql
SELECT AVG(rating) AS average_restaurant_rating
FROM restaurants;
```

### MIN()

**Запрос 1.** Найти минимальную цену блюда.

```sql
SELECT MIN(price) AS minimum_dish_price
FROM dishes;
```

**Запрос 2.** Найти дату и время самого раннего заказа.

```sql
SELECT MIN(order_date) AS first_order_date
FROM orders;
```

### MAX()

**Запрос 1.** Найти максимальную стоимость заказа.

```sql
SELECT MAX(total_price) AS maximum_order_price
FROM orders;
```

**Запрос 2.** Найти дату и время последнего заказа.

```sql
SELECT MAX(order_date) AS last_order_date
FROM orders;
```

### STRING_AGG()

**Запрос 1.** Объединить названия всех ресторанов в одну строку в алфавитном порядке.

```sql
SELECT STRING_AGG(name, ', ' ORDER BY name) AS restaurant_names
FROM restaurants;
```

**Запрос 2.** Объединить имена свободных курьеров в одну строку в алфавитном порядке.

```sql
SELECT STRING_AGG(name, ', ' ORDER BY name) AS available_couriers
FROM couriers
WHERE status = 'свободен';
```

## b. GROUP BY, HAVING

### GROUP BY

**Запрос 1.** Подсчитать количество заказов каждого ресторана, включая рестораны без заказов.

```sql
SELECT r.id AS restaurant_id,
       r.name AS restaurant_name,
       COUNT(o.id) AS orders_count
FROM restaurants r
LEFT JOIN orders o ON o.restaurant_id = r.id
GROUP BY r.id, r.name
ORDER BY r.id;
```

**Запрос 2.** Подсчитать общее количество заказанных блюд в каждом заказе.

```sql
SELECT order_id,
       SUM(quantity) AS dishes_count
FROM order_items
GROUP BY order_id
ORDER BY order_id;
```

### HAVING

**Запрос 1.** Вывести рестораны, у которых средняя цена блюда больше 400 рублей.

```sql
SELECT r.id AS restaurant_id,
       r.name AS restaurant_name,
       AVG(d.price) AS average_dish_price
FROM restaurants r
JOIN dishes d ON d.restaurant_id = r.id
GROUP BY r.id, r.name
HAVING AVG(d.price) > 400
ORDER BY average_dish_price DESC;
```

**Запрос 2.** Вывести пользователей, общая стоимость заказов которых превышает 600 рублей.

```sql
SELECT u.id AS user_id,
       u.name AS user_name,
       SUM(o.total_price) AS total_spent
FROM users u
JOIN orders o ON o.user_id = u.id
GROUP BY u.id, u.name
HAVING SUM(o.total_price) > 600
ORDER BY total_spent DESC;
```

## c. GROUPING SETS, ROLLUP и CUBE

### GROUPING SETS

**Запрос 1.** Подсчитать количество заказов отдельно по ресторанам, отдельно по статусам и по всем заказам вместе.

```sql
SELECT restaurant_id,
       status,
       COUNT(*) AS orders_count
FROM orders
GROUP BY GROUPING SETS (
    (restaurant_id),
    (status),
    ()
)
ORDER BY restaurant_id NULLS LAST, status NULLS LAST;
```

**Запрос 2.** Рассчитать выручку по каждой паре «ресторан — статус», итог по каждому ресторану и общий итог.

```sql
SELECT restaurant_id,
       status,
       SUM(total_price) AS total_revenue
FROM orders
GROUP BY GROUPING SETS (
    (restaurant_id, status),
    (restaurant_id),
    ()
)
ORDER BY restaurant_id NULLS LAST, status NULLS LAST;
```

### ROLLUP

**Запрос 1.** Рассчитать выручку по ресторану и статусу заказа, затем итоги по ресторанам и общий итог.

```sql
SELECT restaurant_id,
       status,
       SUM(total_price) AS total_revenue
FROM orders
GROUP BY ROLLUP (restaurant_id, status)
ORDER BY restaurant_id NULLS LAST, status NULLS LAST;
```

**Запрос 2.** Рассчитать количество заказанных блюд по каждому заказу и блюду, затем итоги по заказам и общий итог.

```sql
SELECT order_id,
       dish_id,
       SUM(quantity) AS total_quantity
FROM order_items
GROUP BY ROLLUP (order_id, dish_id)
ORDER BY order_id NULLS LAST, dish_id NULLS LAST;
```

### CUBE

**Запрос 1.** Подсчитать количество заказов для всех сочетаний ресторана и статуса с промежуточными и общим итогами.

```sql
SELECT restaurant_id,
       status,
       COUNT(*) AS orders_count
FROM orders
GROUP BY CUBE (restaurant_id, status)
ORDER BY restaurant_id NULLS LAST, status NULLS LAST;
```

**Запрос 2.** Рассчитать выручку для всех сочетаний транспорта курьера и статуса заказа, а также промежуточные и общий итоги.

```sql
SELECT c.transport_type,
       o.status,
       SUM(o.total_price) AS total_revenue
FROM orders o
JOIN couriers c ON c.id = o.courier_id
GROUP BY CUBE (c.transport_type, o.status)
ORDER BY c.transport_type NULLS LAST, o.status NULLS LAST;
```

## d. SELECT, FROM, WHERE, GROUP BY, HAVING, ORDER BY

**Запрос 1.** Вывести рестораны, выручка которых по доставленным заказам не меньше 500 рублей, с количеством таких заказов. Отсортировать по убыванию выручки.

```sql
SELECT r.id AS restaurant_id,
       r.name AS restaurant_name,
       COUNT(o.id) AS delivered_orders,
       SUM(o.total_price) AS delivered_revenue
FROM restaurants r
JOIN orders o ON o.restaurant_id = r.id
WHERE o.status = 'доставлен'
GROUP BY r.id, r.name
HAVING SUM(o.total_price) >= 500
ORDER BY delivered_revenue DESC, restaurant_name;
```

**Запрос 2.** Вывести виды транспорта курьеров, у которых средняя стоимость заказов, кроме созданных, превышает 600 рублей. Отсортировать по убыванию средней стоимости.

```sql
SELECT c.transport_type,
       COUNT(o.id) AS orders_count,
       AVG(o.total_price) AS average_order_price
FROM couriers c
JOIN orders o ON o.courier_id = c.id
WHERE o.status <> 'создан'
GROUP BY c.transport_type
HAVING AVG(o.total_price) > 600
ORDER BY average_order_price DESC, c.transport_type;
```
