-- Revision & Consolidation
-- Stuck here used if answer is unknown

-- R1. All customers from the UK
select customer_name, customer_id, country
from customers
where country = 'UK';

-- R2. Customers from the UK with credit limit above 50000
select customer_name, customer_id, country, credit_limit
from customers
where country = 'UK'
and credit_limit > 50000
order by credit_limit desc;

-- R3. The 5 largest invoices in 2025
select invoice_id, invoice_date, amount
from invoices
where extract(year from invoice_date) = 2025
order by amount desc
limit 5;

-- R4. Total revenue by country
select country, sum(amount) as total_revenue
from invoices
group by country
order by total_revenue desc;

-- R5. Number of invoices per status.
select status, count(*) as total_invoices
from invoices
group by status
order by total_invoices desc;

-- R6. Average unit price per product category
select category, avg(unit_price) as avg_unit_price
from products
group by category
order by avg_unit_price desc;

-- R7. Countries with more than 2 customers.
select country, count(customer_id) as Customers
from customers
group by country
having count(customer_id) > 2
order by customers desc;

-- R8. Product categories where average price is above 1000
select category, avg(unit_price) as avg_unit_price
from products
group by category
having avg(unit_price) > 1000
order by avg_unit_price desc;

-- R9. Customers (by customer_id) with more than 3 invoices
select customer_id, count(invoice_id) as total_invoice_id
from invoices
group by customer_id 
having count(invoice_id) > 3
order by total_invoice_id desc;

-- R10. Total revenue per year, ordered by year.
select extract(year from invoice_date) as invoice_year, sum(amount) as total_revenue
from invoices
group by invoice_year
order by invoice_year desc;

-- Block B
-- For each industry, show the total revenue from paid invoices only. Sort by total descending
-- needs Join, revisit Tuesday
select customer_id, sum(amount) as total_revenue
from invoices
where status = 'Paid'
group by customer_id
order by total_revenue desc;

-- Which products were sold in quantities greater than 20 in total across all invoices?
select product_id, count(quantity) as total_quantity_sold
from invoices
group by product_id
having sum(quantity) > 20
order by total_quantity_sold desc;

-- Show the average paid invoice amount per customer (by customer_id), 
-- but only for customers whose average is above 3000. 
select customer_id, avg(amount) as avg_paid_invoice_amount
from invoices
where status = 'paid'
group by customer_id
having avg(amount) > 3000
order by avg_paid_invoice_amount desc;

-- For each invoice status, show: the number of invoices, 
-- the total amount, the average amount, the smallest, the largest.
select status,     COUNT(*) AS total_invoices, SUM(amount) AS total_amount,
AVG(amount) AS average_amount, MIN(amount) AS smallest_invoice, MAX(amount) AS largest_invoice
from invoices
group by status
order by status;

-- Find the months where more than 3 invoices were issued. Show the month and count.
SELECT 
    EXTRACT(MONTH FROM invoice_date) AS invoice_month,
    COUNT(*) AS invoice_count
FROM invoices
GROUP BY invoice_month
HAVING COUNT(*) > 3
ORDER BY invoice_month;

-- Identify "concentration risk" customers: those (by customer_id) 
-- whose total billed amount makes up more than €10,000.
select customer_id, sum(amount) as total_amount
from invoices
group by customer_id
having sum(amount) > 10,000
order by total_amount desc;

-- Across all data, what's the highest single invoice amount, the lowest, the average, and the total?
select count(*) as total_invoices, max(amount) as highest_invoice, 
min(amount) as lowest_invoice, avg(amount) as average_invoice
from invoices
order by total_invoices desc;