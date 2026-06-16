insert into olist_dwh.dim_products(	
    product_id, category_name_portuguese, category_name_english, product_name_length,
    product_description_length, product_photos_qty, product_weight_g, product_length_cm,
    product_height_cm, product_width_cm
)

select product_id, op.product_category_name, opc.product_category_name_english, product_name_length,
	product_description_length, product_photos_qty, product_weight_g, product_length_cm,
    product_height_cm, product_width_cm
from olist.stg_product as op
left join olist.product_category as opc 
on op.product_category_name = opc.product_category_name
