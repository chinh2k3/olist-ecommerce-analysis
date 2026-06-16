use olist;

-- 3.1 Thông tin cở bản
select count(*) as total_rows from olist_orders;
select * from olist_orders limit 5;

-- 3.2 Kiểm tra NULL
select
    sum(case when order_id is null then 1 else 0 end) as null_order_id,
    sum(case when customer_id is null then 1 else 0 end) as null_customer_id,
    sum(case when order_status is null then 1 else 0 end) as null_status,
    sum(case when order_purchase_timestamp is null then 1 else 0 end) as null_purchase_date,
    sum(case when order_approved_at is null then 1 else 0 end) as null_approved_date,
    sum(case when order_delivered_carrier_date is null then 1 else 0 end) as null_carrier_date,
    sum(case when order_delivered_customer_date is null then 1 else 0 end) as null_delivered_date,
    sum(case when order_estimated_delivery_date is null then 1 else 0 end) as null_estimated_date
from olist_orders;

-- 3.3 Kiểm tra dupplicate
select order_id, count(*) as cnt
from olist_orders
group by order_id
having cnt > 1;

-- 3.4 Distribution order_status
select order_status, count(*) as cnt
from olist_orders
group by order_status
order by cnt desc;

-- 3.5 Range date
select
    min(order_purchase_timestamp) as earliest_order,
    max(order_purchase_timestamp) as latest_order
from olist_orders;
