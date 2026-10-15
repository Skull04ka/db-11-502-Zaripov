# HW5. Агрегатные функции и группировка данных



## a. Агрегатные функции

### COUNT()

**Запрос 1.** Подсчитать общее количество заказов.

```sql
SELECT COUNT(\*) AS orders\_count
FROM orders;
```

**Запрос 2.** Подсчитать количество различных курьеров, которым назначались заказы.

```sql
SELECT COUNT(DISTINCT courier\_id) AS couriers\_count
FROM orders;
```

### SUM()

**Запрос 1.** Рассчитать общую стоимость всех заказов.

```sql
SELECT SUM(total\_price) AS total\_revenue
FROM orders;
```

**Запрос 2.** Рассчитать суммарную стоимость позиций всех заказов с учетом количества блюд.

```sql
SELECT SUM(quantity \* price) AS items\_total
FROM order\_items;
```

### AVG()

**Запрос 1.** Вывести среднюю цену блюда.

```sql
SELECT AVG(price) AS average\_dish\_price
FROM dishes;
```

**Запрос 2.** Вывести средний рейтинг ресторанов.

```sql
SELECT AVG(rating) AS average\_restaurant\_rating
FROM restaurants;
```

### MIN()

**Запрос 1.** Найти минимальную цену блюда.

```sql
SELECT MIN(price) AS minimum\_dish\_price
FROM dishes;
```

**Запрос 2.** Найти дату и время самого раннего заказа.

```sql
SELECT MIN(order\_date) AS first\_order\_date
FROM orders;
```

### MAX()

**Запрос 1.** Найти максимальную стоимость заказа.

```sql
SELECT MAX(total\_price) AS maximum\_order\_price
FROM orders;
```

**Запрос 2.** Найти дату и время последнего заказа.

```sql
SELECT MAX(order\_date) AS last\_order\_date
FROM orders;
```

### STRING\_AGG()

**Запрос 1.** Объединить названия всех ресторанов в одну строку в алфавитном порядке.

```sql
SELECT STRING\_AGG(name, ', ' ORDER BY name) AS restaurant\_names
FROM restaurants;
```

**Запрос 2.** Объединить имена свободных курьеров в одну строку в алфавитном порядке.

```sql
SELECT STRING\_AGG(name, ', ' ORDER BY name) AS available\_couriers
FROM couriers
WHERE status = 'свободен';
```

## b. GROUP BY, HAVING

### GROUP BY

**Запрос 1.** Подсчитать количество заказов каждого ресторана, включая рестораны без заказов.

```sql
SELECT r.id AS restaurant\_id,
       r.name AS restaurant\_name,
       COUNT(o.id) AS orders\_count
FROM restaurants r
LEFT JOIN orders o ON o.restaurant\_id = r.id
GROUP BY r.id, r.name
ORDER BY r.id;
```

**Запрос 2.** Подсчитать общее количество заказанных блюд в каждом заказе.

```sql
SELECT order\_id,
       SUM(quantity) AS dishes\_count
FROM order\_items
GROUP BY order\_id
ORDER BY order\_id;
```

### HAVING

**Запрос 1.** Вывести рестораны, у которых средняя цена блюда больше 400 рублей.

```sql
SELECT r.id AS restaurant\_id,
       r.name AS restaurant\_name,
       AVG(d.price) AS average\_dish\_price
FROM restaurants r
JOIN dishes d ON d.restaurant\_id = r.id
GROUP BY r.id, r.name
HAVING AVG(d.price) > 400
ORDER BY average\_dish\_price DESC;
```

**Запрос 2.** Вывести пользователей, общая стоимость заказов которых превышает 600 рублей.

```sql
SELECT u.id AS user\_id,
       u.name AS user\_name,
       SUM(o.total\_price) AS total\_spent
FROM users u
JOIN orders o ON o.user\_id = u.id
GROUP BY u.id, u.name
HAVING SUM(o.total\_price) > 600
ORDER BY total\_spent DESC;
```

