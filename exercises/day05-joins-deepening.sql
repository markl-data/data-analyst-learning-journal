-- Set A — Self-joins (4 queries)
-- A1. Find all pairs of customers in the same country. Show both names and the country.
SELECT c1.customer_name AS customer_1, -- Two different Rows on the same Table
       c2.customer_name AS customer_2, -- Two different Rows on the same Table
       c1.country                      -- Matched by Country
FROM customers AS c1
INNER JOIN customers AS c2 
       ON c1.country = c2.country
       AND c1.customer_id < c2.customer_id   -- Prevent Duplicates
ORDER BY c1.country, customer_1;

-- A2. Find all pairs of products in the same category where one's price is more than double the other's. 
-- Show both product names, both prices, and the category.
SELECT p1.product_name AS product_1,   -- Two different Rows on the same Table
       p2.product_name AS product_2,   -- Two different Rows on the same Table
       p1.category                     -- Matched by Category
FROM products AS p1
INNER JOIN products AS p2 
	ON p1.category = p2.category
   		AND p1.product_id < p2.product_id
   		AND (
        	p1.unit_price > 2 * p2.unit_price
        	OR p2.unit_price > 2 * p1.unit_price
       		)

ORDER BY p1.category, product_1;

-- A3. Stretch: For each customer, find another customer with a very similar credit limit (within €5000). 
-- Show both names and both credit limits.
SELECT 
    c1.customer_name AS customer_1,
    c2.customer_name AS customer_2,
    c1.credit_limit + c2.credit_limit AS combined_credit_limit
FROM customers c1
JOIN customers c2
    ON c1.customer_id < c2.customer_id
WHERE (c1.credit_limit + c2.credit_limit) BETWEEN 0 AND 5000
ORDER BY combined_credit_limit, customer_1;

