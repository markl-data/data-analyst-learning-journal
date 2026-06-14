--------------------------------------------
-- LAG and LEAD 
--------------------------------------------
-- LAG Example
-- "What was each month's revenue growth compared to the previous month?"
WITH monthly_revenue AS (
    SELECT TO_CHAR(invoice_date, 'YYYY-MM') AS year_month,
           SUM(amount) AS monthly_total
    FROM invoices
    GROUP BY TO_CHAR(invoice_date, 'YYYY-MM')
)
SELECT year_month,
       monthly_total,
       LAG(monthly_total) OVER (ORDER BY year_month) AS prev_month_total,
       monthly_total - LAG(monthly_total) OVER (ORDER BY year_month) AS month_over_month_change
FROM monthly_revenue
ORDER BY year_month;

-- LEAD Example
-- Mirror Image
WITH monthly_revenue AS (
    SELECT TO_CHAR(invoice_date, 'YYYY-MM') AS year_month,
           SUM(amount) AS monthly_total
    FROM invoices
    GROUP BY TO_CHAR(invoice_date, 'YYYY-MM')
)
SELECT year_month,
       monthly_total,
       LEAD(monthly_total) OVER (ORDER BY year_month) AS next_month_total
FROM monthly_revenue
ORDER BY year_month;

-- LAG with an Offset
LAG(monthly_total, 1)  -- previous row (default)
LAG(monthly_total, 3)  -- 3 rows back
LAG(monthly_total, 12) -- 12 rows back (useful for year-over-year on monthly data)

-- Year over Year Pattern - Critical for real Analyst Work
LAG(amount, 12) OVER (ORDER BY year_month)  -- Gives Value from 12 Months ago.

-- LAG/LEAD with PARTITION BY - Key Combination
-- Example
-- "For each customer, what was their previous invoice amount?"
SELECT customer_id, invoice_date, amount,
       LAG(amount) OVER (PARTITION BY customer_id ORDER BY invoice_date) AS prev_invoice
FROM invoices
ORDER BY customer_id, invoice_date; -- Resets Per Customer

--------------------------------------------
-- Window Frames 
--------------------------------------------
-- Helps Define a Frame that is required.
-- Control exactly which rows the window includes.
ROWS BETWEEN <start> AND <end>

Where <start> and <end> can be:

UNBOUNDED PRECEDING - from the very start of the partition
N PRECEDING - N rows before the current row
CURRENT ROW
N FOLLOWING - N rows after the current row
UNBOUNDED FOLLOWING - to the very end of the partition

-- Running Total Example
SUM(amount) OVER (ORDER BY invoice_date)
-- equivalent to:
SUM(amount) OVER (ORDER BY invoice_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)

-- 3-row Moving Average (current row + 2 previous rows)
AVG(amount) OVER (ORDER BY invoice_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)

-- 5-row Centered Average (current row + 2 before + 2 after)
AVG(amount) OVER (ORDER BY invoice_date ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING)

-- Total of just the last 3 invoices for each customer
SUM(amount) OVER (PARTITION BY customer_id ORDER BY invoice_date 
                  ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)

