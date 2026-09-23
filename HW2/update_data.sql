UPDATE orders
SET status = 'доставлен'
WHERE id = 2;

UPDATE restaurants
SET rating = 4.8
WHERE id = 1;

UPDATE dishes
SET price = 369.00
WHERE id = 1;

UPDATE couriers
SET status = 'свободен'
WHERE id = 4;

UPDATE users
SET address = 'Казань, ул. Университетская, 7'
WHERE id = 3;
