-- 1. orders → customer
ALTER TABLE olist_orders
    ADD CONSTRAINT fk_orders_customer
    FOREIGN KEY (customer_id) 
    REFERENCES olist_customer(customer_id);

-- 2. order_items → orders
ALTER TABLE olist_order_items
    ADD CONSTRAINT fk_items_orders
    FOREIGN KEY (order_id) 
    REFERENCES olist_orders(order_id);

-- 3. order_items → products
ALTER TABLE olist_order_items
    ADD CONSTRAINT fk_items_products
    FOREIGN KEY (product_id) 
    REFERENCES olist_products(product_id);

-- 4. order_items → sellers
ALTER TABLE olist_order_items
    ADD CONSTRAINT fk_items_sellers
    FOREIGN KEY (seller_id) 
    REFERENCES olist_sellers(seller_id);

-- 5. reviews → orders
ALTER TABLE olist_reviews
    ADD CONSTRAINT fk_reviews_orders
    FOREIGN KEY (order_id) 
    REFERENCES olist_orders(order_id);

-- 6. payments → orders
ALTER TABLE olist_order_payments
    ADD CONSTRAINT fk_payments_orders
    FOREIGN KEY (order_id) 
    REFERENCES olist_orders(order_id);
  
 -- check table relationship  
SELECT 
    TABLE_NAME        as 'Bảng con',
    COLUMN_NAME       as 'Cột FK',
    REFERENCED_TABLE_NAME  as 'Bảng cha',
    REFERENCED_COLUMN_NAME as 'Cột PK'
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'olist'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME;