insert into olist_dwh.fact_orders(
    order_id,
    customer_key,
    purchase_date_key, 
    approved_date_key,
    delivered_carrier_date_key,
    delivered_customer_date_key,
    estimated_delivery_date_key,
    order_status,
    payment_type_key,
    payment_installments,
    payment_value,
    review_score, 
    review_answer_delay_days, 
    delivery_delay_days , 
    carrier_to_customer_days,
    total_items,
    total_freight_value,
    total_order_value
)
select 
	o.order_id,
    
    -- FK: customer
    dc.customer_key,
    
    -- FK: date
    date_format(o.purchase_dt, '%Y%m%d') as purchase_date_key,
    date_format(o.approved_dt, '%Y%m%d') as approved_date_key,
    date_format(o.carrier_dt, '%Y%m%d') as delivered_carrier_date_key,
    date_format(o.customer_dt, '%Y%m%d') as delivered_customer_date_key,
    date_format(o.estimated_dt, '%Y%m%d') as estimated_delivery_date_key,
    
    -- order status
    o.order_status,
    
    -- FK: payment type
    COALESCE(
        dp.payment_type_key,
        (SELECT payment_type_key FROM olist_dwh.dim_payment WHERE payment_type = 'not_defined')
    ),
    p.payment_installments,
    round(p.payment_value, 2) as payment_value,
    
	-- review
    r.review_score,
    r.review_answer_delay_days,
    
        -- delivery metrics
    DATEDIFF(o.customer_dt, o.estimated_dt) as delivery_delay_days,

    DATEDIFF(o.customer_dt, o.carrier_dt) as carrier_to_customer_days,

    -- measures
    i.total_items,
    round(i.total_freight_value, 2) as total_freight_value,
    round(p.payment_value, 2) as total_order_value
from olist.stg_orders AS o

-- CTE
left join olist.tmp_payment as p
    on o.order_id = p.order_id

left join olist.tmp_review as r
    on o.order_id = r.order_id

left join olist.tmp_items as i
    on o.order_id = i.order_id
    
-- dim lookups
left join olist_dwh.dim_customer as dc
    on o.customer_id = dc.customer_id

left join olist_dwh.dim_payment as dp
    on p.payment_type_name = dp.payment_type
    