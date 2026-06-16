use olist;
drop table if exists stg_payment;

create table stg_payment as
with deduped as(
	select
		trim(order_id) as order_id,
		payment_sequential,
		case
			when payment_type in ('credit_card','debit_card','voucher','boleto','not_defined')
			then payment_type
			else 'Unknown'
		end as payment_type,
        payment_installments,
        payment_value,
        row_number() over (partition by order_id, payment_sequential order by payment_value desc) as rn
	from olist_order_payments
	where order_id is not null 
		and payment_sequential is not null
		and payment_value >= 0
        and payment_installments >= 1
)
select * from deduped where rn = 1;


