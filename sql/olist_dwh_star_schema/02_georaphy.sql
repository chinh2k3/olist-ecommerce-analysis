use olist_dwh;
/*
Top 10 bang (customer_state) có tổng doanh thu cao nhất?
Top 10 bang có số lượng đơn hàng nhiều nhất?
Bang nào có giá trị đơn hàng trung bình cao nhất?
Tỷ lệ giao hàng trễ (delivery_delay_days > 0) theo từng bang khách hàng?
Bang nào có thời gian giao hàng trễ trung bình cao nhất?
Luồng giao dịch: cặp (seller_state → customer_state) nào xuất hiện nhiều nhất? (join thêm dim_seller qua fact_order_items)
*/

-- Top 10 bang (customer_state) có tổng doanh thu cao nhất?
select 
	dc.customer_state as bang,
	sum(fo.payment_value) as tong_doanh_thu
from fact_orders as fo
join dim_customer as dc on fo.customer_key = dc.customer_key
group by dc.customer_state
order by tong_doanh_thu desc
limit 10;

-- Top 10 bang có số lượng đơn hàng nhiều nhất?
select 
	dc.customer_state as bang,
    count(distinct fo.order_id) as tong_so_don
from fact_orders as fo
join dim_customer as dc on fo.customer_key = dc.customer_key
group by dc.customer_state
order by tong_so_don desc
limit 10;

-- Bang nào có giá trị đơn hàng trung bình cao nhất?
with ranked as(
	select 
		dc.customer_state as bang,
		round(avg(fo.total_order_value), 2) as gia_tri_tb,
        rank() over (order by avg(fo.total_order_value) desc) as xep_hang
	from fact_orders as fo
	join dim_customer as dc on fo.customer_key = dc.customer_key
	group by dc.customer_state
)
select 
	bang, 
    gia_tri_tb
from ranked
where xep_hang = 1;

-- Tỷ lệ giao hàng trễ (delivery_delay_days > 0) theo từng bang khách hàng?
with delivery_delay as (
	select 
		dc.customer_state,
		count(distinct fo.order_id) as tong_don,
		count(distinct case when fo.delivery_delay_days > 0 then fo.order_id end) as don_tre
	from fact_orders as fo
	join dim_customer as dc on fo.customer_key = dc.customer_key
	group by dc.customer_state
)
select customer_state, tong_don, don_tre,
	round(don_tre * 100.0 / tong_don, 2) as ty_le_tre_pct
from delivery_delay
order by ty_le_tre_pct desc;

-- Bang nào có thời gian giao hàng trễ trung bình cao nhất?
select 
	dc.customer_state as bang,
    round(avg(fo.delivery_delay_days), 2) as tb_so_ngay_tre
from fact_orders as fo
join dim_customer as dc on fo.customer_key = dc.customer_key
where fo.delivery_delay_days > 0
group by dc.customer_state
order by tb_so_ngay_tre desc
limit 1;

-- Luồng giao dịch: cặp (seller_state → customer_state) nào xuất hiện nhiều nhất?

