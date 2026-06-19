-----------------------------------------------------------------------
-- DATA ORIENTATION NOTES (from Kaggle page, 2026-06-19)
-----------------------------------------------------------------------

-- Dataset claims to contain financial statements for major listed companies, 2009-2023

-- Reported columns include: Company, Year, Category, Market Cap, Revenue, Gross Profit, 
-- Net Income, Earning Per Share, EBITDA, Share Holder Equity

---------------------------------------
-- EXCEL DATA VERIFICATION
---------------------------------------
-- Number of Rows: 162 Rows
-- How many columns?: 23 Columns
-- What's the header row tell you?: Listed Reported Columns Above (Filter Applied.)
-- Number of companies: 12 Companies
-- Data shape: Long Format - One Row per Company Year
-- What are the data types?: Text & Numerical including Decimal Numbers
-- Any obvious quality issues?: None
-- What's the date/year granularity?: Annual
-- Known issues from Discussion tab: Initial Excel Data Verification - Values/Duplicates/Errors - none identified.


---------------------------------------
-- MENTAL MODEL
---------------------------------------

-- Likely fact table: 
-- Likely dimensions: companies, time periods, sectors/industries?
-- Probable analytical angles:
--   1. Cross-company comparison (who's the most profitable?)
--   2. Time-series (how have margins changed over 15 years?)
--   3. Sector Aalysis (which industries grew, which shrank?)
--   4. Risk indicators (companies with declining metrics?)
--

-- The Fitness Hub dashboard patterns I want to apply:
-- - 4 KPI cards across the top
-- - Multi-page navigation
-- - Waterfall chart on a P&L breakdown
-- - Narrative panel alongside numbers

---------------------------------------
-- EXPLORATION QUERIES
---------------------------------------

---------------------------------------
-- Group 1 - Shape of the Data
---------------------------------------
-- How many rows total?
SELECT COUNT(*) FROM financials_raw; -- Count 161

-- How many distinct companies?
SELECT COUNT(DISTINCT "company") FROM financials_raw; -- Count 12

-- What's the year range?
SELECT MIN(year), MAX(year) FROM financials_raw; - -- Min Year 2009, Max Year 2023

-- How many rows per year? (Are some years more complete than others?)
SELECT year, COUNT(*) AS row_count
FROM financials_raw
GROUP BY year
ORDER BY year;
-- 11 Company Row Reports from Years 2009-2013
-- 12 Company Row Reports from Years 2014-2018
-- 12 Company Row Reports from Years 2019-2022
--  2 Company Row Reports from Year  2023

-- How many rows per company? (Are some companies more complete than others?)
SELECT company, COUNT(*) AS row_count
FROM financials_raw
GROUP BY company
ORDER BY row_count DESC
LIMIT 20;
-- Companies with 15 Rows - NVDA MSFT, from Years 2009-2023
-- Companies with 14 Rows - GOOG, MCD, AIG, AMZN, PCG, AAPL, INTC, BCS, from Years 2009-2023
-- Companies with 10 Rows - SHLDQ, from Years 2009-2023
-- Companies with  9 Rows - PYPL, from Years 2009-2023

---------------------------------------
-- Group 2 - Data Quality Check
---------------------------------------
-- Are there NULL values where there shouldn't be?
SELECT 
    COUNT(*) FILTER (WHERE revenue IS NULL) AS missing_revenue,
    COUNT(*) FILTER (WHERE market_cap IS NULL) AS missing_market_cap
FROM financials_raw;
-- Initial Result - missing_revenue 0
--                - missing_market_cap 161 <- Need to Investigate (possible naming issue.)
-- Changed Column to market_cap, result now - missing_market_cap 1 <- Need to Investigate
-- SELECT company, year, market_cap
-- FROM financials_raw
-- WHERE market_cap IS NULL;

-- missing_market_cap 1 - is due to PYPL (IPO timing) not an error but should be mentioned.

-- Are there duplicate company-year combinations?
SELECT company, year, COUNT(*)
FROM financials_raw
GROUP BY company, year
HAVING COUNT(*) > 1;
-- Zero Duplicates


---------------------------------------
-- Group 3 - Orientation Glance
---------------------------------------
-- Top 10 Companies by Total Revenue
SELECT company, SUM(revenue) AS total_revenue
FROM financials_raw
GROUP BY company
ORDER BY total_revenue DESC
LIMIT 10;
--  |company|total_revenue|
--  |-------|-------------|
--  |AAPL   |2,965,609    |
--  |AMZN   |2,635,460    |
--  |MSFT   |1,668,065    |
--  |GOOG   |1,556,228    |
--  |INTC   |834,929      |
--  |AIG    |827,454      |
--  |BCS    |515,288.82   |
--  |SHLDQ  |345,587      |
--  |MCD    |338,030.2    |
--  |PCG    |236,237      |


-- Revenue by year, all companies combined
SELECT year, SUM(revenue) AS yearly_total
FROM financials_raw
GROUP BY year
ORDER BY year;

--   |year |yearly_total|
--   |-----|------------|
--   |2,009|392,406.599 |
--   |2,010|441,318.115 |
--   |2,011|520,314.129 |
--   |2,012|596,125.99  |
--   |2,013|631,862.549 |
--   |2,014|679,444.45  |
--   |2,015|749,265.16  |
--   |2,016|757,164.44  |
--   |2,017|836,067.15  |
--   |2,018|971,994.23  |
--   |2,019|1,045,710.3 |
--   |2,020|1,205,720.34|
--   |2,021|1,508,525.59|
--   |2,022|1,639,070.68|
--   |2,023|238,889     |




















