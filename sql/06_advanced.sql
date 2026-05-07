-- Theme 6: Advanced Patterns (Window Functions)
-- Window functions add aggregate-like columns without collapsing 
-- rows. Useful for ranking within groups, running totals, and 
-- comparing rows to their neighbors.
-- Skills: ROW_NUMBER, RANK, PARTITION BY, OVER clause.

-- Q1: Top 3 sellers in each state by revenue.
-- ROW_NUMBER() with PARTITION BY assigns 1, 2, 3 and so on within 
-- each state, ordered by revenue descending. Main query 
-- filters to the top 3.
-- Finding: Many smaller states are dominated by 1-2 sellers. 
-- Bahia's #1 seller alone earned R$222,776 (15× its #3), 
-- consistent with Theme 4's finding that BA's high per-seller 
-- average is driven by an outlier. In larger states like SP, 
-- the gap between #1 and #3 is much smaller — a more balanced 
-- supply base.
WITH seller_state_revenue AS (
    SELECT 
        s.seller_state,
        s.seller_id,
        ROUND(SUM(oi.price), 2) AS total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY s.seller_state 
            ORDER BY SUM(oi.price) DESC
        ) AS state_rank
    FROM sellers AS s
    JOIN order_items AS oi
      ON s.seller_id = oi.seller_id
    GROUP BY s.seller_state, s.seller_id
)
SELECT seller_state, seller_id, total_revenue, state_rank
FROM seller_state_revenue
WHERE state_rank <= 3
ORDER BY seller_state, state_rank;


-- Q2: Running total of orders by month.
-- SUM(COUNT(*)) OVER (ORDER BY month) gives a cumulative 
-- count alongside per-month volume. 
-- Finding: Olist hit operational maturity in late 2017
-- Cumulative orders went from 50k to 96k in just 8 months 
-- (Feb-Aug 2018), versus 16 months to reach the first 50k. 
-- The Feb-March 2018 delivery crisis (Theme 3) coincides with 
-- this growth phase so operations didn't scale with volume.
SELECT 
    strftime('%Y-%m', order_purchase_timestamp) AS month,
    COUNT(*) AS orders_this_month,
    SUM(COUNT(*)) OVER (
        ORDER BY strftime('%Y-%m', order_purchase_timestamp)
    ) AS cumulative_orders
FROM orders
WHERE order_status = 'delivered'
GROUP BY month
ORDER BY month;


-- Q3: Month-over-month change in order volume.
-- Uses LAG() to grab the previous month's value, then computes 
-- absolute and percentage change. CTE cleans up the monthly 
-- aggregation; main query layers on the comparison logic.
-- Finding: Cumulative growth (Q2) hides the real story — 
-- growth was front-loaded. After Black Friday Nov 2017 (+63%), 
-- the platform showed seasonal patterns (Dec dip -24%, Jan 
-- rebound +28%) but plateaued in mid-2018. From April 2018 
-- onward, monthly change bounces between -10% and +3%, with 
-- no sustained growth direction. Volume stabilized around 
-- 6,000-7,000 orders/month.
WITH monthly_orders AS (
    SELECT 
        strftime('%Y-%m', order_purchase_timestamp) AS month,
        COUNT(*) AS orders_this_month
    FROM orders
    WHERE order_status = 'delivered'
    GROUP BY month
)
SELECT 
    month,
    orders_this_month,
    LAG(orders_this_month) OVER (ORDER BY month) AS orders_prev_month,
    orders_this_month - LAG(orders_this_month) OVER (ORDER BY month) AS change,
    ROUND(
        100.0 * (orders_this_month - LAG(orders_this_month) OVER (ORDER BY month))
              / LAG(orders_this_month) OVER (ORDER BY month),
    2) AS pct_change
FROM monthly_orders
ORDER BY month;