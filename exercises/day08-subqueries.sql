-----------------------------------------------------
-- Block 1 Three Placements of Subqueries
-----------------------------------------------------

-----------------------------------------------------
-- Placement 1 - Subquery in WHERE (filtering)
-----------------------------------------------------

-- 1a. Scalar Comparison (inner returns ONE value)
-- "Customers with credit limit above company average"
select customer_name, credit_limit,
from customers,
where credit_limit > (select avg(credit_limit) from customers;

-- 1b. List membership (inner returns MANY values)
-- "Invoices belonging to Irish customers"
select invoice_id, amount
from invoices
where customer_id in (select customer_id from customers where country = 'Ireland');

-- Decision Rule - if the Inner Query returns one number, use a comparison (>,<,=)
--               - if the Inner Query returns a list of values, use IN

-----------------------------------------------------
-- Placement 2 - Subquery in SELECT (comparisons)
-----------------------------------------------------

-- "Each customer's credit limit alongside the company average"
select 	customer_name, 
		credit_limit,
		(select avg(credit_limit) from customers) as company_avg,
		credit_limit - (select avg(credit_limit) from customers) as gap_from_avg
from customers
order by gap_from_avg desc;
-- Note calling the same Subquery twice, once for value, once for calculation

-----------------------------------------------------
-- Placement 3 - Subquery in FROM (Aggregation)
-----------------------------------------------------

-- "What's the average customer's total revenue?"
-- (You can't do AVG(SUM(amount)) — needs two steps)
select avg(customer_total) as avg_rev_per_customer
from (
	select customer_id, sum(amount) as customer_total
	from invoices
	group by customer_id
) as customer_totals

-----------------------------------------------------
-- Block 2 - 12 Exercises across Three Placements
-----------------------------------------------------

-- Set A - Subquery in WHERE
-- A1. Products priced above the average unit price. Show name and price.
select product_name, unit_price
from products
where unit_price > (select avg(unit_price) from products);

-- A2. All invoices issued to customers from countries where there are 2 or more customers.
-- (Hint: inner query returns countries with ≥2 customers; outer uses IN.)
select i.invoice_id, i.amount
from invoices i
join customers c on c.customer_id = i.customer_id 
where c.country in (
		select country
		from customers
		group by country
		having count(*) >= 2 )
);

-- A3. Customers whose credit limit is below the minimum invoice they've received.
-- (This one is sneaky — note it doesn't quite work cleanly with what you know yet, because "minimum invoice per customer" needs per-row context. 
-- Just write what you can in pseudo-SQL and mark it as needing tomorrow's CTE or a correlated subquery. 
-- We'll come back to it.)
select c.customer_id, c.credit_limit, t.min_invoice
from customers c
join (
	select customer_id, min(amount) as min_invoice
	from invoices i group by customer_id
) t on t.customer_id = c.customer_id
where c.credit_limit < t.min_invoice;

-- A4. All invoices from the top 3 most-billed products.
-- (Inner query: top 3 product_ids by SUM(amount). Outer: invoices WHERE product_id IN (...).)
select invoice_id, amount
from invoices
where product_id in (
		select product_id
		from invoices
		group by product_id 
		order by sum(amount) desc
		limit 3
);

-- A5. Customers in industries that have generated more than €10,000 total revenue.
-- (Inner: industries with SUM > 10000. Outer: customers WHERE industry IN (...).)
select customer_name
from customers
where industry in (
		select industry
		from customers c
		join invoices i on i.customer_id = c.customer_id 
		group by c.industry 
		having sum(i.amount) > 10000
);

-- Set B - Subquery in SELECT
-- B1. Each invoice's amount alongside the company-wide average invoice amount and the difference from that average. 
-- Sort by largest positive difference first.
select 	invoice_id, 
		(select avg(amount) from invoices) as company_avg_invoice,
		amount - (select avg(amount) from invoices) as gap_from_avg
from invoices
order by gap_from_avg  desc;

-- B2. Each product alongside the average price in its own category. 
-- (This is a correlated subquery — preview of Block 3. Try and see what happens.
select 	product_name,category,
		(select avg(unit_price) 
		from products p2 
		where p2.category = p1.category) as avg_unit_price
from products p1
order by avg_unit_price desc;

-- B3. Each customer's name, credit limit, and the maximum invoice amount on record (company-wide), 
-- plus a column showing whether their credit limit covers the max possible single invoice.
select 	customer_name, credit_limit,
		(select max(amount) from invoices) as max_amount,
		case when c.credit_limit >= (select max(amount) from invoices)
		then 'Covers'
		else 'Does not Cover'
		end as covers_max_invoice
from customers c
order by max_amount desc;

-- B4. Each country and a column showing the company's total revenue from all countries.
-- (Trick: SELECT a constant from a subquery. One row per country, but the "total revenue" column shows the same number everywhere — useful for percentage calculations.)
select 	country,
		sum(i.amount) as country_revenue,
		(select sum(amount) from invoices) as total_revenue
from customers c
join invoices i on i.customer_id = c.customer_id
group by country;

-- Set C - Subquery in FROM
-- C1. The average customer's total revenue. (Yesterday's P2 — write it cleanly today.)
select avg(customer_total) as avg_rev_per_customer
from (
	select customer_id, sum(amount) as customer_total
	from invoices
	group by customer_id
) as customer_totals

-- C2. The maximum number of invoices any single customer has had.
-- (Inner: COUNT per customer. Outer: MAX of those counts.)
select max(invoice_count) as max_invoices
from (
	select customer_id, count(*) as invoice_count
	from invoices
	group by customer_id
) as invoice_totals

-- C3. The average margin per product category - but only consider categories that have at least one sale.
-- (Inner: per-product margin SUM, grouped by category. Outer: AVG of those category margins. Trickier than it looks — give it a real go.)
select 
	avg(category_margin) as margin_per_category
from (
	select
		p.category,
		sum( (p.unit_price - p.unit_cost) * i.quantity ) as category_margin
		from products p
		join invoices i on i.product_id = p.product_id
		group by p.category
) avg_margin;

)
		
		