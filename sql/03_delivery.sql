-- Theme 3: Delivery Performance
-- Operational analysis of how orders move through the system.
-- Skills: Date math (JULIANDAY), CASE expressions, JOINs, 
-- handling NULLs, working with multi-table delivery data.

-- Q1: How long does delivery take, on average and at worst?
-- Uses JULIANDAY date math to compute days between purchase 
-- and delivery for completed orders.
-- Finding: 12.6 days average, with a max of 209.6 days. The 
-- mean masks a long right tail — a small number of catastrophic 
-- delays pull the average up.
SELECT ROUND(AVG(JULIANDAY(order_delivered_customer_date) 
                 - JULIANDAY(order_purchase_timestamp)), 1) AS avg_days,
       ROUND(MAX(JULIANDAY(order_delivered_customer_date) 
                 - JULIANDAY(order_purchase_timestamp)), 1) AS max_days
FROM orders
WHERE order_status = 'delivered';

-- Q2: How many orders were delivered late vs on time?
-- Uses CASE to derive a status label by comparing actual vs 
-- estimated delivery dates.
-- Finding: 88,652 on-time (91.9%) vs 7,826 late (8.1%). 
-- One in twelve orders misses its promised date — acceptable 
-- but not strong. Late orders typically drive most support load.
SELECT 
    CASE 
        WHEN order_delivered_customer_date > order_estimated_delivery_date 
        THEN 'late'
        ELSE 'on_time'
    END AS delivery_status,
    COUNT(*) AS num_orders
FROM orders
WHERE order_status = 'delivered'
GROUP BY delivery_status;

-- Q3: Where are deliveries late most often?
-- JOIN orders to customers to get state, then compute late 
-- percentage per state.
-- Pattern: SUM(CASE WHEN ... THEN 1 ELSE 0 END) / COUNT(*) 
-- is a common SQL idiom for computing a percentage.
-- Finding: Northeast Brazil dominates the worst performers — 
-- AL (24%), MA (20%), PI (16%) are all 2-3× the national rate.
-- Rio de Janeiro is a notable outlier among high-volume states 
-- at 13.5% late — its 1,664 absolute late orders exceed the 
-- entire Northeast combined.
SELECT 
    c.customer_state,
    COUNT(*) AS total_orders,
    SUM(CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date 
        THEN 1 ELSE 0 
    END) AS late_orders,
    ROUND(
        100.0 * SUM(CASE 
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date 
            THEN 1 ELSE 0 
        END) / COUNT(*), 
    2) AS late_pct
FROM orders AS o
JOIN customers AS c
  ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY late_pct DESC
LIMIT 10;

-- Q4: Does delivery performance vary over time?
-- Slice the late % by year-month using strftime to extract the 
-- month label from the timestamp.
-- Finding: 8% national average masks substantial volatility. 
-- Stable 3-5% through most of 2017. Spikes around Black Friday 
-- 2017 (14.3% late on 7,289 orders) and a sustained crisis 
-- in Feb-March 2018 (16% then 21% late) before recovering. 
-- Suggests operations didn't scale smoothly with volume.
SELECT 
    strftime('%Y-%m', order_purchase_timestamp) AS month,
    COUNT(*) AS total_orders,
    ROUND(
        100.0 * SUM(CASE 
            WHEN order_delivered_customer_date > order_estimated_delivery_date 
            THEN 1 ELSE 0 
        END) / COUNT(*), 
    2) AS late_pct
FROM orders
WHERE order_status = 'delivered'
GROUP BY month
ORDER BY month;