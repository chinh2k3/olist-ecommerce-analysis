use olist;
drop table if exists stg_geolocation;

create table stg_geolocation as
select
    geolocation_zip_code_prefix as zip_code,
    avg(geolocation_lat) as lat,
    avg(geolocation_lng) as lng
from olist_geolocation
group by geolocation_zip_code_prefix;


