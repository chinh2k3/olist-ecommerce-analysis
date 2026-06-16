use olist;

-- 9.1 Thông tin cơ bản
SELECT COUNT(*) AS total_rows FROM olist_reviews;
SELECT * FROM olist_reviews LIMIT 5;

-- 9.2 Kiểm tra NULL
SELECT
    SUM(CASE WHEN review_id IS NULL THEN 1 ELSE 0 END) AS null_review_id,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS null_score,
    SUM(CASE WHEN review_comment_message IS NULL THEN 1 ELSE 0 END) AS null_comment
FROM olist_reviews;

-- 9.3 Distribution review_score
SELECT review_score, COUNT(*) AS cnt
FROM olist_reviews
GROUP BY review_score
ORDER BY review_score;

-- 9.4 Tỷ lệ có comment
SELECT
    COUNT(*) AS total_reviews,
    SUM(CASE WHEN review_comment_message IS NOT NULL THEN 1 ELSE 0 END) AS has_comment,
    ROUND(SUM(CASE WHEN review_comment_message IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS comment_rate
FROM olist_reviews;

-- 9.5 FK check với stg_orders
SELECT COUNT(*) AS reviews_without_order
FROM olist_reviews r
LEFT JOIN olist_orders o ON r.order_id = o.order_id
WHERE o.order_id IS NULL;