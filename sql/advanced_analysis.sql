-- ================================================================
--                        ADVANCED ANALYSIS
-- ================================================================

/*
===================================================================
 1. Month when each product had its highest sales
===================================================================
 Key SQL Concepts Demonstrated:
  - Aggregate Functions: SUM()
  - Common Table Expressions (CTEs)
  - Window Functions: ROW_NUMBER(), OVER(), PARTITION BY
===================================================================
*/
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

/*
===================================================================
 2. List of each customer's most expensive order
===================================================================
 Key SQL Concepts Demonstrated:
  - Common Table Expressions (CTEs)
  - Window Functions: ROW_NUMBER(), OVER(), PARTITION BY
===================================================================
*/
WITH ranked_orders AS (
	SELECT
		c.customer_id,
		c.name,
		o.order_id,
		o.order_date,
		o.total_amount,
		ROW_NUMBER() OVER(
			PARTITION BY c.customer_id
			ORDER BY o.total_amount DESC
		) AS order_rank
	FROM customers AS c
	INNER JOIN orders AS o
		ON c.customer_id = o.customer_id
)
SELECT
	customer_id,
	name,
	order_id,
	order_date,
	total_amount AS highest_order_value
FROM ranked_orders
WHERE order_rank = 1
ORDER BY highest_order_value DESC;

/*
===================================================================
 3. Each category's best performing product
===================================================================
 Key SQL Concepts Demonstrated:
  - Aggregate Functions: SUM()
  - Common Table Expressions (CTEs)
  - Window Functions: RANK(), OVER(), PARTITION BY
===================================================================
*/
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

/*
===================================================================
 4. Rank of each year with the most orders
===================================================================
 Key SQL Concepts Demonstrated:
  - Common Table Expressions (CTEs)
  - Window Functions: DENSE_RANK(), OVER()
===================================================================
*/
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

/*
===================================================================
 5. Yearly revenue and growth percentage
===================================================================
 Key SQL Concepts Demonstrated:
  - Aggregate Functions: SUM()
  - Common Table Expressions (CTEs)
  - Window Functions: LAG()
===================================================================
*/
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

/*
===================================================================
 6. Products whose sales are declining
===================================================================
 Key SQL Concepts Demonstrated:
  - Aggregate Functions: SUM()
  - Common Table Expressions (CTEs)
  - Window Functions: LAG(), OVER(), PARTITION BY
===================================================================
*/
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

/*
===================================================================
 7. Remaining stock after sales
===================================================================
 Key SQL Concepts Demonstrated:
  - Aggregate Functions: SUM()
  - Common Table Expressions (CTEs)
  - Advanced Functions: COALESCE()
===================================================================
*/
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