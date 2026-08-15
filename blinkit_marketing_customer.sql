CREATE DATABASE IF NOT EXISTS blinkit_Marketing_Customer;
USE blinkit_Marketing_Customer;


## 1. DATA TYPE FIXES & SCHEMA DEFINITION

ALTER TABLE blinkit_customer_feedback
MODIFY COLUMN feedback_date DATE;

ALTER TABLE blinkit_customers
MODIFY COLUMN registration_date DATE;

ALTER TABLE blinkit_marketing_performance
MODIFY COLUMN date DATE;

ALTER TABLE blinkit_orders
MODIFY COLUMN order_date DATETIME,
MODIFY COLUMN promised_delivery_time DATETIME,
MODIFY COLUMN actual_delivery_time DATETIME;

## Primary Keys
ALTER TABLE blinkit_customers ADD PRIMARY KEY (customer_id);
ALTER TABLE blinkit_products ADD PRIMARY KEY (product_id);
ALTER TABLE blinkit_orders ADD PRIMARY KEY (order_id);
ALTER TABLE blinkit_customer_feedback ADD PRIMARY KEY (feedback_id);
ALTER TABLE blinkit_marketing_performance ADD PRIMARY KEY (campaign_id);

## Foreign Keys
ALTER TABLE blinkit_orders
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id) REFERENCES blinkit_customers(customer_id);

ALTER TABLE blinkit_order_items
ADD CONSTRAINT fk_items_order
FOREIGN KEY (order_id) REFERENCES blinkit_orders(order_id),
ADD CONSTRAINT fk_items_product
FOREIGN KEY (product_id) REFERENCES blinkit_products(product_id);

ALTER TABLE blinkit_customer_feedback
ADD CONSTRAINT fk_feedback_order
FOREIGN KEY (order_id) REFERENCES blinkit_orders(order_id);

## 2. MARKETING PERFORMANCE ANALYSIS

## Check Total Rows & Date Range
SELECT 
    COUNT(*) AS total_rows,
    MIN(date) AS start_date,
    MAX(date) AS end_date
FROM blinkit_marketing_performance;

## Check Unique Channels & Campaigns
SELECT 
    COUNT(DISTINCT channel) AS total_channels,
    COUNT(DISTINCT campaign_name) AS total_campaigns
FROM blinkit_marketing_performance;

## Quick Marketing Summary Statistics
SELECT 
    COUNT(*) AS total_records,
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(SUM(revenue_generated), 2) AS total_revenue,
    SUM(clicks) AS total_clicks,
    SUM(conversions) AS total_conversions,
    ROUND(AVG(roas), 2) AS avg_roas
FROM blinkit_marketing_performance;

## Channel Performance Analysis
SELECT
    channel,
    COUNT(DISTINCT campaign_id) AS total_campaigns,
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(SUM(revenue_generated), 2) AS total_revenue,
    SUM(clicks) AS total_clicks,
    SUM(conversions) AS total_conversions,
    ROUND(SUM(revenue_generated) / NULLIF(SUM(spend), 0), 2) AS overall_roas,
    ROUND((SUM(conversions) / NULLIF(SUM(clicks), 0)) * 100, 2) AS conversion_rate_pct
FROM blinkit_marketing_performance
GROUP BY channel
ORDER BY total_revenue DESC;

## Target Audience Performance
SELECT
    target_audience,
    ROUND(SUM(spend), 2) AS total_spend,
    ROUND(SUM(revenue_generated), 2) AS total_revenue,
    ROUND(AVG(roas), 2) AS avg_roas
FROM blinkit_marketing_performance
GROUP BY target_audience
ORDER BY total_revenue DESC;

## Top 5 Best Performing Campaigns (by ROAS)
SELECT 
    campaign_name,
    channel,
    target_audience,
    ROUND(spend, 2) AS spend,
    ROUND(revenue_generated, 2) AS revenue,
    roas
FROM blinkit_marketing_performance
ORDER BY roas DESC
LIMIT 5;

## Underperforming Campaigns (ROAS < 1.0)
SELECT 
    campaign_name,
    channel,
    target_audience,
    ROUND(spend, 2) AS spend,
    ROUND(revenue_generated, 2) AS revenue,
    roas
FROM blinkit_marketing_performance
WHERE roas < 1.0
ORDER BY spend DESC;

## Click-Through Rate (CTR) Analysis by Audience
SELECT 
    target_audience,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    ROUND((SUM(clicks) / NULLIF(SUM(impressions), 0)) * 100, 2) AS ctr_percentage
FROM blinkit_marketing_performance
GROUP BY target_audience
ORDER BY ctr_percentage DESC;

## Efficiency Metrics (CPC: Cost Per Click & CPA: Cost Per Acquisition)
SELECT 
    channel,
    SUM(clicks) AS total_clicks,
    SUM(conversions) AS total_conversions,
    ROUND(SUM(spend) / NULLIF(SUM(clicks), 0), 2) AS cpc,
    ROUND(SUM(spend) / NULLIF(SUM(conversions), 0), 2) AS cpa
FROM blinkit_marketing_performance
GROUP BY channel
ORDER BY cpa ASC;

