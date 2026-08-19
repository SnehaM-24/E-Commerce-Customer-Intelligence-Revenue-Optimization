CREATE DATABASE ecommerce_analysis;
USE ecommerce_analysis;

CREATE TABLE ecommerce_customer_behavior_cleaned (
    customer_id VARCHAR(50),
    date DATE,
    product_category VARCHAR(100),
    total_amount DECIMAL(10,2),
    payment_method VARCHAR(50)
);

-- Verify imported data
SELECT *
FROM ecommerce_customer_behavior_cleaned
LIMIT 10;

SELECT COUNT(*) AS total_records
FROM ecommerce_customer_behavior_cleaned;

-- Overall Sales KPIs
SELECT
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(total_amount) AS total_sales,
    AVG(total_amount) AS average_order_value
FROM ecommerce_customer_behavior_cleaned;

-- Sales by Category
SELECT
    product_category,
    COUNT(*) AS transactions,
    SUM(total_amount) AS total_sales,
    AVG(total_amount) AS average_order_value
FROM ecommerce_customer_behavior_cleaned
GROUP BY product_category
ORDER BY total_sales DESC;

-- Top 10 Customers
SELECT
    customer_id,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_spend
FROM ecommerce_customer_behavior_cleaned
GROUP BY customer_id
ORDER BY total_spend DESC
LIMIT 10;

-- Monthly Sales Analysis
SELECT
    YEAR(date) AS year,
    MONTH(date) AS month,
    SUM(total_amount) AS total_sales
FROM ecommerce_customer_behavior_cleaned
GROUP BY
    YEAR(date),
    MONTH(date)
ORDER BY
    year,
    month;
    
-- Payment Method Performance
SELECT
    payment_method,
    COUNT(*) AS transactions,
    SUM(total_amount) AS total_sales
FROM ecommerce_customer_behavior_cleaned
GROUP BY payment_method
ORDER BY total_sales DESC;

-- Customer Ranking — Window Function
WITH customer_sales AS (
    SELECT
        customer_id,
        SUM(total_amount) AS total_spend
    FROM ecommerce_customer_behavior_cleaned
    GROUP BY customer_id
)
SELECT
    customer_id,
    total_spend,
    RANK() OVER (ORDER BY total_spend DESC) AS customer_rank
FROM customer_sales;

-- Category Revenue Contribution
WITH category_sales AS (
    SELECT
        product_category,
        SUM(total_amount) AS total_sales
    FROM ecommerce_customer_behavior_cleaned
    GROUP BY product_category
)
SELECT
    product_category,
    total_sales,
    ROUND(
        total_sales * 100.0 /
        SUM(total_sales) OVER (),
        2
    ) AS revenue_percentage
FROM category_sales
ORDER BY total_sales DESC;

-- -- RFM Customer Segment Analysis
SELECT
    customer_segment,
    COUNT(*) AS customers,
    SUM(monetary) AS total_revenue,
    AVG(monetary) AS average_customer_value
FROM customer_rfm_analysis
GROUP BY customer_segment
ORDER BY total_revenue DESC;

-- Identify At-Risk Customers
SELECT
    customer_id,
    recency,
    frequency,
    monetary,
    customer_segment
FROM customer_rfm_analysis
WHERE customer_segment = 'At Risk'
ORDER BY monetary DESC;

-- Customer Revenue Distribution
SELECT
    customer_id,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS avg_order_value
FROM ecommerce_customer_behavior_cleaned
GROUP BY customer_id
ORDER BY total_revenue DESC;

-- Repeat Customers
SELECT
    customer_id,
    COUNT(*) AS total_orders
FROM ecommerce_customer_behavior_cleaned
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY total_orders DESC;