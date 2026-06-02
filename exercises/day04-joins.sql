-- A1. Show invoice_id, amount, and customer_name for every invoice.
select i.invoice_id, i.amount, c.customer_name
from invoices i
inner join customers c on i.customer_id = c.customer_id 
order by c.customer_name;

-- A2. Show invoice_id, amount, and product_name for every invoice.
SELECT i.invoice_id, i.amount, p.product_name
FROM invoices i
INNER JOIN products p ON i.product_id = p.product_id
ORDER BY p.product_name;

-- A3. Show customer_name, country, and amount for all overdue invoices.
select c.customer_name, c.country, i.amount
from customers c
inner join invoices i on c.customer_id = i.customer_id
where i.status = 'Overdue'
order by c.customer_name;

-- A4. Show customer_name and total revenue per customer (group + join). Sort descending.
select c.customer_name, sum(i.amount) as total_revenue
from customers c
inner join invoices i on c.customer_id = i.customer_id
group by customer_name
order by total_revenue desc;

-- A5. Show product_name and total quantity sold per product. Sort descending.
select p.product_name, sum(i.quantity) as total_quantity
from products p
inner join invoices i on p.product_id = i.product_id
group by p.product_name
order by total_quantity desc;

-- A6. Show product_name and total revenue generated per product.
select p.product_name, sum(i.amount) as total_revenue
from products p
inner join invoices i on p.product_id = i.product_id 
group by p.product_name
order by total_revenue desc;

-- A7. Now answer C3 from Day 2: total profit per product category. 
-- (Hint: SUM((unit_price - unit_cost) * quantity) grouped by category.)
select p.category, sum((p.unit_price - p.unit_cost) * i.quantity) as profit_per_product
from products p
inner join invoices i on p.product_id = i.product_id 
group by p.category
order by profit_per_product;

-- A8. Show customer_name and number of invoices per customer. 
-- Sort descending. Include only customers with more than 2 invoices.
select c.customer_name, count(i.invoice_id) as invoice_count
from customers c
inner join invoices i on c.customer_id = i.customer_id 
group by c.customer_name 
having count(i.invoice_id) > 2
order by invoice_count desc;

-- B1. Show every customer and the total amount they've been invoiced. 
-- Customers with no invoices should show 0 (or NULL).
select c.customer_name, COALESCE(SUM(i.amount), 0) AS total_amount
from customers c
left join invoices i on c.customer_id = i.customer_id 
group by c.customer_name
order by total_amount desc;

-- B2. Find customers who have never been invoiced. 
-- (Hint: LEFT JOIN, then WHERE invoice_id IS NULL.)
select c.customer_name
from customers c
left join invoices i on c.customer_id = i.customer_id 
where i.invoice_id is null
order by c.customer_name desc;

-- B3. Show every product and the total quantity sold. 
-- Include products that have never been sold.
select p.product_name, COALESCE(SUM(i.quantity), 0) as total_quantity
from products p
left join invoices i on p.product_id = i.product_id
group by p.product_name
order by total_quantity desc;

-- B4. Show every customer's name, country, and most recent invoice date. 
-- (Hint: MAX(invoice_date).)
select c.customer_name, c.country, Max(i.invoice_date) as most_recent_invoice
from customers c
left join invoices i on c.customer_id = i.customer_id 
group by c.customer_name, c.country 
order by most_recent_invoice desc;

-- B5. For every customer, show name, credit_limit, and total invoiced amount. 
-- Flag (with a CASE statement or a calculated column) those who have exceeded their credit limit.
select c.customer_name, c.credit_limit, sum(i.amount) as total_invoiced_amount,
case when sum(i.amount) > c.credit_limit then 'Exceeded' else 'OK' end as credit_status
from customers c
left join invoices i on c.customer_id = i.customer_id 
group by c.customer_name, c.credit_limit
order by total_invoiced_amount desc;

-- Set C Multi-table JOINs (5 queries)

