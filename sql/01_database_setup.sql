/*
=========================================================
OLIST BRAZILIAN E-COMMERCE PROJECT
DATABASE SETUP
PostgreSQL

File: 01_database_setup.sql
=========================================================
*/


/*
=========================================================
1. CUSTOMERS
=========================================================
*/

CREATE TABLE customers (
    customer_id VARCHAR(32) PRIMARY KEY,
    customer_unique_id VARCHAR(32) NOT NULL,
    customer_zip_code_prefix INTEGER,
    customer_city VARCHAR(100),
    customer_state VARCHAR(2)
);


/*
=========================================================
2. ORDERS
=========================================================
*/

CREATE TABLE orders (
    order_id VARCHAR(32) PRIMARY KEY,
    customer_id VARCHAR(32) NOT NULL,
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);


/*
=========================================================
3. ORDER ITEMS
=========================================================
*/

CREATE TABLE order_items (
    order_id VARCHAR(32) NOT NULL,
    order_item_id INTEGER NOT NULL,
    product_id VARCHAR(32) NOT NULL,
    seller_id VARCHAR(32) NOT NULL,
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2),

    PRIMARY KEY (order_id, order_item_id),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);


/*
=========================================================
4. ORDER PAYMENTS
=========================================================
*/

CREATE TABLE order_payments (
    order_id VARCHAR(32) NOT NULL,
    payment_sequential INTEGER NOT NULL,
    payment_type VARCHAR(30),
    payment_installments INTEGER,
    payment_value NUMERIC(10,2),

    PRIMARY KEY (order_id, payment_sequential),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);


/*
=========================================================
5. PRODUCTS
=========================================================
*/

CREATE TABLE products (
    product_id VARCHAR(32) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_length INTEGER,
    product_description_length INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);


/*
=========================================================
6. SELLERS
=========================================================
*/

CREATE TABLE sellers (
    seller_id VARCHAR(32) PRIMARY KEY,
    seller_zip_code_prefix INTEGER,
    seller_city VARCHAR(100),
    seller_state VARCHAR(2)
);


/*
=========================================================
7. ORDER REVIEWS
=========================================================
*/

/*
NOTE:
review_id is NOT unique in the raw Olist data.
The same review_id can occur with different order_id values.

Therefore, the composite key
(review_id, order_id)
is used as the primary key.
*/

CREATE TABLE order_reviews (
    review_id VARCHAR(32) NOT NULL,
    order_id VARCHAR(32) NOT NULL,
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,

    PRIMARY KEY (review_id, order_id),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);


/*
=========================================================
8. GEOLOCATION
=========================================================
*/

/*
NOTE:
geolocation_zip_code_prefix is NOT unique.
Therefore, no primary key is defined here.
*/

CREATE TABLE geolocation (
    geolocation_zip_code_prefix INTEGER NOT NULL,
    geolocation_lat NUMERIC(10,6),
    geolocation_lng NUMERIC(10,6),
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(2)
);


/*
=========================================================
9. PRODUCT CATEGORY TRANSLATION
=========================================================
*/

CREATE TABLE product_category_translation (
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);


/*
=========================================================
10. ADD FOREIGN KEYS TO ORDER ITEMS
=========================================================
*/

/*
These constraints are added after products and sellers
have been created and populated.
*/

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_product
FOREIGN KEY (product_id)
REFERENCES products(product_id);


ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_seller
FOREIGN KEY (seller_id)
REFERENCES sellers(seller_id);


/*
=========================================================
DATABASE RELATIONSHIPS
=========================================================

customers
    |
    | customer_id
    v
orders
    |
    +--------------------> order_payments
    |
    +--------------------> order_reviews
    |
    v
order_items
    |
    +--------------------> products
    |
    +--------------------> sellers

products
    |
    | product_category_name
    v
product_category_translation

geolocation
    |
    +-- Used for geographic analysis
        through ZIP code prefixes

=========================================================
END OF DATABASE SETUP
=========================================================
*/