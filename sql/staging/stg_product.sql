use olist;
drop table if exists stg_product;

create table stg_product as
with deduped as(
	select
		trim(product_id) as product_id,
		coalesce(lower(product_category_name), 'unknown') as product_category_name,
		product_name_lenght as product_name_length,
        product_description_lenght as product_description_length,
        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm,
        row_number() over(partition by product_id order by product_id) as rn
	from olist_products
	where product_id is not null
)
select * from deduped where rn = 1;