## Monthly Marketing Trends (MoM)
SELECT 
    DATE_FORMAT(date, '%Y-%m') AS month_year,
    ROUND(SUM(spend), 2) AS monthly_spend,
    ROUND(SUM(revenue_generated), 2) AS monthly_revenue,
    SUM(conversions) AS total_conversions,
    ROUND(SUM(revenue_generated) / NULLIF(SUM(spend), 0), 2) AS monthly_roas
FROM blinkit_marketing_performance
GROUP BY DATE_FORMAT(date, '%Y-%m')
ORDER BY month_year ASC;

## 3. ORDERS & SALES OPERATIONS ANALYSIS
## Store-wise Total Revenue (Top 10)
SELECT 
    store_id,
    ROUND(SUM(order_total), 2) AS total_revenue,
    COUNT(order_id) AS total_orders
FROM blinkit_orders
GROUP BY store_id
ORDER BY total_revenue DESC
LIMIT 10;

## City (Area) -wise Revenue
SELECT 
    c.area,
    ROUND(SUM(o.order_total), 2) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM blinkit_orders o
JOIN blinkit_customers c ON o.customer_id = c.customer_id
GROUP BY c.area
ORDER BY total_revenue DESC;

## Monthly Revenue Trend
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(order_total), 2) AS monthly_revenue
FROM blinkit_orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY order_month DESC;

## Overall Average Order Value (AOV)
SELECT ROUND(SUM(order_total) / COUNT(order_id), 2) AS overall_aov
FROM blinkit_orders;

## City-wise Average Order Value (AOV)
SELECT 
    c.area,
    ROUND(SUM(o.order_total) / COUNT(o.order_id), 2) AS city_aov
FROM blinkit_orders o
JOIN blinkit_customers c ON o.customer_id = c.customer_id
GROUP BY c.area
ORDER BY city_aov DESC;

## Order Cancellation Rate (%)
SELECT 
    COUNT(*) AS total_orders,
    SUM(CASE WHEN delivery_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    ROUND((SUM(CASE WHEN delivery_status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS cancellation_rate_percentage
FROM blinkit_orders;

## Top Stores per City by Revenue (Window Function: DENSE_RANK)
WITH StoreRevenue AS (
    SELECT 
        c.area,
        o.store_id,
        ROUND(SUM(o.order_total), 2) AS total_revenue
    FROM blinkit_orders o
    JOIN blinkit_customers c ON o.customer_id = c.customer_id
    GROUP BY c.area, o.store_id
)
SELECT 
    area,
    store_id,
    total_revenue,
    DENSE_RANK() OVER (PARTITION BY area ORDER BY total_revenue DESC) AS store_rank_in_city
FROM StoreRevenue;

## Cumulative / Running Total Daily Revenue
SELECT 
    DATE(order_date) AS order_day,
    ROUND(SUM(order_total), 2) AS daily_revenue,
    ROUND(SUM(SUM(order_total)) OVER (ORDER BY DATE(order_date) ASC), 2) AS cumulative_running_total
FROM blinkit_orders
GROUP BY DATE(order_date)
ORDER BY order_day ASC;

## Month-over-Month (MoM) Revenue Growth (%)
WITH MonthlySales AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        ROUND(SUM(order_total), 2) AS current_month_revenue
    FROM blinkit_orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT 
    sales_month,
    current_month_revenue,
    LAG(current_month_revenue, 1) OVER (ORDER BY sales_month ASC) AS previous_month_revenue,
    ROUND(
        ((current_month_revenue - LAG(current_month_revenue, 1) OVER (ORDER BY sales_month ASC)) 
        / LAG(current_month_revenue, 1) OVER (ORDER BY sales_month ASC)) * 100, 
        2
    ) AS mom_growth_percentage
FROM MonthlySales;

## 4. CUSTOMER & FEEDBACK INSIGHTS

## High-AOV Customers (Above Overall Average)
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    ROUND(AVG(o.order_total), 2) AS customer_aov
FROM blinkit_customers c
JOIN blinkit_orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING AVG(o.order_total) > (SELECT AVG(order_total) FROM blinkit_orders)
ORDER BY customer_aov DESC;

## Repeat vs One-Time Customers
WITH CustomerOrderCounts AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS total_orders
    FROM blinkit_orders
    GROUP BY customer_id
)
SELECT 
    SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END) AS one_time_customers,
    COUNT(*) AS total_unique_customers,
    ROUND((SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS repeat_customer_percentage
FROM CustomerOrderCounts;

## Top 10 Customers by Total Spend
SELECT 
    c.customer_id,
    c.customer_name,
    c.area,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.order_total), 2) AS total_spend
FROM blinkit_customers c
JOIN blinkit_orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.area
ORDER BY total_spend DESC
LIMIT 10;

## Average Rating per Store
SELECT 
    o.store_id,
    COUNT(f.feedback_id) AS total_feedbacks_received,
    ROUND(AVG(f.rating), 2) AS avg_store_rating
FROM blinkit_orders o
JOIN blinkit_customer_feedback f ON o.order_id = f.order_id
GROUP BY o.store_id
ORDER BY avg_store_rating DESC;