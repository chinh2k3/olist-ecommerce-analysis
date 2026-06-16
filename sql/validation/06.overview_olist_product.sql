-- 6.1 Thông tin cở bản
select count(*) as total_rows from olist_products;
select * from olist_products limit 5;

-- 6.2 Kiểm tra NULL
select
	sum(case when product_id is null then 1 else 0 end) as null_product_id,
    sum(case when product_category_name is null then 1 else 0 end) as null_product_category_name,
    sum(case when product_name_lenght is null then 1 else 0 end) as null_product_name_lenght,
    sum(case when product_description_lenght is null then 1 else 0 end) as null_description_lenght,
    sum(case when product_photos_qty is null then 1 else 0 end) as null_product_photos_qty,
    sum(case when product_weight_g is null then 1 else 0 end) as null_product_weight_g,
    sum(case when product_length_cm is null then 1 else 0 end) as null_product_length_cm,
    sum(case when product_height_cm  is null then 1 else 0 end) as null_product_height_cm ,
    sum(case when product_width_cm  is null then 1 else 0 end) as null_product_width_cm 
from olist_products;

-- 6.3 Kiểm tra dupplicate
select product_id, count(*) as cnt
from olist_products
group by product_id
having cnt > 1;

-- 6.4 Distribution category 
select product_category_name, count(*) as cnt
from olist_products
group by product_category_name
order by cnt desc;

-- 6.5 Range phisical attribute
select
    min(product_weight_g) as min_weight,
    max(product_weight_g) as max_weight,
    avg(product_weight_g) as avg_weight
FROM olist_products;
