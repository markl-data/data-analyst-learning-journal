-------------------------------------------------------
-- Exercises - CTE's - 8 Questions with Decomposition
-------------------------------------------------------
-------------
-- Set A
-------------

-- E1. Top 5 customers by total paid revenue. Show name, country, total. 
-- (Single CTE for the per-customer paid revenue, then final SELECT joins customers.)
-- Steps:
-- A. Per Customer Total Revenue
-- B. Filter to top 5
-- C. Join Customer Names
with customer_totals as (
	select customer_id, sum(amount) as customer_total
	from invoices
	where status = 'paid'
	group by customer_id
),
filter_5 as (
	select customer_id
	from customer_totals
	order by customer_total desc
	limit 5
),
top_5_customers as (
	select ct.customer_id, ct.customer_total
	from customer_totals ct
	join filter_5 f5 on f5.customer_id = ct.customer_id
)
select c.customer_name, c.country, t5.customer_total
from top_5_customers t5
JOIN customers c ON c.customer_id = t5.customer_id
ORDER BY t5.customer_total DESC;

-- E2. Products with above-average margin per unit. Show product name, margin per unit, and the average margin across all products. 
-- (Use two CTEs: one for per-product margin, one for the overall average. Then a final filter.)
-- Steps:
-- A. Per Product Margin
-- B. Overall Average
-- C. Filter
WITH product_margin AS (
    -- A. Per Product Margin
    SELECT 
        product_id,
        (unit_price - unit_cost) AS margin_per_unit
    FROM products
),
avg_margin AS (
    -- B. Overall Average Margin
    SELECT 
        AVG(margin_per_unit) AS avg_product_margin
    FROM product_margin
),
above_avg AS (
    -- C. Filter to products above the average
    SELECT 
        pm.product_id,
        pm.margin_per_unit
    FROM product_margin pm
    CROSS JOIN avg_margin am
    WHERE pm.margin_per_unit > am.avg_product_margin
)
SELECT 
    p.product_name,
    a.margin_per_unit,
    am.avg_product_margin
FROM above_avg a
JOIN products p 
    ON p.product_id = a.product_id
CROSS JOIN avg_margin am
ORDER BY a.margin_per_unit DESC;

-- E3. Countries with more than 1 customer AND total revenue over €15,000. 
-- (Use a CTE to compute per-country stats, then HAVING in the final query. 
-- Compare against your Day 5 D4 - same answer, CTE-shaped.)
-- Steps:
-- A. Country Stats - Distinct Customer_id
-- B. Filter Country, Customer_count and total_revenue by metrics
with country_stats as (
	select c.country, count(distinct c.customer_id) as customer_count,
	sum(i.amount) as total_revenue
	from customers c
	left join invoices i on i.customer_id = c.customer_id
	group by c.country
)
select country, customer_count, total_revenue
from country_stats 
where customer_count >1
and total_revenue > 15000
order by total_revenue desc;

-------------
-- Set B
-------------

