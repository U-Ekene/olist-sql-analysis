-- Theme 5: Products & Categories
-- Looks at the catalog: which categories sell most, what's 
-- popular by region, how product attributes correlate with 
-- performance.
-- Skills: CTEs (Common Table Expressions), JOIN with translation 
-- table, layered analytical queries.

-- Q1: Top 10 categories by total revenue (with English names).
-- Uses a CTE to compute revenue per category, then joins to 
-- the translation table for clean English labels.
-- Finding: Health/beauty leads at R$1.26M, but watches_gifts 
-- has the highest revenue per item (~R$201, roughly 2x the 
-- platform average). Top 10 spans broad consumer categories 
-- (no fashion-specific category in the top — notable absence). 
-- Revenue is balanced across categories (#1 to #10 = 2.6x 
-- ratio), in contrast with seller distribution which is heavily 
-- long-tailed.
WITH category_revenue AS (
    SELECT 
        p.product_category_name,
        ROUND(SUM(oi.price), 2) AS total_revenue,
        COUNT(*) AS items_sold
    FROM products AS p
    JOIN order_items AS oi
      ON p.product_id = oi.product_id
    GROUP BY p.product_category_name
)
SELECT 
    t.product_category_name_english AS category,
    cr.total_revenue,
    cr.items_sold
FROM category_revenue AS cr
JOIN product_category_name_translation AS t
  ON cr.product_category_name = t.product_category_name
ORDER BY cr.total_revenue DESC
LIMIT 10;

-- Q2: Top 10 categories by average review score (with at 
-- least 100 reviews).
-- 4-table JOIN through products → order_items → orders → 
-- order_reviews. CTE handles the heavy aggregation; main 
-- query handles translation and filtering.
-- Finding: Books dominate customer satisfaction (4.45 and 4.37) 
-- so they are predictable products. Food categories also 
-- score well (4.22-4.32). Notably, the highest-revenue 
-- categories (health_beauty, watches_gifts, bed_bath_table) 
-- don't appear in the top-10-by-review list — revenue and 
-- quality are decoupled in this marketplace. Top-revenue 
-- categories tend to have more product variability and quality 
-- issues than simpler categories like books.
WITH category_reviews AS (
    SELECT 
        p.product_category_name,
        AVG(r.review_score) AS avg_score,
        COUNT(*) AS num_reviews
    FROM products AS p
    JOIN order_items AS oi ON p.product_id = oi.product_id
    JOIN orders AS o ON oi.order_id = o.order_id
    JOIN order_reviews AS r ON o.order_id = r.order_id
    GROUP BY p.product_category_name
)
SELECT 
    t.product_category_name_english AS category,
    ROUND(cr.avg_score, 2) AS avg_review,
    cr.num_reviews
FROM category_reviews AS cr
JOIN product_category_name_translation AS t
  ON cr.product_category_name = t.product_category_name
WHERE cr.num_reviews >= 100
ORDER BY cr.avg_score DESC
LIMIT 10;

-- Q3: Worst-rated categories (mirror of Q2 with ORDER BY ASC).
-- Same CTE as Q2; flipped sort to surface quality problems.
-- Finding: 3 of the top 6 highest-revenue categories also appear 
-- in the bottom 10 by review score (bed_bath_table, 
-- furniture_decor, computers_accessories). This is a structural 
-- quality problem: the platform's biggest revenue drivers are 
-- also its weakest customer experiences. The pattern is consistent 
-- with physical complexity — bulky/fragile/technical products 
-- score lowest, simple products (books, food, stationery) score 
-- highest. Office_furniture is the standout problem area at 3.49 
-- with 1,687 reviews — strong sample, large gap from peers.
WITH category_reviews AS (
    SELECT 
        p.product_category_name,
        AVG(r.review_score) AS avg_score,
        COUNT(*) AS num_reviews
    FROM products AS p
    JOIN order_items AS oi ON p.product_id = oi.product_id
    JOIN orders AS o ON oi.order_id = o.order_id
    JOIN order_reviews AS r ON o.order_id = r.order_id
    GROUP BY p.product_category_name
)
SELECT 
    t.product_category_name_english AS category,
    ROUND(cr.avg_score, 2) AS avg_review,
    cr.num_reviews
FROM category_reviews AS cr
JOIN product_category_name_translation AS t
  ON cr.product_category_name = t.product_category_name
WHERE cr.num_reviews >= 100
ORDER BY cr.avg_score ASC
LIMIT 10;