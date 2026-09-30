-- ====================================
--            PRODUCT ANALYSIS
-- ====================================

-- 1. Inventory by category
SELECT
	product_id,
	product_name,
	category,
	stock_quantity
FROM products
ORDER BY category;

-- 2. Remaining stock after sales
WITH product_sales AS (
    SELECT
        product_id,
        SUM(quantity) AS total_sold
    FROM order_items AS oi
    INNER JOIN orders AS o
        ON oi.order_id = o.order_id
    GROUP BY product_id
)
SELECT
    p.product_id,
    p.product_name,
    p.stock_quantity AS original_stock,
    COALESCE(ps.total_sold, 0) AS total_sold,
    p.stock_quantity - COALESCE(ps.total_sold, 0) AS remaining_stock
FROM products AS p
LEFT JOIN product_sales AS ps
    ON p.product_id = ps.product_id
ORDER BY remaining_stock DESC;

-- 3. Top 10 products that generate the most revenue
SELECT
	p.product_id,
	p.product_name,
	p.category,
	SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM products AS p
INNER JOIN order_items AS oi
	ON p.product_id = oi.product_id
INNER JOIN orders AS o
	ON oi.order_id = o.order_id
GROUP BY
	p.product_id,
	p.product_name, 
	p.category
ORDER BY total_revenue DESC
LIMIT 10;

-- 4. Each product's percentage of the total revenue
WITH product_revenue AS (
	SELECT
		p.product_id,
		p.product_name,
		SUM(oi.quantity * oi.unit_price) AS revenue
	FROM products AS p
	INNER JOIN order_items AS oi
		ON p.product_id = oi.product_id
	INNER JOIN orders AS o
		ON oi.order_id = o.order_id
	GROUP BY 
		p.product_id,
		p.product_name
)
SELECT
	product_id,
	product_name, 
	ROUND(revenue, 2) AS revenue,
    ROUND(
        revenue / SUM(revenue) OVER () * 100,
        2
    ) AS percentage_of_total_revenue
FROM product_revenue
ORDER BY revenue DESC;

-- 5.Each category's best performing product
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM products AS p
    INNER JOIN order_items AS oi
        ON p.product_id = oi.product_id
    INNER JOIN orders AS o
        ON oi.order_id = o.order_id
    GROUP BY
        p.product_id,
        p.product_name,
        p.category
),
ranked_products AS (
    SELECT
        product_id,
        product_name,
        category,
        revenue,
        RANK() OVER (
            PARTITION BY category
            ORDER BY revenue DESC
        ) AS category_rank
    FROM product_revenue
)
SELECT
    product_id,
    product_name,
    category,
    ROUND(revenue, 2) AS revenue
FROM ranked_products
WHERE category_rank = 1
ORDER BY category;

-- 6. Products whose sales are declining
WITH monthly_product_sales AS (
	SELECT
		p.product_id,
		p.product_name,
		DATE_TRUNC('month', o.order_date) AS month,
		SUM(oi.quantity) AS units_sold
	FROM products AS p
	INNER JOIN order_items AS oi
		ON p.product_id = oi.product_id
	INNER JOIN orders AS o
		ON oi.order_id = o.order_id
	GROUP BY
		p.product_id,
		p.product_name,
		DATE_TRUNC('month', o.order_date)
),
sales_comparison AS (
	SELECT
		product_id,
		product_name,
		month,
		units_sold,
		LAG(units_sold) OVER (
			PARTITION BY product_id
			ORDER BY month
		) AS previous_month_sales
	FROM monthly_product_sales
)
SELECT
	product_id,
    product_name,
    TO_CHAR(month, 'Month YYYY') AS month,
    units_sold,
    previous_month_sales
FROM sales_comparison
WHERE units_sold < previous_month_sales
ORDER BY product_name, month;
