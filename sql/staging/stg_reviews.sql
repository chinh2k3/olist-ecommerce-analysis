use olist;
drop table if exists stg_review;

create table stg_review as
with deduped as(
	select
		trim(review_id) as review_id,
		trim(order_id) as order_id,
		case
			when review_score in (1, 2, 3, 4, 5) 
			then review_score 
			else null
		end as review_score,
		coalesce(lower(review_comment_title), 'Unknown') as review_comment_title,
        coalesce(lower(review_comment_message), 'Unknown') as review_comment_message,
        str_to_date(review_creation_date, '%Y-%m-%d %H:%i:%s') as review_creation_date,
        str_to_date(review_answer_timestamp, '%Y-%m-%d %H:%i:%s') as review_answer_timestamp,
        row_number() over(partition by review_id order by review_creation_date desc) as rn
	from olist_reviews
	where review_id is not null and order_id is not null
)
select * from deduped where rn = 1;