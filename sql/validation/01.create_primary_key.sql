-- olist_customer
ALTER TABLE olist_customer
	ADD PRIMARY KEY(customer_id);
    
-- olist_order
ALTER TABLE olist_orders
	ADD PRIMARY KEY(order_id);
    
-- olist_products
ALTER TABLE olist_products
	ADD PRIMARY KEY(product_id);
    
-- olist_seller
ALTER TABLE olist_sellers
	ADD PRIMARY KEY(seller_id)