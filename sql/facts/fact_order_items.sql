insert into olist_dwh.fact_order_items(
    order_id,
    order_item_id, 
    order_key,   
    product_key,
    seller_key,
    customer_key,
    purchase_date_key,
    price,
    freight_value,
    total_item_value,
    shipping_limit_date
)
select 
	oi.order_id,
    oi.order_item_id,
        
    -- FK: date
    o.order_key,
	dp.product_key,
    ds.seller_key,
	o.customer_key,
    o.purchase_date_key,
    
    --
    round(oi.price, 2) as price,
    round(oi.freight_value, 2) as freight_value,
	round(oi.price + oi.freight_value, 2)  as total_item_value,
    
	oi.shipping_limit_date
from olist.stg_order_items AS oi

left join olist_dwh.dim_products as dp
	on oi.product_id = dp.product_id

left join olist_dwh.dim_seller as ds
	on oi.seller_id = ds.seller_id
    
left join olist_dwh.fact_orders as o
	on oi.order_id = o.order_id

    