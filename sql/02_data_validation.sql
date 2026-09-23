/*
=========================================================
OLIST BRAZILIAN E-COMMERCE PROJECT
DATA VALIDATION

File: 02_data_validation.sql
Database: olist_ecommerce
PostgreSQL
=========================================================
*/


/*
=========================================================
1. CHECK CUSTOMERS
=========================================================
*/

-- Total rows vs unique customer IDs
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_customer_ids
FROM customers;


/*
=========================================================
2. CHECK ORDERS
=========================================================
*/

-- Total rows vs unique order IDs
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_order_ids
FROM orders;


/*
=========================================================
3. CHECK ORDER ITEMS
=========================================================
*/

-- Total rows vs unique orders
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders
FROM order_items;


/*
=========================================================
4. CHECK ORDER PAYMENTS
=========================================================
*/

-- Total payment rows vs unique orders
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders
FROM order_payments;


/*
=========================================================
5. CHECK ORDER REVIEWS
=========================================================
*/

-- Total reviews, unique review IDs and reviewed orders
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT review_id) AS unique_review_ids,
    COUNT(DISTINCT order_id) AS reviewed_orders
FROM order_reviews;


/*
=========================================================
6. CHECK PRODUCTS
=========================================================
*/

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_id) AS unique_product_ids
FROM products;


/*
=========================================================
7. CHECK SELLERS
=========================================================
*/

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT seller_id) AS unique_seller_ids
FROM sellers;


/*
=========================================================
8. CHECK PRODUCT CATEGORY TRANSLATION
=========================================================
*/

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_category_name) AS unique_categories
FROM product_category_translation;


/*
=========================================================
9. CHECK FOREIGN KEY:
ORDERS -> CUSTOMERS
=========================================================
*/

SELECT COUNT(*) AS unmatched_orders
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


/*
=========================================================
10. CHECK FOREIGN KEY:
ORDER ITEMS -> ORDERS
=========================================================
*/

SELECT COUNT(*) AS unmatched_order_items
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


/*
=========================================================
11. CHECK FOREIGN KEY:
ORDER ITEMS -> PRODUCTS
=========================================================
*/

SELECT COUNT(*) AS unmatched_products
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


/*
=========================================================
12. CHECK FOREIGN KEY:
ORDER ITEMS -> SELLERS
=========================================================
*/

SELECT COUNT(*) AS unmatched_sellers
FROM order_items oi
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;


/*
=========================================================
13. CHECK FOREIGN KEY:
PAYMENTS -> ORDERS
=========================================================
*/

SELECT COUNT(*) AS unmatched_payments
FROM order_payments op
LEFT JOIN orders o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL;


/*
=========================================================
14. CHECK FOREIGN KEY:
REVIEWS -> ORDERS
=========================================================
*/

SELECT COUNT(*) AS unmatched_reviews
FROM order_reviews r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


/*
=========================================================
15. CHECK REVIEW SCORES
=========================================================
*/

SELECT
    MIN(review_score) AS minimum_score,
    MAX(review_score) AS maximum_score
FROM order_reviews;


/*
=========================================================
16. CHECK ORDER DATES
=========================================================
*/

SELECT
    MIN(order_purchase_timestamp) AS earliest_order,
    MAX(order_purchase_timestamp) AS latest_order
FROM orders;


/*
=========================================================
17. CHECK NEGATIVE PRICES
=========================================================
*/

SELECT COUNT(*) AS negative_prices
FROM order_items
WHERE price < 0;


/*
=========================================================
18. CHECK NEGATIVE FREIGHT VALUES
=========================================================
*/

SELECT COUNT(*) AS negative_freight_values
FROM order_items
WHERE freight_value < 0;


/*
=========================================================
19. CHECK UNTRANSLATED PRODUCT CATEGORIES
=========================================================
*/

SELECT
    p.product_category_name,
    COUNT(*) AS number_of_products
FROM products p
LEFT JOIN product_category_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL
GROUP BY p.product_category_name
ORDER BY number_of_products DESC;


/*
=========================================================
END OF DATA VALIDATION
=========================================================
*/