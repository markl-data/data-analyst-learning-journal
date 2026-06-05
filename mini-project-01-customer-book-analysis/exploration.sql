-- ============================================
-- Mini-Project 1: Exploration
-- 2026-06-05
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
SELECT status, 
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