-- 3 Months Moving Average Example
WITH monthly_revenue AS (
    SELECT TO_CHAR(invoice_date, 'YYYY-MM') AS year_month,
           SUM(amount) AS monthly_total
    FROM invoices
    GROUP BY TO_CHAR(invoice_date, 'YYYY-MM')
)
SELECT year_month,
       monthly_total,
       AVG(monthly_total) OVER (ORDER BY year_month 
                                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS three_month_avg
FROM monthly_revenue
ORDER BY year_month;

--------------------------------------------
-- Exercises - 10 Questions
--------------------------------------------
-- Set A
-- For each customer's invoices in chronological order, show the customer_id, invoice_date, 
-- amount, and the previous invoice's amount.
select 	c.customer_id, i.invoice_date, i.amount,
		lag(i.amount) over (partition by c.customer_id order by i.invoice_date) as previous_amt
		from customers c
		join invoices i on i.customer_id = c.customer_id 
		order by c.customer_id, i.invoice_date;

-- Same as previous, but also include a column showing the absolute difference between the current and previous invoice. 
-- Sort by customer then date.
select 	c.customer_id, i.invoice_date, i.amount,
		lag(i.amount) over (partition by c.customer_id order by i.invoice_date) as previous_amt,
		i.amount - LAG(i.amount) OVER (partition by c.customer_id ORDER BY i.invoice_date) AS month_over_month_change
		from customers c
		join invoices i on i.customer_id = c.customer_id 
		order by c.customer_id, i.invoice_date;

--  Monthly revenue with prior-month revenue and month-over-month % growth. 
--  Use a CTE for the monthly revenue first.
WITH monthly_revenue AS (
    SELECT 
        TO_CHAR(invoice_date, 'yyyy-mm') AS year_month,
        SUM(amount) AS monthly_total
    FROM invoices
    GROUP BY TO_CHAR(invoice_date, 'yyyy-mm')
)
SELECT
    year_month,
    monthly_total,
    LAG(monthly_total) OVER (ORDER BY year_month) AS prior_month_revenue,
    ROUND(
        (monthly_total - LAG(monthly_total) OVER (ORDER BY year_month))
        / NULLIF(LAG(monthly_total) OVER (ORDER BY year_month), 0) * 100,
        2
    ) AS pct_growth
FROM monthly_revenue
ORDER BY year_month;

--  For each invoice, show the amount and the next invoice's amount (regardless of customer). 
--  Useful question to think about: in what order should you ORDER BY?
select 	invoice_id, invoice_date, amount,
		lead(amount) over (order by invoice_date) as next_invoice_amount
		from invoices
		order by invoice_date;

--  Interview-grade: For each customer, show their longest gap (in days) between invoices. 
--  (Hint: LAG to get previous date, compute gap, then aggregate.)
with gaps as (
	select c.customer_id, c.customer_name, i.invoice_date, 
	lag(i.invoice_date) over (partition by c.customer_id order by i.invoice_date) as prev_date,
	i.invoice_date - lag(i.invoice_date) over (partition by c.customer_id order by i.invoice_date) as gap_days
	from customers c
	join invoices i on i.customer_id = c.customer_id 
)
select customer_id, customer_name, max(gap_days) as longest_gap_days
from gaps
group by customer_id, customer_name
order by customer_name;

-- Set B
-- For each invoice in chronological order, 
-- show the amount and the average of the last 3 invoice amounts (including the current one).
select 	invoice_id, amount,
		avg(amount) over (ORDER BY invoice_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as three_invoice_amt
		from invoices
order by invoice_date ; -- Chronological Order

-- For each customer's invoices in chronological order, show the running total just for that customer.
select 	c.customer_id, i.invoice_id, i.amount,
		SUM(amount) over (partition by c.customer_id order by i.invoice_date) as running_total
		from customers c
		join invoices i on i.customer_id = c.customer_id
order by c.customer_id, i.invoice_date; -- Chronological Order

-- For each invoice, show the amount and the cumulative total of all invoices issued before this one in the same year.
select 	invoice_id, invoice_date, amount,
		sum(amount) over (partition by extract (year from invoice_date) order by invoice_date
		rows between unbounded preceding and 1 preceding) as prior_invoices_total
		from invoices
order by invoice_date;

-- Interview-grade: For each month, show the 3-month moving average of revenue and the prior 3-month period's average. 
-- This lets a CFO see whether the recent moving average is up or down.
WITH monthly_revenue AS (
    SELECT TO_CHAR(invoice_date, 'YYYY-MM') AS year_month,
           SUM(amount) AS monthly_total
    FROM invoices
    GROUP BY TO_CHAR(invoice_date, 'YYYY-MM')
)
SELECT year_month,
       monthly_total,
       -- Current 3 Month Moving Average
       AVG(monthly_total) OVER (ORDER BY year_month 
                                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS three_month_avg,
       -- Prior 3 Month Moving Average
       AVG(monthly_total) OVER (ORDER BY year_month 
                                ROWS BETWEEN 5 PRECEDING AND 3 PRECEDING) AS prior_three_month_avg                        
FROM monthly_revenue
ORDER BY year_month;

--  Stretch: For each customer, show their average invoice size and what % of that average each individual invoice represents. 
--  (Doable with PARTITION BY + AVG OVER, no frame needed.)
select c.customer_id, i.invoice_id, i.amount,
    AVG(i.amount) OVER (PARTITION BY c.customer_id) AS avg_invoice_size,
    ROUND(i.amount * 100.0 / AVG(i.amount) OVER (PARTITION BY c.customer_id), 2) AS pct_of_customer_avg
FROM customers c
JOIN invoices i
    ON i.customer_id = c.customer_id
ORDER BY c.customer_id, i.amount DESC;

--------------------------------------------
-- Synthesis Exercise
--------------------------------------------

-- For each customer, produce a row showing: 
-- customer_name, total invoices, total revenue, largest single invoice, smallest invoice, 
-- average invoice, their most recent invoice date, and a column showing what % of company revenue they represent.
SELECT c.customer_name,
    COUNT(i.amount) AS total_invoices,
    SUM(i.amount) AS total_revenue,
    MAX(i.amount) AS largest_invoice,
    MIN(i.amount) AS smallest_invoice,
    AVG(i.amount) AS average_invoice,
    MAX(i.invoice_date) AS most_recent_invoice_date,
    ROUND(SUM(i.amount) * 100.0 / (SELECT SUM(amount) FROM invoices), 2) AS pct_of_company_revenue
FROM customers c
JOIN invoices i
    ON i.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY total_revenue DESC;


