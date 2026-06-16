use olist;

-- 8.1 Thông tin cơ bản
SELECT COUNT(*) AS total_rows FROM olist_order_payments;
SELECT * FROM olist_order_payments LIMIT 5;

-- 8.2 Kiểm tra NULL
SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS null_payment_type,
    SUM(CASE WHEN payment_installments IS NULL THEN 1 ELSE 0 END) AS null_installments,
    SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS null_payment_value
FROM olist_order_payments;

-- 8.3 Distribution payment_type
SELECT payment_type, COUNT(*) AS cnt
FROM olist_order_payments
GROUP BY payment_type
ORDER BY cnt DESC;

-- 8.4 Range installments & payment_value
SELECT
    MIN(payment_installments) AS min_installments,
    MAX(payment_installments) AS max_installments,
    AVG(payment_installments) AS avg_installments,
    MIN(payment_value) AS min_value,
    MAX(payment_value) AS max_value,
    AVG(payment_value) AS avg_value
FROM olist_order_payments;

-- 8.5 FK check với stg_orders
SELECT COUNT(*) AS payments_without_order
FROM olist_order_payments p
LEFT JOIN olist_orders o ON p.order_id = o.order_id
WHERE o.order_id IS NULL;