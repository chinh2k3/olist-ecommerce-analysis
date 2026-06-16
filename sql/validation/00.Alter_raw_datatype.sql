-- olist_customer
ALTER TABLE olist_customer
    MODIFY COLUMN customer_id VARCHAR(50) NOT NULL,
    MODIFY COLUMN customer_unique_id VARCHAR(50),
    MODIFY COLUMN customer_zip_code_prefix VARCHAR(10),
    MODIFY COLUMN customer_city VARCHAR(100),
    MODIFY COLUMN customer_state VARCHAR(5);

-- olist_orders  
ALTER TABLE olist_orders
    MODIFY COLUMN order_id VARCHAR(50) NOT NULL,
    MODIFY COLUMN customer_id VARCHAR(50) NOT NULL,
    MODIFY COLUMN order_status VARCHAR(20);

-- olist_products
ALTER TABLE olist_products
    MODIFY COLUMN product_id VARCHAR(50) NOT NULL,
    MODIFY COLUMN product_category_name VARCHAR(100);

-- olist_sellers
ALTER TABLE olist_sellers
    MODIFY COLUMN seller_id VARCHAR(50) NOT NULL,
    MODIFY COLUMN seller_zip_code_prefix VARCHAR(10),
    MODIFY COLUMN seller_city VARCHAR(100),
    MODIFY COLUMN seller_state VARCHAR(5);

-- olist_order_items
ALTER TABLE olist_order_items
    MODIFY COLUMN order_id VARCHAR(50) NOT NULL,
    MODIFY COLUMN product_id VARCHAR(50) NOT NULL,
    MODIFY COLUMN seller_id VARCHAR(50) NOT NULL;

-- olist_reviews
ALTER TABLE olist_reviews
    MODIFY COLUMN review_id VARCHAR(50),
    MODIFY COLUMN order_id VARCHAR(50) NOT NULL;

-- olist_order_payments
ALTER TABLE olist_order_payments
    MODIFY COLUMN order_id VARCHAR(50) NOT NULL;
