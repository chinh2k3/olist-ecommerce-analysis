use olist;
drop table if exists stg_order_items;

create table stg_order_items as
with deduped as(
	select
		trim(order_id) as order_id,
		order_item_id,
		trim(product_id) as product_id,
		trim(seller_id) as seller_id,
		str_to_date(shipping_limit_date, '%Y-%m-%d %H:%i:%s') as shipping_limit_date,
		price,
		freight_value,
		row_number() over (partition by order_id, order_item_id order by shipping_limit_date desc) as rn
	from olist_order_items
	where order_id is not null and order_item_id is not null
)
select * from deduped where rn = 1