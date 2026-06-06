-- ============================================
-- Mini-Project 1: Analysis Queries
-- 2026-06-06
-- ============================================

-- =========================================
-- State of the Book - the Topline Numbers
-- =========================================

-- How many customers, total?
SELECT COUNT(*) AS total_customers FROM customers;

-- Total revenue?
SELECT SUM(amount) AS total_revenue FROM invoices;

-- Revenue by status?
SELECT status, 
       COUNT(*) AS invoice_count,
       SUM(amount) AS total_amount,
       ROUND(100.0 * SUM(amount) / SUM(SUM(amount)) OVER (), 1) AS pct_of_total
FROM invoices
GROUP BY status;
-- Give me a Percentage of Total OVER ()

-- Alternative 
SELECT  
       COUNT(*) AS invoice_count,
       SUM(amount) AS total_amount,
       ROUND(100.0 * SUM(amount) / (SELECT SUM(amount) FROM invoices), 1) AS pct_of_total
FROM invoices
GROUP BY status
ORDER BY total_amount DESC;

-- Note of Numbers / Key Information

-- Topline numbers as of 2026-06-05:
-- Total customers: 12
-- Total revenue: € 137,920
-- % paid: 82.70%, % outstanding: 13.60%, % overdue: 3.70%

-- =========================================
-- Focus One - Customer Concentration
-- =========================================

-- Top 10 customers by total revenue (name, country, industry, total revenue)
select
	c.customer_name,
	c.country,
	c.industry,
	sum(i.amount) as total_revenue
from customers c
join invoices i on c.customer_id = i.customer_id
group by c.customer_name , c.country , c.industry 
order by total_revenue desc
limit 10;

-- The top 1 customer's share of total revenue (a single percentage)
SELECT 
    SUM(amount) AS top_1_customer,
    (SELECT SUM(amount) FROM invoices) AS total_revenue,
    ROUND(100.0 * SUM(amount) / (SELECT SUM(amount) FROM invoices), 1) AS pct_of_total
FROM invoices
WHERE customer_id IN (
    select customer_id
    from invoices
    group by customer_id
    order by sum(amount) desc
    limit 1
);
	 
-- The top 3 customers' combined share of total revenue
SELECT 
    SUM(amount) AS top_3_customers_combined_share,
    (SELECT SUM(amount) FROM invoices) AS total_revenue,
    ROUND(100.0 * SUM(amount) / (SELECT SUM(amount) FROM invoices), 1) AS pct_of_total
FROM invoices
WHERE customer_id IN (
    select customer_id
    from invoices
    group by customer_id
    order by sum(amount) desc
    limit 3
);

-- The top 5 customers' combined share of total revenue
SELECT 
    SUM(amount) AS top_5_customers_combined_share,
    (SELECT SUM(amount) FROM invoices) AS total_revenue,
    ROUND(100.0 * SUM(amount) / (SELECT SUM(amount) FROM invoices), 1) AS pct_of_total
FROM invoices
WHERE customer_id IN (
    select customer_id
    from invoices
    group by customer_id
    order by sum(amount) desc
    limit 5
);

-- ===============================================
-- Focus Two - Country & Industry Performance
-- ===============================================

-- Per country: customer count (DISTINCT!), total revenue, average revenue per customer
select
	c.country,
	count(distinct c.customer_id) as customer_count,
	avg(i.amount) as total_revenue,
	ROUND(SUM(i.amount) / COUNT(DISTINCT c.customer_id), 2) AS avg_revenue_per_customer
from customers c
join invoices i on c.customer_id = i.customer_id
group by c.country
order by total_revenue desc;

-- Per industry: same metrics
select
	c.industry,
	count(distinct c.customer_id) as customer_count,
	avg(i.amount) as total_revenue,
	ROUND(SUM(i.amount) / COUNT(DISTINCT c.customer_id), 2) AS avg_revenue_per_customer
from customers c
join invoices i on c.customer_id = i.customer_id
group by c.industry
order by total_revenue desc;

