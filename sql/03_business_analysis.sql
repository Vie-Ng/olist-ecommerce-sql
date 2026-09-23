/*
=========================================================
OLIST BRAZILIAN E-COMMERCE PROJECT
BUSINESS ANALYSIS
PostgreSQL

File: 03_business_analysis.sql
=========================================================
*/


-- Analysis 1: Total Revenue
-- Business question: What is the total revenue generated from product sales?

SELECT
    SUM(price) AS total_revenue
FROM order_items;


-- Analysis 2: Total Orders
-- Business question: How many orders were placed in total?

SELECT
    COUNT(order_id) AS total_orders
FROM orders;


-- Analysis 3: Unique Customers
-- Business question: How many unique customers have placed orders?

SELECT
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers;


-- Analysis 4: Repeat Customers
-- Business question: Which customers have placed more than one order?

SELECT
    customer_unique_id,
    COUNT(customer_id) AS order_count
FROM customers
GROUP BY customer_unique_id
HAVING COUNT(customer_id) > 1;


-- Analysis 5: Number of Repeat Customers
-- Business question: How many customers have placed more than one order?

SELECT
    COUNT(*) AS repeat_customers
FROM (
    SELECT
        customer_unique_id
    FROM customers
    GROUP BY customer_unique_id
    HAVING COUNT(customer_id) > 1
) AS repeat_customers_list;


-- Analysis 6: Top 10 Products by Revenue
-- Business question: Which products generated the most revenue?

SELECT
    product_id,
    SUM(price) AS total_revenue
FROM order_items
GROUP BY product_id
ORDER BY total_revenue DESC
LIMIT 10;


-- Analysis 7: Revenue by Product Category
-- Business question: Which product categories generate the most revenue?

SELECT
    product_category_name,
    SUM(price) AS total_revenue
FROM order_items
JOIN products
    ON order_items.product_id = products.product_id
GROUP BY product_category_name
ORDER BY total_revenue DESC;


-- Analysis 8: Monthly Revenue Trend
-- Business question: How did revenue change over time?

SELECT
    DATE_TRUNC('month', orders.order_purchase_timestamp) AS order_month,
    SUM(order_items.price) AS monthly_revenue
FROM order_items
JOIN orders
    ON orders.order_id = order_items.order_id
GROUP BY DATE_TRUNC('month', orders.order_purchase_timestamp)
ORDER BY order_month;


-- Analysis 9: Average Order Value
-- Business question: What is the average revenue generated per order?

SELECT
    SUM(price) / COUNT(DISTINCT(order_id)) AS average_order_value
FROM order_items;


-- Analysis 10: One-time vs Repeat Customers
-- Business question: What proportion of customers are one-time versus repeat customers?

SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time customer'
        ELSE 'Repeat customer'
    END AS customer_type,
    COUNT(*) AS number_of_customers
FROM (
    SELECT
        customer_unique_id,
        COUNT(*) AS order_count
    FROM customers
    GROUP BY customer_unique_id
) AS customer_orders
GROUP BY customer_type;


-- Analysis 11: Revenue by Customer Type
-- Business question: How much revenue comes from one-time versus repeat customers?

SELECT
    CASE
        WHEN co.order_count = 1 THEN 'One-time customer'
        ELSE 'Repeat customer'
    END AS customer_type,
    SUM(oi.price) AS total_revenue
FROM (
    SELECT
        customer_unique_id,
        COUNT(*) AS order_count
    FROM customers
    GROUP BY customer_unique_id
) AS co
JOIN customers c
    ON co.customer_unique_id = c.customer_unique_id
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY customer_type;


-- Analysis 12: Revenue by Customer State
-- Business question: Which customer states generate the most revenue?

SELECT
    customer_state,
    SUM(price) AS total_revenue
FROM customers
JOIN orders
    ON customers.customer_id = orders.customer_id
JOIN order_items
    ON orders.order_id = order_items.order_id
GROUP BY customer_state
ORDER BY total_revenue DESC;


