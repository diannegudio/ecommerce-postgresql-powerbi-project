-- ====================================
--            SALES ANALYSIS
-- ====================================

-- 1. Total revenue
SELECT SUM(total_amount) AS total_revenue
FROM orders;

-- 2. Monthly revenue
SELECT
	DATE_TRUNC('month', order_date) AS month,
	SUM(total_amount) AS revenue
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;

-- 3. Yearly revenue and growth percentage
WITH yearly_revenue AS (
	SELECT
		EXTRACT(YEAR FROM order_date) AS year,
		SUM(total_amount) AS revenue
	FROM orders
	GROUP BY EXTRACT(YEAR FROM order_date)
),

revenue_comparison AS (
	SELECT
		year,
		revenue,
		LAG(revenue) OVER(
			ORDER BY year
		) AS previous_year_revenue
	FROM yearly_revenue
)

SELECT
	year,
	ROUND(revenue, 2) AS revenue,
	ROUND(previous_year_revenue, 2) AS previous_year_revenue,
	ROUND(
		((revenue - previous_year_revenue) / NULLIF(previous_year_revenue, 0)) * 100, 2
	) AS growth_percentage
FROM revenue_comparison
ORDER BY year;

-- 4. Best-selling product categories
SELECT
	p.category,
	SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items AS oi
INNER JOIN products as p
	ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- 5. Top 10 products by revenue
SELECT 
	p.product_id,
	p.product_name,
	SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items AS oi
INNER JOIN products AS p
	ON oi.product_id = p.product_id
GROUP BY
	p.product_id,
	p.product_name
ORDER BY revenue DESC
LIMIT 10;

-- 6. Month when each product had its highest sales
WITH monthly_product_revenue AS (
	SELECT
        p.product_id,
        p.product_name,
        DATE_TRUNC('month', o.order_date) AS month,
        SUM(oi.quantity * oi.unit_price) AS monthly_revenue
    FROM order_items AS oi
    INNER JOIN products AS p
        ON oi.product_id = p.product_id
    INNER JOIN orders AS o
        ON oi.order_id = o.order_id
    GROUP BY
        p.product_id,
        p.product_name,
        DATE_TRUNC('month', o.order_date)
),

ranked_months AS (
    SELECT
        product_id,
        product_name,
        month,
        monthly_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY product_id
            ORDER BY monthly_revenue DESC
        ) AS month_rank
    FROM monthly_product_revenue
)

SELECT
    product_id,
    product_name,
    TO_CHAR(month, 'Month YYYY') AS highest_sales_month,
    ROUND(monthly_revenue, 2) AS highest_monthly_revenue
FROM ranked_months
WHERE month_rank = 1
ORDER BY highest_monthly_revenue DESC;