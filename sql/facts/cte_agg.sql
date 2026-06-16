-- CTE: Payment
use olist;

drop table if exists tmp_payment;
create table tmp_payment as
select 
	CAST(order_id AS CHAR(50)) AS order_id,
	sum(payment_value) as payment_value,
	sum(payment_installments) as payment_installments,
	substring_index(group_concat(payment_type order by payment_value desc),',', 1)  as payment_type_name
from olist.stg_payment
group by order_id;

-- CTE: Review
drop table if exists tmp_review;
create table tmp_review as
select order_id, review_score, review_answer_delay_days
from (
	select
		CAST(order_id AS CHAR(50)) AS order_id,
		review_score,
		DATEDIFF(review_answer_timestamp, review_creation_date) as review_answer_delay_days,
		row_number() over(partition by order_id order by review_answer_timestamp desc) as rn
	from olist.stg_review
) t
where rn = 1;

-- CTE: Items
drop table if exists tmp_items;
create table tmp_items as
select
	CAST(order_id AS CHAR(50)) AS order_id,
	count(*) as total_items,
	sum(freight_value) as total_freight_value
from olist.stg_order_items
group by order_id;

ALTER TABLE tmp_payment ADD INDEX idx_order_id(order_id);
ALTER TABLE tmp_review  ADD INDEX idx_order_id(order_id);
ALTER TABLE tmp_items   ADD INDEX idx_order_id(order_id);