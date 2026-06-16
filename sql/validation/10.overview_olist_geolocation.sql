use olist;

-- 10.1 Thông tin cơ bản
SELECT COUNT(*) AS total_rows FROM olist_geolocation;
SELECT * FROM olist_geolocation LIMIT 5;

-- 10.2 Kiểm tra NULL
SELECT
    SUM(CASE WHEN geolocation_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS null_zip,
    SUM(CASE WHEN geolocation_lat IS NULL THEN 1 ELSE 0 END) AS null_lat,
    SUM(CASE WHEN geolocation_lng IS NULL THEN 1 ELSE 0 END) AS null_lng,
    SUM(CASE WHEN geolocation_city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN geolocation_state IS NULL THEN 1 ELSE 0 END) AS null_state
FROM olist_geolocation;

-- 10.3 Kiểm tra Duplicate zip
SELECT geolocation_zip_code_prefix, COUNT(*) AS cnt
FROM olist_geolocation
GROUP BY geolocation_zip_code_prefix
HAVING cnt > 1
ORDER BY cnt desc
LIMIT 10;

-- 10.4 Range lat/lng (kiểm tra tọa độ hợp lệ Brazil)
SELECT
    MIN(geolocation_lat) AS min_lat,
    MAX(geolocation_lat) AS max_lat,
    MIN(geolocation_lng) AS min_lng,
    MAX(geolocation_lng) AS max_lng
FROM olist_geolocation;