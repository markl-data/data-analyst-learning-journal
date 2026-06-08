-- Subquery can exist in Three Places
-- In WHERE, In SELECT, In FROM

-- In SELECT - Example
SELECT customer_name,
       credit_limit,
       (SELECT AVG(credit_limit) FROM customers) AS avg_credit_limit_all_customers,
       credit_limit - (SELECT AVG(credit_limit) FROM customers) AS difference_from_avg
FROM customers
ORDER BY difference_from_avg DESC;
-- How does X compare to the average? - Use this subquery.

-- In FROM - Example
SELECT AVG(customer_total) AS avg_revenue_per_customer
FROM (
    SELECT customer_id, SUM(amount) AS customer_total
    FROM invoices
    GROUP BY customer_id
) AS customer_totals;
-- Brackets run 1st - Treated as a new Table - Apply Outer Query for Result.
-- Note customer_totals - Alias is Needed.
-- Example Questions for this subquery
-- Q1. "What's the average customer's lifetime value?" → AVG of SUM per customer
-- Q2. "What's the median invoice amount per country?" → MEDIAN of per-country aggregates
-- Q3. "What's the busiest day of the year by invoice count?" → MAX of COUNT per day

-- Three Exercise Questions
-- P1. Show each product's name, unit price, and the company's average unit price. 
-- Add a column showing how each product compares (i.e., difference from average).
select product_name,
       unit_price,
       (SELECT AVG(unit_price) FROM products) AS avg_unit_price,
       unit_price - (SELECT AVG(unit_price) FROM products) AS difference_from_avg
FROM products
ORDER BY difference_from_avg DESC;

-- P2. What's the average customer's total revenue? (Inner: total per customer. Outer: AVG of that.)
select avg(customer_total) as avg_revenue_per_customer
from (
    select customer_id, SUM(amount) AS customer_total
    FROM invoices
    GROUP BY customer_id
) AS customer_totals;

-- P3. Same as P2, but for the maximum — i.e., who's our single biggest customer by total revenue? 
-- (Hint: WHERE customer_total = (SELECT MAX(customer_total) FROM (...))). 
-- This is a sub-subquery — perfectly fine, you'll meet these constantly.
select c.customer_name, customer_total
from (
    select customer_id, SUM(amount) AS customer_total
    FROM invoices
    GROUP BY customer_id
) AS t1
join customers c on c.customer_id = t1.customer_id
where customer_total = (
	select max(customer_total)
	from (
		select customer_id, sum(amount) as customer_total
		from invoices
		group by customer_id
	) as t2
);

