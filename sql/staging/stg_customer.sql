use olist;
drop table if exists stg_customer;

create table stg_customer as
with deduped as(
	select
		trim(customer_id) as customer_id,
		trim(customer_unique_id) as customer_unique_id,
        customer_zip_code_prefix as customer_zip_code,
		lower(customer_city) as customer_city,
        upper(customer_state) as customer_state,
        row_number() over(partition by customer_id order by customer_unique_id) as rn
	from olist_customer
	where customer_id is not null and customer_unique_id is not null
)
select * from deduped where rn = 1;


