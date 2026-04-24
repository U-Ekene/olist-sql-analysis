-- Theme 1: Dataset Exploration
-- Getting a feel for the shape and contents of the Olist dataset.
-- Skills: SELECT, WHERE, ORDER BY, LIMIT, DISTINCT

-- Q1: What does an order look like? Peek at a few rows.
SELECT * FROM orders LIMIT 5;

-- Q2: What order statuses exist?
-- Confirms the valid values for filtering.
-- Result: 8 statuses — delivered, invoiced, shipped, processing,
-- unavailable, canceled, created, approved
SELECT DISTINCT order_status FROM orders;

-- Q3: What's the date range of the data?
SELECT MIN(order_purchase_timestamp) AS earliest_order,
       MAX(order_purchase_timestamp) AS latest_order
FROM orders;

-- Q4: How many orders in total?
SELECT COUNT(*) AS total_orders
FROM orders;

-- Q5: How many orders per status?
-- Gives a breakdown of order outcomes. 
-- Finding: ~97% of orders reach 'delivered' (96,478 of 99,441).
-- Transient states like 'approved' and 'created' have very few 
-- rows — they're snapshots of orders in motion at export time.
SELECT order_status, COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- Q6a: How many unique customer_ids are there?
SELECT COUNT(DISTINCT customer_id) AS unique_customer_ids
FROM customers;

-- Q6b: How many unique people (customer_unique_id)?
-- Note: Olist assigns a new customer_id per order, so multiple 
-- customer_ids can belong to the same person. customer_unique_id 
-- is the real person-level identifier.
SELECT COUNT(DISTINCT customer_unique_id) AS unique_people
FROM customers;

-- Q7: How many orders are in each city for customers in the state of São Paulo (SP)?
-- Limited to Top 10 cities by order count in São Paulo state.
-- Shows how concentrated orders are within a single state
SELECT customer_city, COUNT(*) AS total_sp_orders
FROM customers
WHERE customer_state = 'SP'
GROUP BY customer_city
ORDER BY total_sp_orders DESC
LIMIT 10;

-- Q8: Top 10 states by total order count across the country.
-- Complements Q7 — how concentrated is Olist's business at the 
-- national level?
SELECT customer_state, COUNT(*) AS total_state_orders
FROM customers
GROUP BY customer_state
ORDER BY total_state_orders DESC
LIMIT 10;