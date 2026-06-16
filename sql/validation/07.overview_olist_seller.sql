use olist;

-- 7.1 Thông tin cơ bản
SELECT COUNT(*) AS total_rows FROM olist_sellers;
SELECT * FROM olist_sellers LIMIT 5;

-- 7.2 Kiểm tra NULL
SELECT
    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS null_seller_id,
    SUM(CASE WHEN seller_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS null_zip,
    SUM(CASE WHEN seller_city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN seller_state IS NULL THEN 1 ELSE 0 END) AS null_state
FROM olist_sellers;

-- 7.3 Kiểm tra Duplicate
SELECT seller_id, COUNT(*) AS cnt
FROM olist_sellers
GROUP BY seller_id
HAVING cnt > 1;

-- 5.4 Distribution theo State
SELECT seller_state, COUNT(*) AS cnt
FROM olist_sellers
GROUP BY seller_state
ORDER BY cnt DESC;

-- 7.5 FK check với stg_order_items
SELECT COUNT(*) AS items_without_seller
FROM olist_order_items oi
LEFT JOIN olist_sellers s ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;