use olist;

-- 5.1 Thông tin cơ bản
select count(*) as total_order_item from olist_order_items;
select * from olist_order_items limit 5; 

-- 5.2 Kiểm tra giá trị null
select
	sum(case when order_id is null then 1 else 0 end) as null_order_id,
    sum(case when freight_value is null then 1 else 0 end) as null_freight_value,
    sum(case when product_id is null then 1 else 0 end) as null_product_id,
    sum(case when seller_id is null then 1 else 0 end) as null_seller_id,
    sum(case when shipping_limit_date is null then 1 else 0 end) as null_shipping_limit_date,
    sum(case when price is null then 1 else 0 end) as null_price_id
from olist_order_items;

-- 5.3 Range price and freight
select 
	min(price) as min_price,
    max(price) as max_price,
    avg(price) as avg_price,
    min(freight_value) as min_freight_value,
    max(freight_value) as max_freight_value,
    avg(freight_value) as avg_freight_value
from olist_order_items;

-- 5.4 Số item trong mỗi order
select 
	avg(item_count) as avg_item_count,
    max(item_count) as max_item_count
from(
	select order_id, count(*) item_count
    from olist_order_items
    group by order_id
) t;

-- 5.5 FK với olist_order
select count(*) as items_with_out
from olist_order_items oi
left join olist_orders o on oi.order_id = o.order_id
where o.order_id is null;