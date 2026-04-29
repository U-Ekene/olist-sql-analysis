-- Theme 2: Customer & Order Patterns
-- Looks at how customers behave and what orders look like 
-- beyond basic shape.
-- Skills: Aggregations (COUNT, SUM, AVG), HAVING, subqueries

-- Q1: Top 10 customers by order count.
-- Looks at the "long tail" of repeat buyers — does anyone 
-- order frequently?
-- Finding: One outlier with 17 orders. Top 10 ranges from 17 
-- down to 6. Even repeat buyers mostly cap at single digits.
SELECT customer_unique_id, COUNT(*) AS order_count
FROM customers
GROUP BY customer_unique_id
ORDER BY order_count DESC
LIMIT 10;

-- Q2: Distribution of customers by order count.
-- How many customers ordered exactly 1 time, 2 times, 3 times, etc?
-- Subquery pattern: compute orders-per-customer first, then 
-- count customers within each bucket.
-- Finding: 93,099 of 96,096 customers (~96.9%) ordered exactly 
-- once. Dropoff to 2,745 at 2 orders, then near-zero. Olist 
-- functions as a one-and-done marketplace, not a loyalty platform.
SELECT order_count, COUNT(*) AS num_customers
FROM (
    SELECT customer_unique_id, COUNT(*) AS order_count
    FROM customers
    GROUP BY customer_unique_id
) AS customer_orders
GROUP BY order_count
ORDER BY order_count;

-- Q3: What's the price spread across all order items?
-- Quick sense of how much variation exists in the catalog.
-- Finding: R$0.85 to R$6,735, average R$120.65. Wide spread 
-- suggests a right-skewed distribution (many cheap items, 
-- few expensive ones pulling the average up).
SELECT MIN(price) AS smallest_price,
       MAX(price) AS largest_price,
       ROUND(AVG(price), 2) AS average_price
FROM order_items;

-- Q4: Which states have more than 50 repeat customers?
-- Repeat customer = someone who placed more than 1 order.
-- Combines a subquery (to identify repeaters) with HAVING (to 
-- filter the resulting state aggregates).
-- Finding: 7 states pass the threshold. The ranking mirrors total 
-- order volume as SP has the most repeaters (1,296), but at ~3% 
-- of SP's total customers, the repeat rate is no higher than the 
-- national ~3.4%. Loyalty follows volume, not geography.
SELECT customer_state, COUNT(*) AS repeat_customers
FROM (
    SELECT customer_unique_id, customer_state, COUNT(*) AS order_count
    FROM customers 
    GROUP BY customer_unique_id, customer_state
    HAVING COUNT(*) > 1
) AS repeaters
GROUP BY customer_state
HAVING COUNT(*) > 50
ORDER BY repeat_customers DESC;

-- Q5: Average order value by customer state.
-- First multi-table JOIN: combines order_items (prices), 
-- orders (customer link), and customers (state).
-- Builds order totals first, then averages per state.
-- Finding: Top 10 states by avg order value are all small/remote 
-- states (PB, AP, AC, AL, RO, PA, TO...). SP/RJ/MG don't make the 
-- list so high-volume urban states have lower average order values.
SELECT c.customer_state, ROUND(AVG(order_total), 2) AS avg_order_value
FROM (
    SELECT oi.order_id,
           o.customer_id,
           SUM(oi.price) AS order_total
    FROM order_items AS oi
    JOIN orders AS o
    ON oi.order_id = o.order_id
    GROUP BY oi.order_id, o.customer_id
) AS order_totals
JOIN customers AS c
ON order_totals.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY avg_order_value DESC
LIMIT 10;