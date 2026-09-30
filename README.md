# ecommerce-postgresql-project
</> Markdown
# Project Overview
This is a PostgreSQL-based e-commerce database project created to demonstrate SQL skills through realistic customer, order, product, and sales analysis.
The dataset represents a simplified e-commerce business where customers placed orders containing multiple products. 
SQL queries are used to explore customer spending, order values, purchasing behavior, and business-related insights.

</> Markdown
# Database Structure
This database contains the following main tables:
  </> Markdown
  ## 1. customers
  Contains the information about the customers.
  The columns within **customers** table are: `customer_id`, `name`, `email`, `city`, `country`, and `signup_date`

  </> Markdown
  ## 2. order_items
  Contains the individual products included in each order.
  The columns within **order_items** table are: `order_item_id`, `order_id`, `product_id`, `quantity`, and `unit_price`

  </> Markdown
  ## 3. orders
  Contains information about customer orders.
  The columns within **orders** table are: `order_id`, `customer_id`, `order_date`, `status`, and `total_amount`

  </> Markdown
  ## 4. payments
  Contains information about the transactions.
  The columns within **payments** table are: `payment_id`, `order_id`, `payment_method`, `payment_status`, and `payment_date`

  </> Markdown
  ## 5. products
  Contains information about the products available in the store.
  The columns within **products** table are: `product_id`, `product_name`, `category`, `price`, and `stock_quantity`

</> Markdown
# SQL Concepts Demonstrated
This project focuses on writing clean and structured queries applying the following SQL concepts:
* Basic concepts such as `SELECT`, `WHERE`, `GROUP BY`, and `ORDER BY`
* Aggregate functions such as `SUM()`, `AVG()`, `COUNT()`, `MIN()`, and `MAX()`
* Join clauses such as `JOIN`, `INNER JOIN`, `LEFT JOIN`, and `CROSS JOIN`
* Common Table Expressions (CTEs)
* Window Functions such as `ROW_NUMBER()`, `RANK()`, `PARTION BY`, and `OVER()`
* Date and time functions
* Data filtering and transformation

</> Markdown
# Analysis Concepts Demonstrated
This project answers questions such as:
* Who are the top 10 customers based on spending?
* How many new customers are there per year?
* Which customers have spending above the average customer spending?
* What is each customer's most expensive order?
* What is the yearly revenue and growth percentage per year?
* What are the best-selling product categories?
* When did each product have its highest sales?
