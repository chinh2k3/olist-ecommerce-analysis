insert into olist_dwh.dim_seller(	
    seller_id, seller_zip_code, seller_city,
    seller_state, seller_lat, seller_lng
)

select seller_id, seller_zip_code, seller_city,
		seller_state, og.lat, og.lng
from olist.stg_seller as os
left join olist.stg_geolocation as og 
on os.seller_zip_code = og.zip_code
