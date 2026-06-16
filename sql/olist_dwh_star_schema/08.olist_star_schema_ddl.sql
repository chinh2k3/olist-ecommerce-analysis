create database if not exists olist_dwh
  character set utf8mb4
  collate utf8mb4_unicode_ci;

use olist_dwh;

-- DIMENSION TABLE

-- dim_payment
drop table if exists dim_payment;
create table dim_payment(
	payment_type_key  int          not null auto_increment,
    payment_type      VARCHAR(50)  not null,
    primary key (payment_type_key),
    unique key uq_payment_type (payment_type)
) engine = InnoDB;

INSERT INTO dim_payment (payment_type) VALUES ('credit_card'), ('boleto'), ('voucher'), ('debit_card'), ('not_defined');

-- dim_date
drop table if exists dim_date; 
create table dim_date(
	date_key     int         not null,   -- YYYYMMDD
    full_date    date        not null,
    day          tinyint     not null,
    month        tinyint     not null,
    month_name   varchar(10) not null,
    quarter      tinyint     not null,
    year         smallint    not null,
    week_of_year tinyint     not null,
    day_of_week  tinyint     not null,   -- 0=Monday ... 6=Sunday
    day_name     varchar(10) not null,
    is_weekend   boolean     not null default false,
    primary key (date_key)
) engine=InnoDB;

-- dim_customer
drop table if exists dim_customer;
create table dim_customer(
	customer_key        int not null auto_increment,
    customer_id         varchar(50) not null,   
    customer_unique_id  varchar(50) not null,  
    customer_zip_code   varchar(50),
    customer_city       varchar(100),
    customer_state      char(2),
	customer_lat        float null,
    customer_lng        float null,
    primary key (customer_key),
    unique key uq_customer_id (customer_id)
)engine=InnoDB;

-- dim_seller

drop table if exists dim_seller;
create table dim_seller(
	seller_key      int         not null auto_increment,
    seller_id       varchar(50) not null,
    seller_zip_code varchar(10),
    seller_city     varchar(100),
    seller_state    char(2),
	seller_lat      float null,
    seller_lng      float null,
    primary key (seller_key),
    unique key uq_seller_id (seller_id)
)engine = InnoDB;

-- dim_products

drop table if exists dim_products;
create table dim_products(
	product_key                int         not null auto_increment,
    product_id                 varchar(50) not null,
    category_name_portuguese   varchar(100),
    category_name_english      varchar(100),
    product_name_length        int,
    product_description_length int,
    product_photos_qty         int,
    product_weight_g           float,
    product_length_cm          float,
    product_height_cm          float,
    product_width_cm           float,
    primary key (product_key),
    unique key uq_product_id (product_id)
) engine = InnoDB;

-- fact table

-- fact table order 
-- Grain: 1 row per order
-- Source: olist_orders + olist_order_payments + olist_order_reviews
drop table if exists fact_orders;
create table fact_orders (
    order_key  int not null auto_increment,
    order_id   varchar(50) not null,

    -- Foreign Keys
    customer_key       int not null,
    purchase_date_key  int not null, 
    approved_date_key  int,
    delivered_carrier_date_key int,
    delivered_customer_date_key int,
    estimated_delivery_date_key int,

    -- Order Status
    order_status varchar(20), -- delivered, shipped, canceled…

    -- Payment Metrics (aggregated per order)
    payment_type_key      int not null, -- dominant payment type
    payment_installments  int,
    payment_value         decimal(10,2),

    -- Review Metrics
    review_score             tinyint, -- 1–5
    review_answer_delay_days int,  -- days between purchase and review

    -- Delivery Metrics
    delivery_delay_days      int, -- actual vs estimated (negative = early)
    carrier_to_customer_days int, -- days from ship to delivery

    -- Measures
    total_items          int,
    total_freight_value  decimal(10,2),
    total_order_value    decimal(10,2), -- payment_value

    primary key (order_key),
    unique key uq_order_id (order_id),
    constraint fk_fo_customer foreign key (customer_key) references dim_customer(customer_key),
    constraint fk_fo_purchase_date foreign key (purchase_date_key) references dim_date(date_key),
    constraint fk_fo_approved_date foreign key (approved_date_key) references dim_date(date_key),
    constraint fk_fo_delivered_carried_date foreign key (delivered_carrier_date_key) references dim_date(date_key),
    constraint fk_fo_delivered_date foreign key (delivered_customer_date_key) references dim_date(date_key),
    constraint fk_fo_est_date foreign key (estimated_delivery_date_key) references dim_date(date_key),
    constraint fk_fo_payment_type foreign key (payment_type_key) references dim_payment(payment_type_key)
) engine=InnoDB;


-- fact_order_items
-- Grain: 1 row per order-item
-- Source: olist_order_items + joined to orders, products, sellers
DROP TABLE IF EXISTS fact_order_items;
CREATE TABLE fact_order_items (
    order_item_key int         not null auto_increment,
    order_id       varchar(50) not null,
    order_item_id  tinyint     not null,   -- item sequence within order

    -- Foreign Keys
    order_key         int  not null,   -- FK → fact_orders
    product_key       int  not null,
    seller_key        int  not null,
    customer_key      int  not null,
    purchase_date_key int  not null,

    -- Measures
    price            decimal(10,2),
    freight_value    decimal(10,2),
    total_item_value decimal(10,2),  -- price + freight_value

    -- Shipping dates (denormalized for convenience)
    shipping_limit_date     datetime,

    primary key (order_item_key),
    constraint fk_foi_order foreign key (order_key) references fact_orders(order_key),
    constraint fk_foi_products foreign key (product_key) references dim_products(product_key),
    constraint fk_foi_seller foreign key (seller_key) references dim_seller(seller_key),
    constraint fk_foi_customer foreign key (customer_key) references dim_customer(customer_key),
    constraint fk_foi_date foreign key (purchase_date_key) references dim_date(date_key)
) engine=InnoDB;

-- INDEXES for query performance

/*create index idx_fo_purchase_date on fact_orders(purchase_date_key);
create index idx_fo_customer      on fact_orders(customer_key);
create index idx_fo_status        on fact_orders(order_status);

create index idx_foi_order        on fact_order_items(order_key);
create index idx_foi_product      on fact_order_items(product_key);
create index idx_foi_seller       on fact_order_items(seller_key);
create index idx_foi_date         on fact_order_items(purchase_date_key);*/

