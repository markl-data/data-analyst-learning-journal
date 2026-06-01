-- Total number of customers
select count(*) as total_customers
from customers;
--  Total revenue across all invoices.
select sum(amount) as total_revenue
from invoices;
-- Average invoice amount.
select avg(amount) as average_invoice_amount
from invoices;
-- Largest single invoice ever.
select max(amount) as largest_invoice
from invoices;
-- Smallest single invoice ever.
select min(amount) as smallest_invoice
from invoices;
-- Total revenue from paid invoices only.
select sum(amount) as paid_invoices
from invoices
where status = 'paid';
-- Total amount currently outstanding (status = 'outstanding').
select sum(amount) as outstanding_invoices
from invoices
where status = 'outstanding';
-- Number of products in our catalogue.
select count(*) as number_of_products
from products;
-- Average unit price across all products.
select avg(unit_price) as average_unit_price
from products;
-- Number of distinct industries our customers operate in.
select count(distinct industry) as distinct_industry
from customers;

-- Customer count per country.
select country, count(*) as customer_count 
from customers
group by country;
-- Customer count per industry.
select industry, count(*) as customer_industry
from customers
group by industry;
-- Total revenue per status (paid / outstanding / overdue).
select status, sum(amount) as revenue_per_status
from invoices
group by status;
-- Number of invoices per customer (use customer_id). Sort by invoice count descending.
select customer_id, count(*) as invoices_per_customer
from invoices
group by customer_id
order by invoices_per_customer desc;
-- Total revenue per customer (use customer_id). Sort by revenue descending.
select customer_id, sum(amount) as revenue_per_customer
from invoices
group by customer_id
order by revenue_per_customer desc;
-- Average unit price per product category.
select category, avg(unit_price) as average_unit_price
from products
group by category;
-- Number of products per category.
select category, count(*) as products_per_category
from products
group by category;
-- Total quantity sold per product (use product_id). Sort descending.
select product_id, sum(quantity) as total_quantity_sold
from invoices
group by product_id
order by total_quantity_sold desc;
-- Average invoice amount per status.
select status, avg(amount) as average_invoice_amount
from invoices
group by status;
-- Total revenue per customer per status (group by both — should show several rows per customer).
SELECT customer_id,
       status,
       SUM(amount) AS revenue_per_customer_per_status
FROM invoices
GROUP BY customer_id, status
ORDER BY customer_id, status;

-- For each product, show name, unit price, unit cost, and unit margin (price − cost). 
-- Sort by margin descending

select product_name, unit_price, unit_cost, (unit_price - unit_cost) as unit_margin
from products
order by unit_margin desc;

-- For each product (use product_id), show the total quantity sold across all invoices. 
-- Sort by quantity descending.

select product_id, sum(quantity) as total_quantity_sold 
from invoices
group by product_id
order by total_quantity_sold desc;

-- For each product category, show the total profit across all sales. 
-- Total profit = SUM of (margin × quantity).

select category, SUM((unit_price - unit_cost) * quantity) as total_profit
from products
group by category
order by total_profit desc;

-- Average credit limit per country. Sort by average descending.
select country, avg(credit_limit) as average_credit_limit
from customers
group by country
order by average_credit_limit desc;

-- Average invoice amount per year. Use EXTRACT(YEAR FROM invoice_date).
select Extract(year from invoice_date) as invoice_year,
avg(amount) as average_invoice_amount
from invoices
group by invoice_year
order by average_invoice_amount desc;

-- Countries with more than 1 customer.
select country, count(*) as customer_count
from customers
group by country
having count(*) >= 1
order by customer_count desc;

-- Customers (by customer_id) with more than 2 invoices.
select customer_id, count(*) as invoice_count
from invoices
group by customer_id
having count(*) > 2
order by invoice_count desc;

-- Statuses with total revenue over 50000. Sort by total descending.
select status, sum(amount) as total_revenue
from invoices
group by status
having sum(amount) > 50000
order by total_revenue desc;

-- Product categories where the average unit price is above 500.
select category, avg(unit_price) as average_unit_price
from products
group by category
having avg(unit_price) > 500
order by average_unit_price desc;

--  Years where total revenue exceeded 60000.
select extract(year from invoice_date) as invoice_year, sum(amount) as total_revenue
from invoices
group by invoice_year
having sum(amount) > 60000
order by invoice_year desc;

-- Which countries generated the most revenue in 2025?
-- (WHERE to filter year, GROUP BY country, SUM amount, ORDER BY total DESC)
select country, sum(amount) as total_revenue
from invoices
where extract(year from invoice_date) = 2025
group by country
order by total_revenue desc;

-- Average paid-invoice size by customer (use customer_id). Sort descending.
-- (WHERE status = 'paid', GROUP BY customer_id, AVG amount)
select customer_id, avg(amount) as total_paid_invoice
from invoices
where status = 'paid'
group by customer_id
order by total_paid_invoice desc;

-- For each invoice status, show: the number of invoices, the total amount, and the average amount.
-- (Three aggregates side-by-side in one SELECT. GROUP BY status.)
select status, count(*) as number_of_invoices, sum(amount) as total_amount, avg(amount) as average_invoice_amount
from invoices
group by status
order by average_invoice_amount desc;

-- Which months had the highest total invoiced revenue? Try two versions:
-- Just month number: EXTRACT(MONTH FROM invoice_date)
select extract(month from invoice_date) as invoice_month, sum(amount) as total_amount
from invoices
group by invoice_month
order by total_amount desc;
-- Year + month combined: TO_CHAR(invoice_date, 'YYYY-MM')
-- Look at both results and ask: which is more useful for a real analyst?
select to_char(invoice_date, 'YYYY-MM') as invoice_year_month, sum(amount) as total_amount
from invoices
group by invoice_year_month
order by total_amount desc;

-- Find customers (by customer_id) whose total outstanding + overdue balance is greater than 5000.
-- (Hint: WHERE filters to non-paid statuses, GROUP BY customer_id, SUM, HAVING > 5000)
select customer_id, sum(amount) as total_balance
from invoices
where status in ('outstanding', 'overdue')
group by customer_id
having sum(amount) > 5000
order by total_balance desc;