-- Analysis 13: Top 10 Sellers by Revenue
-- Business question: Which sellers generate the most revenue?

SELECT
    seller_id,
    SUM(price) AS total_revenue
FROM order_items
GROUP BY seller_id
ORDER BY total_revenue DESC
LIMIT 10;


-- Analysis 14: High-Volume but Low-Revenue Sellers
-- Business question: Which sellers have many orders but relatively low revenue?

SELECT
    seller_id,
    COUNT(DISTINCT order_id) AS number_of_orders,
    SUM(price) AS total_revenue
FROM order_items
GROUP BY seller_id
HAVING COUNT(DISTINCT order_id) >= 100
   AND SUM(price) < 10000
ORDER BY total_revenue ASC;


-- Analysis 15: Category Revenue and Average Order Value
-- Business question: Which product categories generate high revenue and what is their average order value?

SELECT
    p.product_category_name,
    SUM(oi.price) AS total_revenue,
    SUM(oi.price) / COUNT(DISTINCT(order_id)) AS average_order_value
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC;


-- Analysis 16: On-time vs Late Delivery
-- Business question: How many orders were delivered on time versus late?

SELECT
    CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On time'
    END AS delivery_status,
    COUNT(*) AS number_of_orders
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;


-- Analysis 17: Average Delivery Time
-- Business question: What is the average delivery time in days?

SELECT
    AVG(
        EXTRACT(
            EPOCH FROM (
                order_delivered_customer_date - order_purchase_timestamp
            )
        ) / 86400
    ) AS average_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL;


-- Analysis 18: Late Delivery by Customer State
-- Business question: Which customer states have the most late deliveries?

SELECT
    c.customer_state,
    COUNT(*) AS late_orders
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_delivered_customer_date > o.order_estimated_delivery_date
GROUP BY c.customer_state
ORDER BY late_orders DESC;


-- Analysis 19: Average Review Score by Product Category
-- Business question: Which product categories have higher or lower average review scores?

WITH order_category AS (
    SELECT DISTINCT
        o.order_id,
        p.product_category_name
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
)

SELECT
    oc.product_category_name,
    ROUND(AVG(r.review_score), 2) AS average_review_score
FROM order_category oc
JOIN order_reviews r
    ON oc.order_id = r.order_id
GROUP BY oc.product_category_name
ORDER BY average_review_score DESC;


-- Analysis 20: Review Score vs Delivery Performance
-- Business question: Is late delivery associated with lower review scores?

SELECT
    CASE
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 'Late'
        ELSE 'On time'
    END AS delivery_status,
    ROUND(AVG(r.review_score), 2) AS average_review_score,
    COUNT(DISTINCT o.order_id) AS number_of_orders
FROM orders o
JOIN order_reviews r
    ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status
ORDER BY average_review_score DESC;


-- Analysis 21: Top 3 Products by Revenue within Each Category
-- Business question: What are the top 3 revenue-generating products within each category?

WITH product_revenue AS (
    SELECT
        p.product_category_name,
        oi.product_id,
        SUM(oi.price) AS total_revenue
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY
        p.product_category_name,
        oi.product_id
),

ranked_products AS (
    SELECT
        product_category_name,
        product_id,
        total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY product_category_name
            ORDER BY total_revenue DESC
        ) AS product_rank
    FROM product_revenue
)

SELECT
    product_category_name,
    product_id,
    total_revenue,
    product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY
    product_category_name,
    product_rank;


-- Analysis 22: Revenue Contribution by Product Category
-- Business question: What percentage of total revenue does each product category contribute?

WITH category_revenue AS (
    SELECT
        p.product_category_name,
        SUM(oi.price) AS total_revenue
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY p.product_category_name
)

SELECT
    product_category_name,
    total_revenue,
    ROUND(
        total_revenue / SUM(total_revenue) OVER () * 100,
        2
    ) AS revenue_contribution_pct
FROM category_revenue
ORDER BY total_revenue DESC;