-- ============================================
-- Day 6 — Consolidation + Subquery Preview
-- 2026-06-04
-- ============================================

-- --------------------------------------------
-- Block 1: COUNT(DISTINCT) Drill
-- --------------------------------------------
SELECT c.country,
       COUNT(c.customer_id) AS wrong_count,
       COUNT(DISTINCT c.customer_id) AS right_count
FROM customers AS c
LEFT JOIN invoices AS i ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY c.country;

-- D1.2a How many distinct customers have we invoiced in each year? (Year, customer count.)
select 
	count(distinct c.customer_id) as customer_count,
	extract (year from i.invoice_date) as invoice_year
from customers as c
join invoices AS i ON c.customer_id = i.customer_id
group by invoice_year;

-- D1.2b How many distinct industries does each country represent in our customer base? 
-- (Country, distinct industries.)
select c.country,
	count(distinct c.industry) as distinct_industry
from customers c
group by c.country;

-- D1.2c How many distinct products has each customer bought? 
-- (Customer name, distinct product count.)
select
	c.customer_name,
	count(distinct i.product_id) as distinct_products_bought
from invoices i
join customers c on c.customer_id = i.customer_id
group by c.customer_name
order by distinct_products_bought;

-- D1.2d For each invoice status, how many distinct customers are involved? 
-- (Status, distinct customers.)
select
	i.status,
	count(distinct c.customer_id) as distinct_customers
from customers c
join invoices i on c.customer_id = i.customer_id
group by i.status
order by distinct_customers;

-- --------------------------------------------
-- Block 2: Speed Drills (Days 1-5 Mixed)
-- --------------------------------------------
-- S1. All customers from Germany.
select
	c.customer_name
from customers c
where c.country = 'Germany';

-- S2. All paid invoices over €5000, customer name and amount, sorted descending.
select
	c.customer_name,
	i.amount
from invoices i
join customers c on c.customer_id = i.customer_id
where i.status = 'paid'
	and i.amount > 5000
order by i.amount desc;

-- S3. Total revenue per product category, sorted descending.
select
	p.category,
	sum(i.amount) as total_revenue
from invoices i
join products p on p.product_id = i.product_id 
group by p.category
order by total_revenue desc;

-- S4. Top 5 customers by total invoiced revenue (any status). 
-- Customer name, total revenue.
select
	c.customer_name,
	sum(i.amount) as total_revenue
from invoices i
join customers c on c.customer_id = i.customer_id 
group by c.customer_name 
order by total_revenue desc
limit 5;

-- S5. Number of distinct customers per country who have at least one overdue invoice. 
-- (Pure anti-pattern of S5 next: COUNT(DISTINCT) + filter.)
select
	c.country,
	count(distinct c.customer_id) as distinct_customers
from customers c
join invoices i on i.customer_id = c.customer_id 
where i.status = 'overdue'
group by c.country
order by distinct_customers desc;

-- S6. Products that have never appeared on any invoice.
select
	p.product_name
from products p
left join invoices i on i.product_id = p.product_id
where i.product_id is null;

-- S7. For each industry, show: customer count, total revenue, average invoice amount.
select
	c.industry,
	count(distinct c.customer_id) as customer_count,
	sum(i.amount) as total_revenue,
	avg(i.amount) as avg_invoice_amt
from invoices i
join customers c on c.customer_id = i.customer_id 
group by c.industry
order by customer_count , total_revenue , avg_invoice_amt desc;

-- S8. Months in 2025 where total revenue exceeded €10,000. (Use TO_CHAR for year-month.)
select
	to_char(i.invoice_date, 'YYYY-MM') as year_month,
	sum(i.amount) as total_revenue
from invoices i
where to_char(i.invoice_date, 'YYYY') = '2025'
group by to_char(i.invoice_date, 'YYYY-MM')
having sum(i.amount) > 10000
order by total_revenue desc;

-- S9. The customer name with the single largest invoice ever.
select
	c.customer_name,
	max(i.amount) as largest_invoice
from invoices i
join customers c on c.customer_id = i.customer_id 
group by c.customer_name 
order by largest_invoice desc
limit 1;

-- S10. For each country, what's the average customer credit limit and how does it compare to the global average? 
-- (For now, write the per-country average; comparing to global needs subqueries — which is Block 3.)
select
	c.country,
	avg(c.credit_limit) as avg_cedit_limit,
	ROUND((SELECT AVG(credit_limit) FROM customers), 0) AS global_avg_credit_limit
from customers c
group by c.country
order by avg_cedit_limit desc;

-- SubQuery Preview
-- Pattern 1
-- Customers with above-average credit limit
SELECT customer_name, credit_limit
FROM customers
WHERE credit_limit > (SELECT AVG(credit_limit) FROM customers);

-- All invoices belonging to UK customers
SELECT *
FROM invoices
WHERE customer_id IN (SELECT customer_id FROM customers WHERE country = 'UK');

-- The single largest invoice
SELECT *
FROM invoices
WHERE amount = (SELECT MAX(amount) FROM invoices);

-- SubQuery Practice
-- SQ1. Products priced above the average product price. Show product name and unit price.
select product_name, unit_price
from products
where unit_price > (select avg(unit_price) from products)
order by product_name, unit_price;

-- SQ2. Invoices with above-average amounts. Show invoice_id and amount.
select invoice_id, amount
from invoices
where amount > (select avg(amount) from invoices)
order by invoice_id, amount;

-- SQ3. All invoices belonging to Irish customers. Use IN (SELECT ...) to find Irish customer_ids first.
select invoice_id, customer_id, amount
from invoices
where customer_id in (select customer_id from customers where country = 'Ireland')
order by customer_id, amount desc;

-- SQ4. The single most expensive invoice on record. 
-- Show all columns. (Hint: WHERE amount = (SELECT MAX(...))).
select customer_id, invoice_id, amount
from invoices
WHERE amount = (SELECT MAX(amount) FROM invoices)
order by customer_id, invoice_id, amount desc;

-- SQ5. Customer(s) with the highest credit limit. (
-- There might be more than one tied for the highest — that's why your filter uses = (SELECT MAX...), not LIMIT 1.)
select customer_name, customer_id, credit_limit
from customers c
where credit_limit = (select max(credit_limit) from customers)
order by customer_name, customer_id, credit_limit desc;

-- Block 4: Mini-project preparation
-- CFO Q1: most valuable customers + concentration risk
-- Tables: customers, invoices
-- Approach: GROUP BY customer, SUM revenue, ORDER BY desc
-- Concentration: top customer's share of total revenue
-- Tool gap: need subquery for total revenue comparison

-- --------------------------------------------
-- End-of-day note
-- --------------------------------------------
-- Day 6 complete. Drills locked, subquery basics tasted, 
-- mini-project briefing read and approach sketched.