-- ====================================
--          CUSTOMER ANALYSIS
-- ====================================

-- 1. Top 10 customers by spending
SELECT
	c.customer_id,
	c.name,
	SUM(o.total_amount) AS total_spending
FROM customers AS c
INNER JOIN orders AS o
	ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spending DESC
LIMIT 10;

-- 2. Number of customers without orders
SELECT COUNT(*) AS customers_without_orders
FROM customers AS c
LEFT JOIN orders AS o
	ON c.customer_id = o.customer_id
WHERE o.order_id is NULL;

-- 3. Number of new customers per year
SELECT
	DATE_TRUNC('year', signup_date) AS year,
	COUNT(*) AS new_customers
FROM customers
GROUP BY DATE_TRUNC('year', signup_date)
ORDER BY year;

-- 4. List of customers whose spending is above the average customer spending
WITH customer_spending AS (
	SELECT
		c.customer_id,
		c.name,
		SUM(o.total_amount) AS total_spending
	FROM customers AS c
	INNER JOIN orders AS o
		ON c.customer_id = o.customer_id
	GROUP BY c.customer_id, c.name
),

average_spending AS (
	SELECT
		AVG(total_spending) AS average_customer_spending
	FROM customer_spending AS cs
)

SELECT
	cs.customer_id,
	cs.name,
	cs.total_spending,
	ROUND(a.average_customer_spending, 2) AS average_customer_spending
FROM customer_spending AS cs
CROSS JOIN average_spending AS a
WHERE cs.total_spending > a.average_customer_spending
ORDER BY cs.total_spending DESC;

-- 5. List of each customer's most expensive order
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
