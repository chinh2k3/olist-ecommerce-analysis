use olist;
drop table if exists stg_seller;

create table stg_seller as
with deduped as(
	select
		trim(seller_id) as seller_id,
        seller_zip_code_prefix as seller_zip_code,
		lower(seller_city) as seller_city,
        upper(seller_state) as seller_state,
        row_number() over(partition by seller_id order by seller_id) as rn
	from olist_sellers
	where seller_id is not null
)
select * from deduped where rn = 1;