-- C1. Show customer_name, product_name, invoice_date, and amount for every invoice.
select c.customer_name, p.product_name, i.invoice_date, i.amount
from invoices i
join customers as c on i.customer_id = c.customer_id
join products as p on i.product_id = p.product_id
order by c.customer_name desc;

-- C2. Total revenue per country per product category. Group by both.
select c.country, p.category, sum(i.amount) as total_revenue
from invoices i
join customers as c on i.customer_id = c.customer_id
join products as p on i.product_id = p.product_id
group by c.country, p.category
order by total_revenue desc;

-- C3. Which industries bought the most of each product category? 
-- (Group by industry and category, SUM amount, ORDER BY descending.)
select c.industry, p.category, sum(i.amount) as total_revenue
from invoices i
join customers as c on i.customer_id = c.customer_id
join products as p on i.product_id = p.product_id
group by c.industry, p.category
order by total_revenue desc;

-- C4. For each customer, 
-- show name and the total margin (sum of (unit_price - unit_cost) × quantity) they've generated.
select c.customer_name, sum((p.unit_price - p.unit_cost) * i.quantity) as total_margin
from invoices i
join customers as c on i.customer_id = c.customer_id
join products as p on i.product_id = p.product_id
group by  c.customer_name
order by total_margin desc;

-- C5. Stretch: For each country, find the single highest-margin invoice. 
-- (Hard with what we know today - write what you can.)
SELECT country, invoice_id, margin
FROM (SELECT c.country, i.invoice_id, (p.unit_price - p.unit_cost) * i.quantity AS margin,
        ROW_NUMBER() OVER (
            PARTITION BY c.country 
            ORDER BY (p.unit_price - p.unit_cost) * i.quantity DESC
        ) AS rn
FROM invoices i
JOIN customers c ON i.customer_id = c.customer_id
JOIN products p ON i.product_id = p.product_id
) highest
WHERE rn = 1
ORDER BY margin DESC;

-- Set D — Real analyst questions (7 queries)
-- D1. Top 5 customers by total paid revenue. Show name, country, and total paid revenue.
select c.customer_name, c.country, sum(i.amount) as total_paid_revenue
from invoices i
join customers as c on i.customer_id = c.customer_id
where i.status = 'paid'
group by c.customer_name, c.country 
order by total_paid_revenue desc 
limit 5;

-- D2. Which Irish customers have outstanding or overdue balances over €2000? 
-- Show name and the outstanding amount.
select c.customer_name, sum(i.amount) as outstanding_amount
from invoices i
join customers as c on i.customer_id = c.customer_id
where c.country = 'Ireland' and i.status in('outstanding','overdue')
group by c.customer_name
having sum(i.amount) > 2000
order by outstanding_amount desc;

-- D3. What's our most profitable product category, by margin × quantity? 
-- Show category and total profit.
select p.category, SUM((p.unit_price - p.unit_cost) * i.quantity) AS total_profit
FROM invoices i
JOIN products p ON i.product_id = p.product_id
GROUP BY p.category
ORDER BY total_profit DESC;

-- D4. For each customer, show: name, country, 
-- total invoices, total revenue, average invoice size, latest invoice date.
select c.customer_name, c.country, count(i.amount) as total_invoices, sum(i.amount) as total_revenue,
avg(i.amount) as average_invoice_size, max(i.invoice_date) as latest_invoice_date
from invoices i
join customers c on i.customer_id = c.customer_id
group by c.customer_name, c.country
order by total_revenue desc, total_invoices desc, latest_invoice_date desc, average_invoice_size, latest_invoice_date desc;

-- D5. Are there any products that have never been sold? Show name and category.
select p.product_name, p.category
from products p
left join invoices i ON p.product_id = i.product_id
group by  p.product_name, p.category
HAVING SUM(i.amount) is null
ORDER BY p.product_name;

-- D6. Which country has the highest average invoice amount? (Not total — average.)
select c.country, avg(i.amount) as average_amount
from invoices i
join customers c on i.customer_id = c.customer_id
where i.status = 'paid'
group by c.country
order by average_amount desc
limit 1;
