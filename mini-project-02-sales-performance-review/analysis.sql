/* ============================================================
   SALES PERFORMANCE REVIEW — FINAL ANALYSIS SQL
   Author: Mark
   Date: 2026-06-15
   Purpose: Customer trajectory, product momentum, pipeline health
   ============================================================ */


/* ============================================================
   TOPLINE METRICS
   ------------------------------------------------------------
   Total revenue, paid vs outstanding vs overdue
   ============================================================ */

-- Total revenue by status
SELECT
    status,
    SUM(amount) AS total_revenue
FROM invoices
GROUP BY status
ORDER BY status;



/* ============================================================
   Q1 — CUSTOMER TRAJECTORY
   ------------------------------------------------------------
   Goal: Classify customers as growing / flat / declining
   Method: Compare early-period vs late-period revenue
   ============================================================ */

WITH ordered AS (
    SELECT
        c.customer_id,
        c.customer_name,
        i.invoice_date,
        i.amount,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id
            ORDER BY i.invoice_date
        ) AS rn,
        COUNT(*) OVER (
            PARTITION BY c.customer_id
        ) AS total_invoices
    FROM customers c
    JOIN invoices i
        ON i.customer_id = c.customer_id
),
halves AS (
    SELECT
        customer_id,
        customer_name,
        CASE
            WHEN rn <= total_invoices / 2 THEN 'early'
            ELSE 'late'
        END AS period,
        amount
    FROM ordered
),
summary AS (
    SELECT
        customer_id,
        customer_name,
        SUM(CASE WHEN period = 'early' THEN amount END) AS early_revenue,
        SUM(CASE WHEN period = 'late' THEN amount END) AS late_revenue
    FROM halves
    GROUP BY customer_id, customer_name
)
SELECT
    customer_id,
    customer_name,
    early_revenue,
    late_revenue,
    CASE
        WHEN late_revenue > early_revenue * 1.20 THEN 'growing'
        WHEN late_revenue < early_revenue * 0.80 THEN 'declining'
        ELSE 'flat'
    END AS trajectory
FROM summary
ORDER BY customer_name;




/* ============================================================
   Q2 — PRODUCT MOMENTUM
   ------------------------------------------------------------
   Goal: Identify product growth patterns
   Method: Early vs late revenue trajectory (MoM too sparse)
   ============================================================ */

WITH ordered AS (
    SELECT c.customer_id, c.customer_name, i.invoice_date, i.amount,
           ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY i.invoice_date) AS rn,
           COUNT(*) OVER (PARTITION BY c.customer_id) AS total_invoices
    FROM customers c
    JOIN invoices i ON i.customer_id = c.customer_id
),
halves AS (
    SELECT customer_id, customer_name, total_invoices,
           CASE WHEN rn <= total_invoices / 2 THEN 'early' ELSE 'late' END AS period,
           amount FROM ordered
),
summary AS (
    SELECT customer_id, customer_name, total_invoices,
           SUM(CASE WHEN period = 'early' THEN amount END) AS early_revenue,
           SUM(CASE WHEN period = 'late' THEN amount END) AS late_revenue
    FROM halves
    GROUP BY customer_id, customer_name, total_invoices
)
SELECT customer_id, customer_name, total_invoices, early_revenue, late_revenue,
       CASE
           WHEN total_invoices < 4 THEN 'insufficient data'
           WHEN late_revenue > early_revenue * 1.20 THEN 'growing'
           WHEN late_revenue < early_revenue * 0.80 THEN 'declining'
           ELSE 'flat'
       END AS trajectory
FROM summary
ORDER BY trajectory, customer_name;




/* ============================================================
   Q2-C — LOWEST PERFORMING PRODUCTS
   ------------------------------------------------------------
   Goal: Identify bottom 2 products by total revenue
   ============================================================ */

SELECT
    p.product_id,
    p.product_name,
    SUM(i.amount) AS total_revenue
FROM products p
JOIN invoices i
    ON i.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue ASC
LIMIT 2;




/* ============================================================
   Q3 — PIPELINE HEALTH (TIME-TO-PAY PROXY)
   ------------------------------------------------------------
   Goal: Identify slow-paying segments
   Method A: Age of unpaid invoices
   Method B: % of revenue unpaid
   ============================================================ */

-- OPTION A: Average age of outstanding/overdue invoices
SELECT
    c.country,
    c.industry,
    i.status,
    AVG(CURRENT_DATE - i.invoice_date) AS avg_invoice_age_days
FROM invoices i
JOIN customers c
    ON c.customer_id = i.customer_id
WHERE i.status IN ('outstanding', 'overdue')
GROUP BY c.country, c.industry, i.status
ORDER BY avg_invoice_age_days DESC;


-- OPTION B: % of revenue currently unpaid
WITH revenue_by_segment AS (
    SELECT
        c.country,
        c.industry,
        SUM(i.amount) AS total_revenue
    FROM invoices i
    JOIN customers c
        ON c.customer_id = i.customer_id
    GROUP BY c.country, c.industry
),
unpaid_by_segment AS (
    SELECT
        c.country,
        c.industry,
        SUM(i.amount) AS unpaid_revenue
    FROM invoices i
    JOIN customers c
        ON c.customer_id = i.customer_id
    WHERE i.status IN ('outstanding', 'overdue')
    GROUP BY c.country, c.industry
)
SELECT
    r.country,
    r.industry,
    r.total_revenue,
    COALESCE(u.unpaid_revenue, 0) AS unpaid_revenue,
    ROUND(
        COALESCE(u.unpaid_revenue, 0) * 100.0 / r.total_revenue,
        2
    ) AS pct_revenue_unpaid
FROM revenue_by_segment r
LEFT JOIN unpaid_by_segment u
    ON r.country = u.country
   AND r.industry = u.industry
ORDER BY pct_revenue_unpaid DESC;



