use olist_dwh;

-- ------------------------------------------------------------
-- Bước 1: Bảng trạng thái của seller
-- ------------------------------------------------------------
drop temporary table if exists tmp_seller_stats;
create temporary table tmp_seller_stats as
select
    foi.seller_key,
    count(distinct foi.order_key) as seller_total_orders,
    round(avg(fo.delivery_delay_days), 2) as seller_avg_delay,
    round(sum(case when fo.delivery_delay_days > 0 then 1 else 0 end) / nullif(count(*), 0), 4)  as seller_late_rate,
    round(avg(fo.review_score), 3) as seller_avg_review_score
from fact_order_items as foi
join fact_orders as fo on foi.order_key = fo.order_key
where fo.review_score  is not null
  and fo.order_status  = 'delivered'
group by foi.seller_key;
 
-- Index để JOIN nhanh
alter table tmp_seller_stats add index idx_seller_key (seller_key);

-- ---------------------------------------------------------------------------
-- BƯỚC 2: Tạo bảng ml_dataset
-- ---------------------------------------------------------------------------
drop table if exists ml_dataset;

create table ml_dataset(

	-- TARGER
	review_score int,				-- Điểm đánh giá gốc từ 1-5
	is_satisfied tinyint(1),		-- Target: hài lòng 0(4-5s) không hài lòng 1 (1-3s)
    
    -- DELIVERY
    delivery_delay_days 	int,	-- Số ngày trễ so vơi dự kiến
    estimated_delivery_days int, 	-- Số ngày dự kiến giao hàng
    
	-- DELIVERY DETAIL
    actual_delivery_days      int,  -- Số ngày thực tế từ mua đến khi nhận hàng
    carrier_to_customer_days  int,  -- Ngày từ carrier nhận đến khi giao tay khách
    review_answer_delay_days  int,  -- Ngày từ lúc mua đến khi khách điền review
 
    -- ORDER
    total_order_value       decimal(10,2), -- Tổng giá trị đơn hàng
    total_freight_value     decimal(10,2), -- Tổng phí vận chuyển
    total_items 			int,  		   -- Tổng số sản phẩm
    freight_ratio           decimal(10,4), -- Tỉ lệ phí vận chuyển / giá trị đơn
    payment_installments	int, 		   -- Số kỳ trả góp
    payment_value     		decimal(10,2), -- Giá trị thanh toán
    
    -- PAYMENT
    payment_type  varchar(50),   -- Kiểu thanh toán
    
    -- PRODUCT
    category_name_english 	varchar(50), -- Tên sản phâm bằng tiếng anh
    
    -- GEO
    customer_state  varchar(10),   -- Bang của khách hàng
    customer_lat 	float,
    customer_lng 	float,
    seller_state    varchar(10),   -- Bang của người bán
    seller_lat		float,
    seller_lng		float,

     -- SELLER REPUTATION (NEW)
    seller_total_orders       int,            -- Tổng đơn seller đã xử lý
    seller_late_rate          decimal(10,4),  -- Tỉ lệ đơn giao trễ của seller
    seller_avg_review_score   decimal(10,3),  -- Điểm review trung bình của seller
    seller_avg_delay          decimal(10,2),  -- Delay trung bình của seller (ngày)
    
    -- TIME
	month     int, 		  -- Tháng đặt hàng (1–12),
    day_name  varchar(10) -- Thứ trong tuần (0=Thứ Hai, 6=Chủ Nhật),
) engine = InnoDB
DEFAULT CHARSET=utf8mb4;

insert into ml_dataset
select 
	fo.review_score as review_score,
    case when fo.review_score >=4 then 0 else 1 end as is_satisfied,
    
    -- DELIVERY
    coalesce(fo.delivery_delay_days, 0) as delivery_delay_days, 
    datediff(
		str_to_date(cast(fo.estimated_delivery_date_key as char), '%Y%m%d'),
		str_to_date(cast(fo.purchase_date_key as char), '%Y%m%d') ) as estimated_delivery_days,
	
	-- DELIVERY DETAIL
    datediff(
        str_to_date(cast(fo.delivered_customer_date_key as char), '%Y%m%d'),
        str_to_date(cast(fo.purchase_date_key as char), '%Y%m%d')) as actual_delivery_days,
        
	fo.carrier_to_customer_days,
    fo.review_answer_delay_days,
    
    -- ORDER
    fo.total_order_value,
    fo.total_freight_value,
    fo.total_items,
	ROUND(fo.total_freight_value / NULLIF(fo.total_order_value, 0),4) as freight_ratio,
    fo.payment_installments,
    fo.payment_value,
    
    -- PAYMENT
    dp.payment_type as payment_type,
    
    -- PRODUCT
    coalesce(dpd.category_name_english, 'Unknown') as category_name_english,

    -- GEO
    dc.customer_state as customer_state,
    dc.customer_lat   as customer_lat,
    dc.customer_lng   as customer_lng,
	coalesce(ds.seller_state, 'Unknown')  as seller_state,
    ds.seller_lat     as seller_lat,
    ds.seller_lng     as seller_lng,

    -- SELLER REPUTATION (NEW — từ tmp_seller_stats)
    coalesce(ss.seller_total_orders, 0) as seller_total_orders,
    coalesce(ss.seller_late_rate, 0.5) as seller_late_rate,
    coalesce(ss.seller_avg_review_score, 3.0) as seller_avg_review_score,
    coalesce(ss.seller_avg_delay, 0) as seller_avg_delay,
    
    -- TIME
    dd.month,
    dd.day_name
    
from fact_orders as fo

-- Dim Payment
join dim_payment as dp on fo.payment_type_key = dp.payment_type_key

-- Dim Date
join dim_date as dd on fo.purchase_date_key = dd.date_key

-- Item đầu tiên của mỗi đơn (để lấy product seller customer)
left join(
	select order_key,
		min(product_key) as product_key,
        min(seller_key) as seller_key,
        min(customer_key) as customer_key
	from fact_order_items 
    group by order_key
)as foi on fo.order_key = foi.order_key

left join dim_products as dpd on foi.product_key = dpd.product_key
left join dim_seller as ds on foi.seller_key = ds.seller_key 
left join dim_customer as dc on foi.customer_key = dc.customer_key

-- Seller reputation
left join tmp_seller_stats as ss on foi.seller_key = ss.seller_key

where fo.review_score is not null
	and fo.order_status = 'delivered';

DROP TEMPORARY TABLE IF EXISTS tmp_seller_stats;
