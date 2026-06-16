set session cte_max_recursion_depth = 2000;
insert into olist_dwh.dim_date (
	date_key, full_date, day, month, month_name,
	quarter, year, week_of_year, day_of_week, day_name, is_weekend
)

-- recursive: bảng tự sinh dữ liệu = cách dùng lại chính nó
with recursive date_series as (
    select date('2016-01-01') as dt
    
	union all
    
    -- Recursive: cộng 1 ngày mỗi bước
    select dt + interval 1 day
    from date_series
    where dt < '2018-12-31'
)
select
    date_format(dt, '%Y%m%d') as date_key,
    dt as full_date,
    day(dt) as day,
    month(dt) as month,
    monthname(dt) as month_name,
    quarter(dt) as quarter,
    year(dt) as year,
    week(dt, 3) as week_of_year,
    weekday(dt) as day_of_week,
    dayname(dt) as day_name,
    weekday(dt) >= 5  as is_weekend
from date_series;