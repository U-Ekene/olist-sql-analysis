-- Theme 4: Seller Analysis
-- Examining the supply side of the marketplace — who sells, 
-- how revenue is distributed, and where performance varies.
-- Skills: multi-table JOINs, subqueries combined with joins, 
-- aggregations on joined data.

-- Q1: Top 10 sellers by total revenue.
-- Captures total revenue and items_sold per seller.
-- Finding: Top earner R$229k from 1,156 items. Two distinct 
-- business models visible in the top 10: high-volume sellers 
-- (1,000-2,000 items, ~R$100/item) and premium sellers 
-- (~400 items, ~R$500/item). Top revenue ratio is only 1.7x 
-- (#1 vs #10), so revenue is fairly flat across top performers.
SELECT seller_id, 
       ROUND(SUM(price), 2) AS total_revenue,
       COUNT(*) AS items_sold
FROM order_items
GROUP BY seller_id
ORDER BY total_revenue DESC
LIMIT 10;

-- Q2: Marketplace-wide seller revenue distribution.
-- Summary stats across all sellers: count, total revenue, mean, 
-- min, max. Reveals concentration of revenue.
-- Finding: 3,095 sellers, R$13.6M total revenue, R$4,391 mean. 
-- But the range is R$3.50 to R$229,473 — a 65,500x spread. 
-- Top 10 sellers (0.3% of total) generate ~13% of revenue. 
-- Classic long-tail / power-law distribution.
SELECT 
    COUNT(*) AS total_sellers,
    ROUND(SUM(seller_revenue), 2) AS total_revenue,
    ROUND(AVG(seller_revenue), 2) AS avg_seller_revenue,
    ROUND(MIN(seller_revenue), 2) AS min_seller_revenue,
    ROUND(MAX(seller_revenue), 2) AS max_seller_revenue
FROM (
    SELECT seller_id, SUM(price) AS seller_revenue
    FROM order_items
    GROUP BY seller_id
) AS seller_totals;

-- Q3: Sellers earning above the mean revenue.
-- Subquery in HAVING — filters sellers whose total revenue 
-- exceeds the average computed across all sellers.
-- Finding: 628 of 3,095 sellers (~20%) are above average. 
-- The 80/20 split confirms a strong right-skewed distribution: 
-- a few top performers drag the mean up, leaving most sellers 
-- below it.
SELECT seller_id, ROUND(SUM(price), 2) AS revenue
FROM order_items
GROUP BY seller_id
HAVING SUM(price) > (
    SELECT AVG(seller_revenue)
    FROM (
        SELECT SUM(price) AS seller_revenue
        FROM order_items
        GROUP BY seller_id
    )
)
ORDER BY revenue DESC;

-- Q4: Top 10 sellers by revenue, with average review score.
-- Combines order_items (revenue) with orders (bridge) and 
-- order_reviews (quality). Tests whether top sellers are also 
-- high-quality, or just high-volume.
-- Finding: Most top-10 sellers cluster between 4.0-4.3 review 
-- score. Two exceptions: seller #3 at 3.80 and seller #5 at 
-- 3.35. Seller #5 is a clear outlier — high revenue (R$188k) 
-- but well below quality benchmarks. Top revenue and high 
-- ratings correlate but aren't perfectly aligned; some 
-- sellers monetize despite weaker customer satisfaction.
SELECT 
    oi.seller_id,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS num_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM order_items AS oi
JOIN orders AS o
  ON oi.order_id = o.order_id
JOIN order_reviews AS r
  ON o.order_id = r.order_id
GROUP BY oi.seller_id
ORDER BY total_revenue DESC
LIMIT 10;

-- Q5: Top 10 seller states by total revenue.
-- JOINs sellers with order_items to compute per-state revenue 
-- and seller density. Adds a geographic dimension to the 
-- seller analysis.
-- Finding: SP dominates supply (1,849 sellers = 60% of total, 
-- R$8.7M = 64% of revenue), mirroring its dominance on the 
-- customer side. Two outliers stand out for high per-seller 
-- productivity: BA (R$15,029/seller from just 19 sellers) and 
-- PE (R$10,165/seller from 9 sellers) — small but highly 
-- productive markets. SP's seller concentration also helps 
-- explain Theme 3's delivery-rate gap: sellers cluster in the 
-- southeast, so orders to the Northeast travel long distances.
SELECT 
    s.seller_state,
    COUNT(DISTINCT s.seller_id) AS num_sellers,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(SUM(oi.price) / COUNT(DISTINCT s.seller_id), 2) AS avg_revenue_per_seller
FROM sellers AS s
JOIN order_items AS oi
  ON s.seller_id = oi.seller_id
GROUP BY s.seller_state
ORDER BY total_revenue DESC
LIMIT 10;