-- Exploration
-- What date range does our data cover?
SELECT MIN(invoice_date), MAX(invoice_date), COUNT(*) FROM invoices;

-- How many months of data do we have, and how many invoices per month?
SELECT TO_CHAR(invoice_date, 'YYYY-MM') AS year_month, COUNT(*) AS invoice_count, SUM(amount) AS revenue
FROM invoices
GROUP BY TO_CHAR(invoice_date, 'YYYY-MM')
ORDER BY year_month;

-- -- Topline: total revenue, by status, by country, by industry
-- (you've written these before — copy the patterns)
select 	c.country, c.industry, i.status, sum(amount) as total_revenue
		from invoices i
		join customers c on c.customer_id = i.customer_id 
		group by c.country, c.industry, i,status
		order by total_revenue desc;

-------------------------------
-- Topline Takeaway
-------------------------------
-- Revenue is highly concentrated in: Spain (Automotive), Ireland (Beverages), UK (Industrial, Electronics, Retail)

-- And the majority of revenue is paid, but there are meaningful outstanding and overdue pockets in:
-- UK Industrial, Ireland Retail, Portugal Industrial, France Food

-- This is a classic “strong core + weak tail” revenue distribution.

-----------------------------------
-- Country-Level Insights - Top 2
-----------------------------------

-- 🇪🇸 Spain

    -- Automotive dominates.

    -- Multiple large paid invoices (12k, 7.2k, 3.6k).

    -- Spain is a high‑value, low risk market.

-- 🇮🇪 Ireland

    -- Beverages is the powerhouse.

    -- Many paid invoices (12k, 3k, 2.7k, 2.5k, 2.4k, 1.35k, 600).

    -- Retail has outstanding invoices (3.75k, 3.6k).

    -- Ireland is high volume but mixed quality (paid + outstanding).

--------------------------------------
-- Industry-Level Insights - Top 2
--------------------------------------

-- 🚗 Automotive

    -- Entirely Spain.

    -- High‑value paid invoices (12k, 7.2k, 3.6k).

    -- Automotive is a top performer.

-- 🍺 Beverages

    -- Ireland + Germany.

    -- Ireland has many mid‑sized paid invoices.

    -- Germany has a few large paid invoices.

    -- Beverages is high volume + reliable.

--------------------------------------
-- Status-Level Insights - 3 Status
--------------------------------------

-- ✔ Paid

    -- Dominates the dataset.

    -- Strong in Spain, Ireland, Germany, Netherlands, UK.

-- ⏳ Outstanding

    -- UK Industrial (9.6k)

    -- Ireland Retail (3.75k, 3.6k)

    -- Portugal Industrial (1.8k)

    -- Outstanding is clustered in Industrial + Retail.

-- ⚠️ Overdue

    -- Portugal Industrial (2.4k)

    -- France Food (1.8k)

    -- UK Food (900)

    -- Overdue is small but concentrated in weak industries.

--------------------------------------
-- Non Obvious Patterns
--------------------------------------

-- Spain Automotive appears twice at 12k and 7.2k — likely two different customers or two large invoices.

-- Ireland Beverages has many mid‑sized invoices — this is a “bread and butter” segment.

-- UK Industrial is the only segment with both high paid and high outstanding revenue.

-- Portugal Industrial is the only segment with paid + outstanding + overdue.

-- Food is the weakest industry across all countries

--------------------------------------------------------------------------
-- Q1 - Customer Trajectory
-- Q  - "Which customers are growing, flat, or declining over time?"
--------------------------------------------------------------------------

-- Over Time -> Time Series, needs invoice dates
-- Growing/Flat/Declining -> comparison of recent activity to earlier activity
-- Names, not aggregate trends -> need output per customer, not aggregate
with ordered as (
	select c.customer_id, c.customer_name, i.invoice_date, i.amount,
	row_number () over (partition by c.customer_id order by i.invoice_date) as rn,
	count(*) over (partition by c.customer_id) as total_invoices
	from customers c
	join invoices i on i.customer_id = c.customer_id
),
halves as (
	select customer_id, customer_name,
	case when rn <= total_invoices / 2 then 'early'
	else 'late'
	end as period,
	amount from ordered
),
summary as (
	select customer_id, customer_name,
	sum(case when period = 'early' then amount end) as early_revenue,
	sum(case when period = 'late' then amount end) as late_revenue
	from halves
	group by customer_id, customer_name
)
select 	customer_id, customer_name, early_revenue, late_revenue,
		case
			when late_revenue > early_revenue * 1.20 then 'growing'
			when late_revenue < early_revenue * 0.80 then 'declining'
			else 'flat'
		end as trajectory
from summary
order by customer_name;
			 
-- Caveats

-- Customers with only 1–2 invoices cannot be meaningfully classified.

-- Customers with seasonal patterns may appear flat even if they have cycles.

-- Customers with large one off invoices may distort the trend.

--------------------------------------------------------------------------
-- Q2 - Product Momentum
-- Q  - "Which products show consistent growth? Which are seasonal vs steady? 
-- Q  - Which two are the lowest performers and should they be dropped?"
--------------------------------------------------------------------------

-- "Consistent growth in recent months -> time-series per product, LAG or moving-average-shaped
-- "Seasonal vs Steady" -> variance comparison across months
-- "Two lowest performers" -> ranking + recommendation

-- Consistent Growth Products
with product_monthly as (
	select p.product_id, p.product_name,
	date_trunc('month', i.invoice_date) as month,
	sum(i.amount) as monthly_revenue
	from products p
	join invoice_lines il on il.product_id = p.product_id
	join invoices i on i.invoice_id = il.invoice_id
	group by p.product_id, p.product_name, date_trunc('month', i.invoice_date)
),
deltas AS (
    SELECT
        product_id,
        product_name,
        month,
        monthly_revenue,
        LAG(monthly_revenue) OVER (
            PARTITION BY product_id
            ORDER BY month
        ) AS prev_rev
    FROM product_monthly
),
recent AS (
    SELECT
        product_id,
        product_name,
        month,
        (monthly_revenue - prev_rev) AS delta,
        ROW_NUMBER() OVER (
            PARTITION BY product_id
            ORDER BY month DESC
        ) AS rn
    FROM deltas
)
SELECT
    product_id,
    product_name
FROM recent
GROUP BY product_id, product_name
HAVING SUM(CASE WHEN rn <= 3 AND delta > 0 THEN 1 ELSE 0 END) = 3;



-- "Which products are Seasonal vs Steady?"
with product_monthly as (
	select p.product_id, p.product_name,
	date_trunc('month', i.invoice_date) as month,
	sum(i.amount) as monthly_revenue
	from products p
	join invoice_lines il on il.product_id = p.product_id
	join invoices i on i.invoice_id = il.invoice_id
	group by p.product_id, p.product_name, date_trunc('month', i.invoice_date)
),
SELECT
    product_id,
    product_name,
    AVG(monthly_revenue) AS avg_rev,
    STDDEV_POP(monthly_revenue) AS std_rev,
    STDDEV_POP(monthly_revenue) / NULLIF(AVG(monthly_revenue), 0) AS cv,
    CASE
        WHEN STDDEV_POP(monthly_revenue) / NULLIF(AVG(monthly_revenue), 0) > 0.5
            THEN 'seasonal'
        WHEN STDDEV_POP(monthly_revenue) / NULLIF(AVG(monthly_revenue), 0) < 0.1
            THEN 'steady'
        ELSE 'moderate'
    END AS pattern
FROM product_monthly
GROUP BY product_id, product_name
ORDER BY cv DESC;


-- “Which two products are the lowest performers?”
SELECT
    p.product_id,
    p.product_name,
    SUM(i.amount) AS total_revenue
FROM products p
JOIN invoices i 
    ON i.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue ASC
LIMIT 2

-- Caveats

-- Many products have few invoices or irregular timing, so month over month deltas can look artificially positive or negative.
-- A single large invoice can make a product appear “growing” even if it’s not.

-- Seasonality requires enough months to be meaningful.

-- “Lowest performers” should not be judged on revenue alone.



--------------------------------------------------------------------------
-- Q3 - Time-to-pay Analysis
-- Q  - "Average time-to-pay across customer segments." 
-- Q  - "Are some countries/industries slower?"
--------------------------------------------------------------------------

-- Time to Pay using age of Unpaid Invoices
-- “We don’t have payment dates, 
-- so I’m using the age of currently outstanding/overdue invoices as a proxy for time to pay.”
SELECT
    c.country,
    c.industry,
    i.status,
    AVG(CURRENT_DATE - i.invoice_date) AS avg_invoice_age_days
FROM invoices i
JOIN customers c
    ON c.customer_id = i.customer_id
WHERE i.status IN ('outstanding', 'overdue')
GROUP BY
    c.country,
    c.industry,
    i.status
ORDER BY
    avg_invoice_age_days desc
-- This answers:
-- “Where are unpaid invoices hanging around the longest, by country/industry and status?”
    
-- Caveats

-- “We don’t store payment timestamps, so this is a proxy, not true time to pay.”

-- “The age metric only reflects invoices that are still unpaid today, not historical behavior.”

-- “For a proper time‑to‑pay analysis, we’d need either payment dates or a separate payments table.”