## c. GROUPING SETS, ROLLUP и CUBE

### GROUPING SETS

**Запрос 1.** Подсчитать количество заказов отдельно по ресторанам, отдельно по статусам и по всем заказам вместе.

```sql
SELECT restaurant\_id,
       status,
       COUNT(\*) AS orders\_count
FROM orders
GROUP BY GROUPING SETS (
    (restaurant\_id),
    (status),
    ()
)
ORDER BY restaurant\_id NULLS LAST, status NULLS LAST;
```

**Запрос 2.** Рассчитать выручку по каждой паре «ресторан — статус», итог по каждому ресторану и общий итог.

```sql
SELECT restaurant\_id,
       status,
       SUM(total\_price) AS total\_revenue
FROM orders
GROUP BY GROUPING SETS (
    (restaurant\_id, status),
    (restaurant\_id),
    ()
)
ORDER BY restaurant\_id NULLS LAST, status NULLS LAST;
```

### ROLLUP

**Запрос 1.** Рассчитать выручку по ресторану и статусу заказа, затем итоги по ресторанам и общий итог.

```sql
SELECT restaurant\_id,
       status,
       SUM(total\_price) AS total\_revenue
FROM orders
GROUP BY ROLLUP (restaurant\_id, status)
ORDER BY restaurant\_id NULLS LAST, status NULLS LAST;
```

**Запрос 2.** Рассчитать количество заказанных блюд по каждому заказу и блюду, затем итоги по заказам и общий итог.

```sql
SELECT order\_id,
       dish\_id,
       SUM(quantity) AS total\_quantity
FROM order\_items
GROUP BY ROLLUP (order\_id, dish\_id)
ORDER BY order\_id NULLS LAST, dish\_id NULLS LAST;
```

### CUBE

**Запрос 1.** Подсчитать количество заказов для всех сочетаний ресторана и статуса с промежуточными и общим итогами.

```sql
SELECT restaurant\_id,
       status,
       COUNT(\*) AS orders\_count
FROM orders
GROUP BY CUBE (restaurant\_id, status)
ORDER BY restaurant\_id NULLS LAST, status NULLS LAST;
```

**Запрос 2.** Рассчитать выручку для всех сочетаний транспорта курьера и статуса заказа, а также промежуточные и общий итоги.

```sql
SELECT c.transport\_type,
       o.status,
       SUM(o.total\_price) AS total\_revenue
FROM orders o
JOIN couriers c ON c.id = o.courier\_id
GROUP BY CUBE (c.transport\_type, o.status)
ORDER BY c.transport\_type NULLS LAST, o.status NULLS LAST;
```

## d. SELECT, FROM, WHERE, GROUP BY, HAVING, ORDER BY

**Запрос 1.** Вывести рестораны, выручка которых по доставленным заказам не меньше 500 рублей, с количеством таких заказов. Отсортировать по убыванию выручки.

```sql
SELECT r.id AS restaurant\_id,
       r.name AS restaurant\_name,
       COUNT(o.id) AS delivered\_orders,
       SUM(o.total\_price) AS delivered\_revenue
FROM restaurants r
JOIN orders o ON o.restaurant\_id = r.id
WHERE o.status = 'доставлен'
GROUP BY r.id, r.name
HAVING SUM(o.total\_price) >= 500
ORDER BY delivered\_revenue DESC, restaurant\_name;
```

**Запрос 2.** Вывести виды транспорта курьеров, у которых средняя стоимость заказов, кроме созданных, превышает 600 рублей. Отсортировать по убыванию средней стоимости.

```sql
SELECT c.transport\_type,
       COUNT(o.id) AS orders\_count,
       AVG(o.total\_price) AS average\_order\_price
FROM couriers c
JOIN orders o ON o.courier\_id = c.id
WHERE o.status <> 'создан'
GROUP BY c.transport\_type
HAVING AVG(o.total\_price) > 600
ORDER BY average\_order\_price DESC, c.transport\_type;
```

