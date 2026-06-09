-- B2 "Each product alongside the average price in its own category."
-- This gives the SAME average for every row - wrong (company wide average)
SELECT product_name, category, unit_price,
       (SELECT AVG(unit_price) FROM products) AS avg_price
FROM products;

-- Inner Query needs to know what Category the current outer row is on, = Correlated Subquery
select 	p1.product_name,
		p1.category,
		p1.unit_price,
		(select avg(p2.unit_price)       -- Note use of p2 - both using same products table, therefore (p2)
		from products as p2
		where p2.category = p1.category
		) as avg_price_in_category
from products as p1
order by p1.category, p1.unit_price desc;

-- When to use Correlated Subqueries
-- Three Common Patterns
-- Pattern 1 - Per Group Comparison (X alongside the average of Y)
-- Example Above

-- Pattern 2 - EXISTS / NOT EXISTS (checking if related rows exist)
-- Customers who have at least one overdue invoice
select 	customer_name
from customers as c
where exists (
	select 1 from invoices as i
	where i.customer_id = c.customer_id 
	and i.status = 'overdue'
);

-- Pattern 3 - For each X, find the row with Max/Min Y
-- Expand on Later

-- Correlated Subqueries useful with small datasets but with large one the looping aspect could cause issues.

-----------------------------------------------------
-- Block 3 - 3 Exercises - Correlated Subqueries
-----------------------------------------------------
-- D1. Each product alongside the average price in its own category. 
-- (Properly answer B2 from Block 2.)
select 	p1.product_name,
		p1.category,
		p1.unit_price,
		(select avg(p2.unit_price)
		from products p2
		where p2.category = p1.category
		) as avg_category_price
from products p1
order by p1.product_name, p1.category, p1.unit_price desc;

-- D2. Find customers who have at least one paid invoice over €5000. Use EXISTS.
select 	customer_name
from customers c
where exists (
	select 1 from invoices as i
	where i.customer_id = c.customer_id 
	and i.status = 'paid'
	and i.amount > 5000
);

-- D3. Find customers who have no invoices at all. Use NOT EXISTS. 
-- (Compare against your Day 4 B2 anti-join — same answer, different shape.)
select  customer_name
from customers c
where not exists (
	select 1 from invoices as i
	where i.customer_id = c.customer_id
);

-----------------------------------------------------
-- Block 4 - 5 Exercises - Synthesis Exercises
-----------------------------------------------------
-- S1. Which products are priced below the average price within their own category? 
-- Show product name, category, its price, and the category average.
select 	p1.product_name,
		p1.category,
		p1.unit_price,
		(select avg(unit_price)
		from products p2
		where p2.category = p1.category
		) as avg_price
from products p1
where p1.unit_price < (
		select avg(p2.unit_price)
		from products p2
		where p2.category = p1.category
)
order by p1.product_name, p1.category, p1.unit_price desc;

-- S2. Find customers whose total revenue is greater than the average customer's total revenue.
select 	c.customer_name,
		t.total_revenue
from customers c
join 	(
		select customer_id, sum(amount) as total_revenue
		from invoices
		group by customer_id 
		) t on t.customer_id = c.customer_id	
where t.total_revenue > (
		select avg(total_revenue)
		from (
			select customer_id, sum(amount) as total_revenue
			from invoices
			group by customer_id 
		) x
)
order by t.total_revenue desc;

-- S3. For each country, show the country name, the country's total revenue, 
-- and what percentage that represents of the company-wide total.
-- (Subquery in SELECT for the company total, then compute %.)
select 	c.country,
		sum(i.amount) as country_revenue,
		(select sum(amount) from invoices) as total_revenue,
		sum(i.amount) * 100.0 / (select sum(amount) from invoices) as pct_of_total
from customers c
join invoices i on i.customer_id = c.customer_id 
group by c.country
order by pct_of_total desc;

-- S4. Which industries have at least one customer who has never paid an invoice?
-- (Tricky. Sketch the approach in plain English first, then write it.)
select distinct c.industry
from customers c
where exists (
	select 1 from customers c2
		where c2.industry = c.industry 
			and not exists (
			select 1 from invoices i
			where i.customer_id = c2.customer_id  
			and i.status = 'paid'
		)
);

-- or
SELECT DISTINCT c.industry
FROM customers c
LEFT JOIN invoices i 
    ON i.customer_id = c.customer_id
    AND i.status = 'paid'
WHERE i.invoice_id IS NULL;

-- S5. Find the product whose revenue is closest to (but not exceeding) the average product's revenue.
-- (Hard. Don't worry if you can't fully write it — sketch the approach.)
select 	product_name, revenue
from 	(
		-- Revenue per Product
		select p.product_name,
			sum(i.quantity * p.unit_price) as revenue
		from products p
		join invoices i on i.product_id = p.product_id 
		group by p.product_name 
		) t
where revenue <= 
		(
		-- Average Product Revenue
		select avg(revenue)
		from
		(
			select sum(i.quantity * p.unit_price) as revenue
		from products p
		join invoices i on i.product_id = p.product_id 
		group by p.product_id
		) x
)
order by revenue desc
limit 1;
