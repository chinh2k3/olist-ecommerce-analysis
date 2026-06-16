use olist_dwh;

-- Doanh thu theo quý
select 
    concat('Q', dd.quarter, '-', dd.year ) as ky_bao_cao,
    sum(payment_value) as doanh_thu
from fact_orders as fo
join dim_date as dd on fo.approved_date_key = dd.date_key
group by dd.year, dd.quarter
order by dd.year, dd.quarter;

-- Doanh thu theo tháng
drop view if exists vw_revenue_monthly;
create view vw_revenue_monthly as
select 
	dd.year,
    dd.month,
    concat(dd.month,'/', dd.year) as ky_bao_cao,
    sum(payment_value) as doanh_thu
from fact_orders as fo
join dim_date as dd on fo.approved_date_key = dd.date_key
group by dd.year, dd.month
order by dd.year, dd.month;

-- Số đơn hàng đặt theo từng tháng — có xu hướng tăng trưởng không?
select 
	concat(dd.month, '/', dd.year) as month,
	count(distinct fo.order_id) as total_order
from fact_orders as fo
join dim_date as dd on fo.approved_date_key = dd.date_key
group by dd.year, dd.month
order by dd.year, dd.month;

-- Giá trị đơn hàng trung bình (AOV) theo từng tháng?
select 
	concat(dd.month, '/', dd.year) as month,
    round(avg(fo.payment_value), 2) as aov
from fact_orders as fo
join dim_date as dd on fo.approved_date_key = dd.date_key
group by dd.year, dd.month
order by dd.year, dd.month;

-- Tháng nào có doanh thu cao nhất và thấp nhất trong toàn dataset?
with doanh_thu as(
	select 
		concat(dd.month, '/', dd.year) as thang,
		sum(fo.payment_value) as tong_doanh_thu
	from fact_orders as fo
	join dim_date as dd on fo.approved_date_key = dd.date_key
	group by dd.year, dd.month
	order by dd.year, dd.month
)
select
	thang,
    tong_doanh_thu,
    case 
		when tong_doanh_thu = max(tong_doanh_thu) over() then 'cao nhat'
        when tong_doanh_thu = min(tong_doanh_thu) over() then 'thap nhat'
	end as nhan_xet
from doanh_thu
where tong_doanh_thu = (select max(tong_doanh_thu) from doanh_thu) or
	tong_doanh_thu = (select min(tong_doanh_thu) from doanh_thu)
order by tong_doanh_thu desc;

-- Tăng trưởng doanh thu YoY (Year over Year) giữa 2017 và 2018?

with year_revenue as (
	select 
		dd.year,
        sum(fo.payment_value) as doanh_thu
    from fact_orders as fo
    join dim_date as dd on fo.approved_date_key = dd.date_key
    where dd.year in (2017, 2018)
    group by dd.year
)
select
	curr.year as nam,
    curr.doanh_thu as doanh_thu_nam_truoc,
    pre.doanh_thu as doanh_thu_nam_sau,
    round((curr.doanh_thu - pre.doanh_thu) / pre.doanh_thu * 100, 2) as tang_truong_yoy_pct
from 	  year_revenue as curr
left join year_revenue as pre on curr.year = pre.year + 1
order by curr.year;

-- Phân phối đơn hàng theo ngày trong tuần — ngày nào có nhiều đơn nhất?
select 
    case dd.day_of_week
		when 0 then 'Monday'
        when 1 then 'Tuesday'
        when 2 then 'Wednesday'
        when 3 then 'Thursday'
        when 4 then 'Friday'
        when 5 then 'Saturday'
        when 6 then 'Sunday'
	end as ten_ngay,
    count(distinct fo.order_id) as tong_don_hang
from fact_orders as fo
join dim_date as dd on fo.approved_date_key = dd.date_key
group by dd.day_of_week
order by dd.day_of_week


