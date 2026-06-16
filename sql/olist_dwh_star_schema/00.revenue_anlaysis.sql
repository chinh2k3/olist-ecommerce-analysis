use olist_dwh;

with doanh_thu as(
	select 
		d.year as nam,
        d.quarter as quy,
        concat('Q', d.quarter, '-', d.year) as ky_bao_cao,
        
        -- Doanh Thu
        count(distinct fo.order_id) as tong_so_don,
        sum(fo.total_order_value) as tong_doanh_thu,
        sum(fo.total_freight_value) as chi_phi_van_chuyen,
        sum(fo.total_order_value - fo.total_freight_value) as doanh_thu_san_pham,
        
        -- Giá trị trung bình 
        ROUND(AVG(fo.total_order_value), 2) AS gia_tri_tb_don, 
        ROUND(AVG(fo.total_items), 2) AS so_sp_don_tb, 
        
        -- Tỉ trọng vận chuyển
        round(sum(fo.total_freight_value) / nullif(sum(fo.total_order_value), 0) * 100, 2) as pct_phi_van_chuyen
	from fact_orders fo
	join dim_date d on fo.purchase_date_key = d.date_key
    group by nam, quy
    order by nam, quy asc
)

select * from doanh_thu
