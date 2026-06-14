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