-- Total revenue per country
SELECT c.country, SUM(i.amount) AS country_revenue
FROM customers c
JOIN invoices i ON i.customer_id = c.customer_id
GROUP BY c.country; -- One Row per Country

-----------------------------
-- Window Functions - Theory 
-----------------------------

-- Every invoice with the total revenue for its country attached
SELECT i.invoice_id,
       i.amount,
       c.country,
       SUM(i.amount) OVER (PARTITION BY c.country) AS country_total_revenue
FROM customers c
JOIN invoices i ON i.customer_id = c.customer_id
ORDER BY c.country, i.amount DESC;

-- Window function version (today)
SELECT c.country,
       SUM(i.amount) OVER (PARTITION BY c.country) AS country_revenue,
       SUM(i.amount) OVER () AS company_total,
       SUM(i.amount) OVER (PARTITION BY c.country) * 100.0 / SUM(i.amount) OVER () AS pct
FROM customers c
JOIN invoices i ON i.customer_id = c.customer_id;

-- ROW_NUMBER, RANK, DENSE_RANK
-- Syntax
SELECT customer_id,
       amount,
       ROW_NUMBER() OVER (ORDER BY amount DESC) AS rank_by_amount
FROM invoices;
-- with PARTITION BY
-- Rank each invoice within its own customer (largest first)
SELECT c.customer_name,
       i.invoice_id,
       i.amount,
       ROW_NUMBER() OVER (PARTITION BY i.customer_id ORDER BY i.amount DESC) AS rank_within_customer
FROM customers c
JOIN invoices i ON i.customer_id = c.customer_id
ORDER BY c.customer_name, rank_within_customer;

-- Top 3 Customers in each Country
-- Top 3 customers in each country by total revenue
WITH customer_revenue AS (
    SELECT c.country,
           c.customer_name,
           SUM(i.amount) AS total_revenue
    FROM customers c
    JOIN invoices i ON i.customer_id = c.customer_id
    GROUP BY c.country, c.customer_name
),
ranked AS (
    SELECT country,
           customer_name,
           total_revenue,
           ROW_NUMBER() OVER (PARTITION BY country ORDER BY total_revenue DESC) AS rank_in_country
    FROM customer_revenue
)
SELECT country, customer_name, total_revenue
FROM ranked
WHERE rank_in_country <= 3
ORDER BY country, rank_in_country;

----------------------------------------
-- Window Functions - Ranking Exercises 
----------------------------------------

-- W1. Rank all invoices from biggest to smallest. Show invoice_id, amount, and rank.
select 	customer_id, amount,
       	rank() OVER (ORDER BY amount DESC) AS invoice_rank
from invoices
order by amount desc;

-- W2. For each customer, rank their invoices from biggest to smallest. 
-- Show customer name, invoice_id, amount, and rank.
select 	c.customer_name, i.invoice_id, i.amount,
		rank () over (partition by c.customer_id order by i.amount desc) as invoice_rank
from customers c
join invoices i on i.customer_id = c.customer_id 
order by c.customer_name, invoice_rank;

-- W3. For each country, show the top 2 invoices by amount. 
-- Customer name, invoice amount, rank.
with ranked as (
		select 	c.country, c.customer_name, i.invoice_id, i.amount,
		rank () over (partition by c.country order by i.amount desc) as invoice_rank
		from customers c
		join invoices i on i.customer_id = c.customer_id 
)
select *
from ranked
where invoice_rank <= 2
order by country, invoice_rank;

-- W4. Each customer's single largest invoice. Customer name, amount of their biggest invoice. 
-- (Hint: rank invoices within customer, filter to rank = 1.)
with ranked as (
		select 	c.customer_name, i.invoice_id, i.amount,
		rank () over (partition by c.customer_id order by i.amount desc) as invoice_rank
		from customers c
		join invoices i on i.customer_id = c.customer_id 
)
select *
from ranked
where invoice_rank = 1
order by customer_name;

-- W5. Top 3 products in each category by total revenue. 
-- Product name, category, total revenue, rank within category
with product_revenue as (
		select 	p.product_id, p.product_name, p.category, sum(i.amount) as total_revenue
		from products p
		join invoices i on i.product_id = p.product_id
		group by p.product_id , p.product_name , p.category 
),
ranked as (
		select product_name, category, total_revenue,
		rank () over (partition by category order by total_revenue desc) as revenue_rank
		from product_revenue
)
select product_name, category, total_revenue, revenue_rank
from ranked
where revenue_rank <= 3
order by category, revenue_rank;

-- W6. Try this with both ROW_NUMBER() and RANK(): 
-- Top 3 products by unit_price. Compare the outputs - what's the difference?
with ranked as (
    select
        product_name,
        category,
        unit_price,
        ROW_NUMBER() OVER (
            ORDER BY unit_price DESC
        ) AS rn
    from products
)
select *
from ranked
where rn <= 3
order by rn;
--
with ranked as (
    select
        product_name,
        category,
        unit_price,
        Rank() OVER (
            ORDER BY unit_price DESC
        ) AS rnk
    from products
)
select *
from ranked
where rnk <= 3
order by rnk;

-- W7. For each industry, find the customer with the second-highest total revenue. 
-- (Rank = 2 within industry.)
with customer_totals as (
    select
        c.customer_id,
        c.customer_name,
        c.industry,
        SUM(i.amount) AS total_revenue
    from customers c
    left join invoices i
        on i.customer_id = c.customer_id
    group by c.customer_id, c.customer_name, c.industry
),
ranked as (
    select
        customer_name,
        industry,
        total_revenue,
        RANK() OVER (PARTITION BY industry ORDER BY total_revenue DESC) as revenue_rank
    	from customer_totals
)
select
    customer_name,
    industry,
    total_revenue,
    revenue_rank
from ranked
where revenue_rank = 2
order by industry;

-- W8. Interview-grade: Find the second-most-recent invoice for each customer. 
-- Show customer name, the date of their most recent invoice, and the date of their second-most-recent. 
-- (Hint: rank by date descending, partition by customer_id, then filter to rank = 2. 
-- Also tricky bonus: how do you get both dates on the same row? CTE + self-join, or LAG - which you'll meet tomorrow.)
with ranked as (
		select c.customer_id, c.customer_name, i.invoice_date,
		rank () over (partition by c.customer_id order by i.invoice_date desc) as rnk
		from customers c
		join invoices i on i.customer_id = c.customer_id 
)
select 	r2.customer_name,
		r1.invoice_date as most_recent_invoice,
		r2.invoice_date as second_most_recent_invoice
from ranked r1
join ranked r2 on r1.customer_id = r2.customer_id 
where r1.rnk = 1 
and r2.rnk = 2
order by r2.customer_name; 

