-- S2 "Find customers whose total revenue is greater than the average customer's total revenue."
select customer_name, 
		(select avg(i.amount) from invoices i) as avg_revenue
from customers c
join invoices i on i.customer_id = c.customer_id 
group by customer_name
order by avg_revenue desc;

-- Q1. Question: Find the product whose revenue is closest to but not 
-- exceeding the average product's revenue.

-----------------------------------------------------
-- Block 1 - CTE, Common Table Expression
-----------------------------------------------------
-- CTE Example
WITH step_a_name AS (
    -- the query that produces Step A's result
),
step_b_name AS (
    -- the query that produces Step B's result, 
    -- can reference step_a_name like a table
)
SELECT ...
FROM step_b_name
WHERE ...;

-- Exercise 1
-- "Find the product whose revenue is closest to (but not exceeding) the average product's revenue."
-- Step A - Per Total Products
-- Step B - Average the Totals
-- Step C - Filter products where Total < B
-- Step D - Pick the one cloest to B(smallest gap, limit 1)
with product_totals as (
	-- Step A - Each Products Total Revenue
	select p.product_id, p.product_name,
	sum(i.amount) as total_revenue
	from products p
	join invoices i on i.product_id = p.product_id
	group by p.product_id, p.product_name  
),
benchmark as (
	-- Step B - Average of those Totals
	select avg(total_revenue) as avg_revenue
	from product_totals
)
-- Step C + D - Filter and Pick Closest
select pt.product_name, pt.total_revenue, b.avg_revenue
from product_totals pt
cross join benchmark b
where pt.total_revenue <= b.avg_revenue 
order by (b.avg_revenue - pt.total_revenue) asc
limit 1;

-- Exercise 2
-- "For each country, show the country's total revenue and 
-- what percentage that represents of the company-wide total. 
-- Sort by percentage descending."
WITH company_total AS (
    -- Step A: compute the single number - company-wide total revenue
    -- (hint: one row, one column called something like 'total_revenue')
    select sum(amount) as total_revenue
    from invoices
),
country_totals AS (
    -- Step B: compute per-country revenue
    -- (hint: JOIN customers and invoices, GROUP BY country, SUM amount)
    select 	c.country,
    		sum(i.amount) as country_revenue
    from customers c
    join invoices i on i.customer_id = c.customer_id
    group by c.country
) 
-- Step C: combine A and B, compute percentage, sort
SELECT 
    ct.country,
    ct.country_revenue,
    -- compute pct here using ct.country_revenue and the value from company_total
    ct.country_revenue * 100.0 / c.total_revenue as pct_of_total
FROM country_totals ct
CROSS JOIN company_total c    -- attach the single company total to every country row
ORDER BY pct_of_total DESC;





