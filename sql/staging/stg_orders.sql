use olist;
drop table if exists stg_orders;

create table stg_orders as
with deduped as(
	select
		trim(order_id) as order_id,
		trim(customer_id) as customer_id,
		case
			when order_status in ('delivered','shipped','canceled', 'invoiced','processing','unavailable','approved') 
			then order_status 
			else 'Unknown'
		end as order_status,
		str_to_date(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s') as purchase_dt,
		str_to_date(order_approved_at, '%Y-%m-%d %H:%i:%s') as approved_dt,
		str_to_date(order_delivered_carrier_date, '%Y-%m-%d %H:%i:%s') as carrier_dt,
		str_to_date(order_delivered_customer_date, '%Y-%m-%d %H:%i:%s') as customer_dt,
		str_to_date(order_estimated_delivery_date, '%Y-%m-%d %H:%i:%s') as estimated_dt,
        row_number() over(partition by order_id order by order_purchase_timestamp desc) as rn
	from olist_orders
	where order_id is not null and customer_id is not null
)
select * from deduped where rn = 1;