-- For each, compare against the global average per customer - the subquery move
select
	c.country,
	count(distinct c.customer_id) as customer_count,
	sum(i.amount) as total_revenue,
	round(sum(i.amount) / count(distinct c.customer_id), 2) AS avg_revenue_per_customer,
	(
		select round(sum(amount) / count(distinct customer_id), 2)
		from invoices
	) as global_avg_per_customer
from customers c
join invoices i on c.customer_id = i.customer_id
group by c.country
order by avg_revenue_per_customer desc;
	
-- ===============================================
-- Focus Three - Product Profit Contribution
-- ===============================================

-- Per product: name, category, total revenue, total profit, total quantity sold, average profit per unit
select
	p.product_name,
	p.category,
	sum(i.amount) as total_revenue,
	sum((p.unit_price - p.unit_cost) * i.quantity) as total_profit,
	sum(i.quantity) as total_quantity_sold,
	round(avg(p.unit_price - p.unit_cost), 2) as avg_profit_per_unit
from products p
join invoices i on p.product_id = i.product_id
group by p.product_name, p.category
order by total_revenue desc;

-- Rank by total profit, descending
select
	p.product_name,
	p.category,
	sum(i.amount) as total_revenue,
	sum((p.unit_price - p.unit_cost) * i.quantity) as total_profit,
	sum(i.quantity) as total_quantity_sold,
	round(avg(p.unit_price - p.unit_cost), 2) as avg_profit_per_unit
from products p
join invoices i on p.product_id = i.product_id
group by p.product_name, p.category
order by total_profit desc;

-- Identify any products with low profit or no sales (anti-join pattern from Day 6)
SELECT p.product_name,
       p.category,
       SUM(i.amount) AS total_revenue,
       SUM((p.unit_price - p.unit_cost) * i.quantity) AS total_profit,
       SUM(i.quantity) AS total_quantity,
       ROUND(SUM((p.unit_price - p.unit_cost) * i.quantity) / SUM(i.quantity), 2) AS profit_per_unit
FROM products p
LEFT JOIN invoices i ON p.product_id = i.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_profit DESC NULLS LAST;

-- ===============================================
-- Focus Four - Overdue & Outstanding
-- ===============================================

-- A list of customers with the largest overdue + outstanding balances (by name)
select
	c.customer_name,
	sum(i.amount) as unpaid_balance
from customers c
join invoices i on c.customer_id = i.customer_id 
where i.status in ('overdue', 'outstanding')
group by c.customer_name 
order by unpaid_balance desc;

-- Each customer's outstanding+overdue amount as a % of their total billings 
-- (concentration of their own risk)
select 
	c.customer_id,
	c.customer_name,
	c.country,
	c.credit_limit,
	sum(case when i.status in ('overdue', 'outstanding') then i.amount else 0 end) as unpaid_amount,
	sum(i.amount) as total_billed,
	round(
		sum(case when i.status in ('overdue', 'outstanding') then i.amount else 0 end)
		/ nullif(sum(i.amount), 0) *100,
		1
	) as billing_pct
from customers c
left join invoices i on c.customer_id = i.customer_id
group by c.customer_id, c.customer_name, c.country, c.credit_limit
having sum(case when i.status in ('overdue', 'outstanding') then i.amount else 0 end) > 0
order by billing_pct desc;


-- Whether any of those customers are exceeding their credit limit
SELECT c.customer_name,
       c.country,
       c.credit_limit,
       SUM(CASE WHEN i.status IN ('overdue','outstanding') THEN i.amount ELSE 0 END) AS at_risk_amount,
       SUM(i.amount) AS total_billed,
       ROUND(100.0 * SUM(CASE WHEN i.status IN ('overdue','outstanding') THEN i.amount ELSE 0 END) 
             / NULLIF(SUM(i.amount), 0), 1) AS pct_at_risk,
       CASE WHEN SUM(CASE WHEN i.status IN ('overdue','outstanding') THEN i.amount ELSE 0 END) > c.credit_limit 
            THEN 'YES' ELSE 'no' END AS exceeds_credit_limit
FROM customers c
LEFT JOIN invoices i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.customer_name, c.country, c.credit_limit
HAVING SUM(CASE WHEN i.status IN ('overdue','outstanding') THEN i.amount ELSE 0 END) > 0
ORDER BY at_risk_amount DESC;
