-- ====================================
--            ORDER ANALYSIS
-- ====================================

-- 1. Distribution of in-store vs. delivery orders
SELECT
    CASE
        WHEN status = '0' THEN 'In-Store'
        WHEN status = '1' THEN 'Delivery'
    END AS order_type,
    COUNT(*) AS number_of_orders
FROM orders
GROUP BY status
ORDER BY status;

-- 2. Average number of items per order
WITH items_per_order AS (
    SELECT
        order_id,
        SUM(quantity) AS total_items
    FROM order_items
    GROUP BY order_id
)
SELECT
    ROUND(AVG(total_items), 2) AS average_items_per_order
FROM items_per_order;

-- 3. Year with the most orders
WITH yearly_orders AS (
    SELECT
        EXTRACT(YEAR FROM order_date) AS year,
        COUNT(*) AS number_of_orders
    FROM orders
    GROUP BY EXTRACT(YEAR FROM order_date)
)
SELECT
    year,
    number_of_orders
FROM yearly_orders
ORDER BY number_of_orders DESC;

-- 4. Rank of each year with the most orders
WITH yearly_orders AS (
    SELECT
        EXTRACT(YEAR FROM order_date) AS year,
        COUNT(*) AS number_of_orders
    FROM orders
    GROUP BY EXTRACT(YEAR FROM order_date)
)
SELECT
    year,
    number_of_orders,
    DENSE_RANK() OVER (ORDER BY number_of_orders DESC) AS order_rank
FROM yearly_orders
ORDER BY order_rank;
