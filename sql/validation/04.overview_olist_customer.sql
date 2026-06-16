use olist;

-- 4.1 Thông tin cơ bản
select count(*) as total_customer from olist_customer;
select * from olist_customer limit 5;

-- 4.2 Kiểm tra null
select
	sum(case when customer_id is null then 1 else 0 end) as null_customer_id,
    sum(case when customer_unique_id is null then 1 else 0 end) as null_customer_unique_id,
    sum(case when customer_zip_code_prefix is null then 1 else 0 end) as null_customer_zip_code_prefix,
    sum(case when customer_city is null then 1 else 0 end) as null_customer_city,
    sum(case when customer_state is null then 1 else 0 end) as null_customer_state
from olist_customer;

-- 4.3 Kiểm tra dupplicate
select customer_id, count(*) as cnt
from olist_customer
group by customer_id
having cnt > 1;

-- 4.4 Distribution theo state
select customer_state, count(*) cnt
from olist_customer
group by customer_state
order by cnt desc;

-- 4.5 FK check với olist_orders
select count(*) order_with_customer
from olist_orders o
left join olist_customer c on o.customer_id = c.customer_id
where c.customer_id is null