-- A4. Bonus thinking question (don't write code): if customers had a referring_customer_id column 
-- (so customer A could refer customer B), 
-- how would you write a query to show every customer with the name of who referred them? 
-- Sketch in pseudocode.
SELECT customer.name,
       referrer.name
FROM customers AS customer
LEFT JOIN customers AS referrer
       ON customer.referring_customer_id = referrer.customer_id
       
-- Set B — Anti-joins and reverse patterns (4 queries)
-- B1. Find all products that have NEVER been sold. Show name and category.
select p1.product_name as product_1,
	   p1.category
from products p1
left join invoices i 
		ON p1.product_id = i.product_id
where i.amount is null 
order by p1.category;

-- B2. Find all customers who have never had an OVERDUE invoice. 
-- (Tricky — they may have paid invoices.) Show name.
select c1.customer_name as customer_1
from customers c1
left join invoices i
	  on c1.customer_id = i.customer_id
	  and i.status = 'overdue'
where i.invoice_id is null
order by c1.customer_name desc;

-- B3. Find all product categories where the cheapest product has never been sold. 
-- Show category and the unsold product's name.
SELECT 
    p.category,
    p.product_name
FROM products p
JOIN (
        SELECT 
            category,
            MIN(unit_price) AS min_price
        FROM products
        GROUP BY category
     ) cheapest
     ON p.category = cheapest.category
    AND p.unit_price = cheapest.min_price
LEFT JOIN invoices i
       ON p.product_id = i.product_id
WHERE i.invoice_id IS NULL
ORDER BY p.category, p.product_name;

-- B4. Are there any countries where every customer has at least one outstanding or overdue balance? 
-- (Hard — write what you can.)
SELECT country
FROM (
        SELECT 
            c.customer_id,
            c.country,
            CASE 
                WHEN EXISTS (
                    SELECT 1
                    FROM invoices i
                    WHERE i.customer_id = c.customer_id
                      AND i.status IN ('outstanding', 'overdue')
                )
                THEN 1 ELSE 0 
            END AS has_unpaid
        FROM customers c
     ) AS customer_flags
GROUP BY country
HAVING MIN(has_unpaid) = 1

-- Set C — Multi-table aggregation (6 queries)
-- Three tables, GROUP BY, aggregates, ordering.

-- C1. Total revenue per industry. (Industries are in customers, revenue is in invoices.) Sort descending.
select 	c.industry,
		sum(i.amount) as total_revenue
from customers c
join invoices i 
      ON c.customer_id = i.customer_id
GROUP BY c.industry
ORDER BY total_revenue DESC;

-- C2. Top 3 industries by total profit. (Profit needs all three tables.) Sort descending, limit 3.
SELECT 
    c.industry,
    SUM((p.unit_price - p.unit_cost) * i.quantity) AS total_profit
FROM customers c
JOIN invoices i 
      ON c.customer_id = i.customer_id
JOIN products p
      ON i.product_id = p.product_id
GROUP BY c.industry
ORDER BY total_profit DESC
LIMIT 3;

-- C3. For each country, show: number of customers, total revenue, average invoice size. 
-- One row per country.
select
	c.country,
	count(c.customer_id) as total_number_of_customers,
	sum(i.amount) as total_revenue,
	avg(i.amount) as average_invoice_size
from customers c
left join invoices i 
      ON c.customer_id = i.customer_id
group by c.country
order by total_number_of_customers, total_revenue, average_invoice_size desc;  

-- C4. Which product category is most popular in each country? (Group by country and category, sum amount.) 
-- Order by country, then total descending. 
-- (Need window functions to pick just the top one per country - for now, just show the full result.)
select 
	c.country,
	p.category,
	sum(i.amount) as total_revenue
from customers c
left join invoices i
	ON c.customer_id = i.customer_id
left join products p
	ON i.product_id = p.product_id
group by c.country, p.category
order by c.country, total_revenue;

-- C5. Show every customer's name, country, industry, total invoiced amount, count of invoices, and most recent invoice date. 
-- One row per customer. Include customers with no invoices (use COALESCE).
select 
	c.customer_name,
	c.country,
	c.industry,
	coalesce(sum(i.amount), 0) as total_invoiced_amount,
	coalesce(COUNT(i.invoice_id), 0) AS count_of_invoices,
    MAX(i.invoice_date) AS most_recent_invoice_date
from customers c
LEFT JOIN invoices i
       ON c.customer_id = i.customer_id
GROUP BY  c.customer_name, c.country, c.industry
ORDER BY total_invoiced_amount DESC, count_of_invoices DESC;

-- C6. Which products have the highest revenue contribution within their category? 
-- Show product name, category, product's revenue, and the category's total revenue.
select
	p.product_name,
	p.category,
	sum(i.amount) as product_revenue,
	(
		select sum(i2.amount)
		from invoices i2
		join products p2 on i2.product_id = p2.product_id 
		where p2.category = p.category 
	) as category_total_revenue
from products p
left join invoices i
	ON p.product_id = i.product_id
group by p.product_name, p.category 
order by product_revenue desc;

-- Set D — Interview-style questions (6 queries)

-- D1. Find the top 3 customers in each country by total revenue. Show customer name, country, and total.
-- (Limit applies to top 3 globally with our tools today;
-- For now do the global top 3 within each filter)
select
	c.customer_name,
	sum(i.amount) as total_revenue,
	c.country
from customers c
left join invoices i
	on c.customer_id = i.customer_id
where c.country = 'UK'
group by c.customer_name, c.country
order by total_revenue desc
limit 3;

-- D2. For each industry, find the customer with the largest single invoice.
-- Hint: this needs a subquery, which is next week
SELECT
    c.customer_name,
    c.industry,
    i.amount AS largest_invoice
FROM invoices i
JOIN customers c 
      ON i.customer_id = c.customer_id
WHERE i.amount = (
        SELECT MAX(i2.amount)
        FROM invoices i2
        JOIN customers c2 
              ON i2.customer_id = c2.customer_id
        WHERE c2.industry = c.industry
      )
ORDER BY c.industry, largest_invoice DESC;

-- D3. Find customers whose total revenue (paid invoices only) is greater than €10,000. 
-- Show name, country, and that total. Sort descending.
select
	c.customer_name,
	c.country,
	sum(i.amount) as total_revenue
from customers c
left join invoices i
	on c.customer_id = i.customer_id
	and i.status = 'paid'
group by c.customer_name, c.country
having sum(i.amount) > 10000
order by total_revenue desc;

-- D4. Which countries have more than 1 customer AND have generated more than €15,000 in total revenue?
-- Show country, customer count, total revenue.
select
	c.country,
	count(c.customer_id) as customer_count,
	sum(i.amount) as total_revenue
from customers c
left join invoices i
	on c.customer_id = i.customer_id
group by c.country
having count(c.customer_id) > 1 and sum(i.amount) > 15000
order by c.country, customer_count, total_revenue desc;

-- D5. Calculate the "customer concentration": for each country, what % of that country's revenue comes from the single biggest customer? 
-- (Hard — write what you can, sketch the rest. Subqueries coming next week.)
SELECT
    c.customer_name,
    c.country,
    SUM(i.amount) AS customer_revenue,
    (
        SELECT SUM(i2.amount)
        FROM invoices i2
        JOIN customers c2 ON i2.customer_id = c2.customer_id
        WHERE c2.country = c.country
    ) AS country_total_revenue,
    SUM(i.amount) * 1.0 /
    (
        SELECT SUM(i2.amount)
        FROM invoices i2
        JOIN customers c2 ON i2.customer_id = c2.customer_id
        WHERE c2.country = c.country
    ) AS concentration_pct
FROM customers c
LEFT JOIN invoices i
       ON c.customer_id = i.customer_id
GROUP BY c.customer_name, c.country
HAVING SUM(i.amount) = (
    SELECT MAX(customer_total)
    FROM (
        SELECT 
            c3.customer_id,
            SUM(i3.amount) AS customer_total
        FROM customers c3
        LEFT JOIN invoices i3 ON c3.customer_id = i3.customer_id
        WHERE c3.country = c.country
        GROUP BY c3.customer_id
    ) t
)
ORDER BY c.country, concentration_pct DESC;

-- D6. Find product categories where average profit per sale (profit ÷ quantity sold) is above €100. 
-- Show category, total profit, total quantity sold, and average profit per unit.
SELECT
    p.category,
    SUM((p.unit_price - p.unit_cost) * i.quantity) AS total_profit,
    SUM(i.quantity) AS total_quantity_sold,
    SUM((p.unit_price - p.unit_cost) * i.quantity) * 1.0 / SUM(i.quantity) 
        AS avg_profit_per_unit
FROM products p
JOIN invoices i 
      ON p.product_id = i.product_id
GROUP BY p.category
HAVING 
    SUM((p.unit_price - p.unit_cost) * i.quantity) * 1.0 / SUM(i.quantity) > 100
ORDER BY avg_profit_per_unit DESC;