-- E4. Customers whose total revenue exceeds the company average. 
-- (This is yesterday's blocker - S2 - written from scratch using the chained CTE pattern from Block 1.)
-- Steps:
-- Customers and the Total Revenue
-- Company Average
-- Filter 
with customer_stats as (
	select c.customer_id, c.customer_name, sum(i.amount) as total_revenue
	from customers c
	left join invoices i on i.customer_id = c.customer_id
	group by c.customer_id, c.customer_name
),
company_avg as (
	select avg(total_revenue) as avg_revenue
	from customer_stats
)
select cs.customer_name, cs.total_revenue, ca.avg_revenue
from customer_stats cs
cross join company_avg ca
where cs.total_revenue > ca.avg_revenue
order by cs.total_revenue desc;

-- E5. For each country, show the country revenue and the country's percentage of total. 
-- Same as yesterday's S3, but written using CTEs from scratch.
-- Steps:
-- Country Revenue, per
-- Country Percentage of Total Country Revenue
-- Filter
with county_revenue as (
    select SUM(amount) AS company_total
    from invoices
)
select 	c.country, sum(i.amount) AS country_revenue,
		sum(i.amount) * 100.0 / t.company_total AS pct_of_total
FROM customers c
join invoices i on i.customer_id = c.customer_id
cross join county_revenue t
group by c.country, t.company_total

-- E6. Find product categories where the total profit per category exceeds the average category's profit. 
-- (Three logical steps: per-category profit, average of those, filter.)
-- Steps:
-- Per Category Profit
-- Average
-- Filter
with category_profit as (
	select p.category, sum((p.unit_price - p.unit_cost) * i.quantity) as total_profit 
	from products p
	join invoices i on i.product_id = p.product_id 
	group by p.category
),
avg_category as (
	select avg(total_profit) as avg_profit
	from category_profit
)
select cp.category, cp.total_profit, ac.avg_profit
from category_profit cp
cross join avg_category ac
where cp.total_profit > ac.avg_profit
order by cp.total_profit desc;

-------------
-- Set C
-------------

-- E7. "For each industry, identify the customer with the highest total revenue in that industry. 
-- Show industry, customer name, and that customer's revenue."
-- Steps:
-- per-customer total revenue (joined with industry)
-- for each industry, find the max total
-- filter A to only customers whose revenue equals their industry's max
-- present cleanly
with customer_totals as (
	select c.customer_id, c.customer_name, c.industry, sum(i.amount) as total_revenue
	from customers c
	left join invoices i on i.customer_id = c.customer_id 
	group by c.customer_id, c.customer_name, c.industry
),
industry_max as (
	select industry, max(total_revenue) as max_revenue
	from customer_totals
	group by industry
),
top_customers as (
	select ct.industry, ct.customer_name, ct.total_revenue
	from customer_totals ct
	join industry_max im on im.industry = ct.industry 
	and im.max_revenue = ct.total_revenue 
)
select *
from top_customers
order by industry;

-- E8. "Identify customers whose total paid revenue is more than 50% of the total paid revenue from their country."
-- Steps:
-- per-customer paid revenue (with country)
-- per-country paid revenue
-- join A and B per customer, compute the ratio
-- filter to >50%
with customer_paid as (
	select c.customer_id, c.customer_name, c.country, sum(i.amount) as customer_revenue
	from customers c
	left join invoices i on i.customer_id = c.customer_id
	where i.status = 'paid'
	group by c.customer_id, c.customer_name, c.country
),
country_paid as (
	select country, sum(customer_revenue) as country_revenue
	from customer_paid 
	group by country
),
pct_ratio as (
	select cp.customer_name, cp.country, cp.customer_revenue,
    cp.customer_revenue * 100.0 / ctry.country_revenue AS pct_of_country
    from customer_paid cp
    join country_paid ctry on ctry.country = cp.country 
)
select customer_name, country, customer_revenue, pct_of_country
from pct_ratio 
where pct_of_country > 50
order by pct_of_country desc;

-----------------------------
-- With Recursive Example
-----------------------------
-- WITH RECURSIVE date_series AS (
    SELECT DATE '2025-01-01' AS day
    UNION ALL
    SELECT day + INTERVAL '1 day'
    FROM date_series
    WHERE day < DATE '2025-12-31'
)
SELECT * FROM date_series;

-----------------------------
-- CTE - Synthesis 
-----------------------------
-- "For each industry, show: number of customers, total revenue, average revenue per customer, 
-- the industry's percentage of total company revenue, 
-- and a flag indicating whether the industry has any overdue invoices."
with industry_stats as (
	-- per industry customer count & total revenue
	select 	c.industry,
			count(distinct c.customer_id) as customer_count,
			sum(i.amount) as total_revenue
			from customers c
			left join invoices i on i.customer_id = c.customer_id
			group by c.industry
),
company_total as (
	-- company wide total revenue
	select sum(amount) as total_revenue
	from invoices
),
industry_overdue as (
	-- industry flag with any overdue invoices
	select c.industry,
	case
		when count(*) > 0 then 1
		else 0
		end as has_overdue
		from customers c
		join invoices i on i.customer_id = c.customer_id 
		where i.status = 'overdue'
		group by c.industry 	
)
select 	s.industry, s.customer_count, s.total_revenue,
		s.total_revenue * 1.0 / s.customer_count as avg_revenue_per_customer,
		s.total_revenue * 100.0 / ct.total_revenue AS pct_of_company,
		COALESCE(o.has_overdue, 0) AS has_overdue
		from industry_stats s
		cross join company_total ct
		left join industry_overdue o on o.industry = s.industry 
		order by pct_of_company desc;