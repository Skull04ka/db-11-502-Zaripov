ALTER TABLE users
ADD COLUMN created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE users
ADD CONSTRAINT uq_users_email UNIQUE (email);

ALTER TABLE restaurants
ADD CONSTRAINT chk_restaurants_rating
CHECK (rating BETWEEN 0 AND 5);

ALTER TABLE dishes
ADD CONSTRAINT chk_dishes_price
CHECK (price > 0);

ALTER TABLE order_items
ADD CONSTRAINT chk_order_items_quantity
CHECK (quantity > 0);
