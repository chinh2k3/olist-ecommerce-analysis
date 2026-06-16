insert into olist_dwh.dim_customer(	
	customer_id, customer_unique_id, customer_zip_code, customer_city,
    customer_state, customer_lat, customer_lng
)
select customer_id, customer_unique_id, customer_zip_code, customer_city,
		customer_state, og.lat, og.lng
from olist.stg_customer as oc
left join olist.stg_geolocation as og 
on oc.customer_zip_code = og.zip_code
