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



