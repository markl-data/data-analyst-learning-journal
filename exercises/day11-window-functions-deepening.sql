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




