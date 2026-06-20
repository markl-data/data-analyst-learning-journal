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

--   |year | yearly_total|
--   |-----| ------------|
--   |2,009| 392,406.599 |
--   |2,010| 441,318.115 |
--   |2,011| 520,314.129 |
--   |2,012| 596,125.99  |
--   |2,013| 631,862.549 |
--   |2,014| 679,444.45  |
--   |2,015| 749,265.16  |
--   |2,016| 757,164.44  |
--   |2,017| 836,067.15  |
--   |2,018| 971,994.23  |
--   |2,019| 1,045,710.3 |
--   |2,020| 1,205,720.34|
--   |2,021| 1,508,525.59|
--   |2,022| 1,639,070.68|
--   |2,023| 238,889     |

-- Column Breakdown - Name & Data Type
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'financials_raw'
ORDER BY ordinal_position;

-- Step 1 - Result of Column Breakdown - Full Schema
/*|column_name                        |data_type        |
|-----------------------------------|-----------------|
|year                               |integer          |
|category                           |text             |
|revenue                            |numeric          |
|ebitda                             |numeric          |
|roe                                |numeric          |
|roa                                |numeric          |
|roi                                |numeric          |
|company                            |character varying|
|market_cap                         |real             |
|gross_profit                       |real             |
|net_income                         |real             |
|earning_per_share                  |real             |
|share_holder_equity                |real             |
|cash_flow_from_operating           |real             |
|cash_flow_from_investing           |real             |
|cash_flow_from_financial_activities|real             |
|current_ratio                      |real             |
|debt_equity_ratio                  |real             |
|net_profit_margin                  |real             |
|free_cash_flow_per_share           |real             |
|return_on_tangible_equity          |real             |
|number_of_employees                |integer          |
|inflation_rate                     |real             |*/


-- Step 2 - Sample Values
SELECT * FROM financials_raw LIMIT 5;
-- Identified naming issue in regards to columns - for instance gross_profit values are null while Gross Profit are present

-- Step 3 - Headline Metric Section
-- 2-4 Headline Metrics Key to Understand Dataset

-- 1. Revenue (Top Line Growth)
-- 2. Operating Cash Flow
-- 3. Market Cap
-- 4. EPS

-- ** Distinct Categories Issue Identified **
-- 1. "Bank" and "BANK" are duplicate categories with different casing the same sector represented two ways
-- 2. Mixed naming conventions some are full words (Finance, Manufacturing), some are abbreviations (ELEC, LOGI, IT)
-- Need to Clean Data & Address this issue.

-- -- Sector lookup: convert raw category to clean sector name
SELECT 
    category,
    COUNT(*) AS row_count,
    COUNT(DISTINCT company) AS company_count
FROM financials_raw
GROUP BY category
ORDER BY category;

-- -- Identify what Companies are in each Distinct Category
SELECT category, STRING_AGG(DISTINCT company, ', ') AS companies
FROM financials_raw
GROUP BY category
ORDER BY category;

-- Create a normalised sector column via CASE
SELECT 
    company,
    category,
    CASE 
        WHEN UPPER(category) = 'BANK' THEN 'Banking'
        WHEN category = 'Finance' THEN 'Finance'  
        WHEN category = 'FinTech' THEN 'FinTech'  
        WHEN category = 'ELEC' THEN 'Electronics'
        WHEN category = 'IT' THEN 'Technology'
        WHEN category = 'FOOD' THEN 'Food & Beverage'
        WHEN category = 'LOGI' THEN 'Logistics'
        WHEN category = 'Manufacturing' THEN 'Manufacturing'
        ELSE category
    END AS sector
FROM financials_raw;

-- Decided to make sector column permanent for ease of understanding Dataset.
-- Add the sector column
ALTER TABLE financials_raw ADD COLUMN sector text;

-- -- Populate sector with Data
UPDATE financials_raw 
SET sector = CASE 
    WHEN UPPER(category) = 'BANK' THEN 'Banking'
    WHEN category = 'Finance' THEN 'Finance'
    WHEN category = 'FinTech' THEN 'FinTech'
    WHEN category = 'ELEC' THEN 'Electronics'
    WHEN category = 'IT' THEN 'Technology'
    WHEN category = 'FOOD' THEN 'Food & Beverage'
    WHEN category = 'LOGI' THEN 'Logistics'
    WHEN category = 'Manufacturing' THEN 'Manufacturing'
    ELSE category
END;

-- -- Verify Data
SELECT category, sector, COUNT(*) 
FROM financials_raw 
GROUP BY category, sector 
ORDER BY sector;

---------------------------------------
-- EXPLORATION QUERIES
---------------------------------------

---------------------------------------
-- Group 2 - COMPLETENESS FINDINGS
---------------------------------------

-- Revenue: X/161 populated, Y missing
-- Net Income: X/161 populated, Y missing
-- Market Cap: X/161 populated, Y missing (PYPL pre-IPO accounts for some)
-- Net Profit Margin: X/161 populated, Y missing

-- Step 1
-- For each Metric above get the spread/range/distribution
-- Revenue range and distribution - Distribution Summary using UNION ALL(keeps everything)
-- Union (Removes Duplicates.)
SELECT 'revenue' AS metric, MIN(revenue) AS min_value, MAX(revenue) AS max_value, AVG(revenue) AS avg_value,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY revenue) AS median_value,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY revenue) AS q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY revenue) AS q3
FROM financials_raw
WHERE revenue IS NOT NULL

UNION ALL

SELECT 
    'net_income', MIN(net_income), MAX(net_income), AVG(net_income),
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY net_income),
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY net_income),
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY net_income)
FROM financials_raw
WHERE net_income IS NOT NULL

UNION ALL

SELECT 
    'market_cap', MIN(market_cap), MAX(market_cap), AVG(market_cap),
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY market_cap),
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY market_cap),
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY market_cap)
FROM financials_raw
WHERE market_cap IS NOT NULL

UNION ALL

SELECT 
    'net_profit_margin', MIN(net_profit_margin), MAX(net_profit_margin), AVG(net_profit_margin),
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY net_profit_margin),
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY net_profit_margin),
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY net_profit_margin)
FROM financials_raw
WHERE net_profit_margin IS NOT NULL;

-- Step 2
-- VALUE-RANGE FINDINGS:
-- Revenue: range $3,326 to $513,983, median $45,992, mean $75,863
--   → Right Skewed: a small number of very large companies (AAPL/MSFT type firms) pull the mean far above the median. 
-- Most companies sit in the €20–80K band, but a few giants stretch the upper tail.

-- Net Income: range -$12,244 to $99,803, median $4,758, mean $12,277
--   → The presence of negative values indicates loss making years for some firms.
-- The median is low relative to the mean, 
-- meaning a few highly profitable companies inflate the average while many operate close to breakeven.

-- Market Cap: range $0.04B to $2,913B, median $113.14B, mean $337.60B
--   → Extremely right skewed: mega caps (Apple, Microsoft, Amazon) dominate the distribution.
-- The median is only ⅓ of the mean, showing how a handful of trillion dollar firms distort the overall picture.

-- Net Profit Margin: range –44.7% to 36.7%, median 15.3%, mean 13.7%
--   → Wide dispersion: some firms run deep negative margins, while others achieve exceptionally high profitability.
-- The median > mean suggests the negative outliers drag the average down.

-- All four metrics show strong right skew: 
-- a small number of extremely large or profitable firms dominate the distribution, 
-- while the majority cluster in the lower to mid ranges. 
-- Loss making years and negative margins are present but not typical.




-- Step 3
-- Per Company Completeness - Find Data Gaps (if any.)
SELECT company, sector, COUNT(*) AS total_year_rows, COUNT(revenue) AS revenue_years,
    COUNT(net_income) AS net_income_years, COUNT(market_cap) AS market_cap_years,
    COUNT(net_profit_margin) AS npm_years, MIN(year) AS first_year, MAX(year) AS last_year
FROM financials_raw
GROUP BY company, sector
ORDER BY company;

-- 1. Companies where the year span does NOT reach back to 2009
-- Result: Only two companies fail the 2009–2022/23 coverage requirement:
-- PYPL - first year 2014  → Expected: PayPal IPO’d mid 2010s, so earlier financials do not exist.
-- SHLDQ - last year 2018  → Expected: Sears filed for bankruptcy in 2018; reporting stops thereafter.

-- 2. Companies with metric gaps within their year span
-- Result: Only one company shows a metric gap:
-- PYPL - total_year_rows = 9, market_cap_years = 8 → 1 missing market_cap value 

-- 3. Companies whose row count does NOT match their year span
-- Result: Every company has one row per year within its active reporting window.
-- No internal gaps exist.

-- Summary
/*  The dataset is extremely clean.  
    Only PYPL and SHLDQ have shortened year spans due to IPO and bankruptcy timing.
    PYPL has one expected market_cap gap.
    No company has missing years inside its reporting window.*/




-- Step 4
-- Sanity Check - Net Profit Margin - Percentage in the Data or Ratio?
-- Check the format of Net Profit Margin
SELECT company, year, net_income, revenue, net_profit_margin,
       ROUND( (net_income / NULLIF(revenue, 0) * 100)::numeric, 2) AS computed_npm_pct
FROM financials_raw
WHERE net_profit_margin IS NOT NULL
ORDER BY company, year
LIMIT 20;

-- NPM FORMAT CHECK:
-- net_profit_margin is stored as [percentage]
-- Example: AAPL 2022 stored value = 4.8277, computed = 4.83 → consistent.

-- Loss Years
SELECT company, COUNT(*) AS loss_years, MIN(year) AS first_loss, MAX(year) AS last_loss
FROM financials_raw
WHERE net_income < 0
GROUP BY company
ORDER BY loss_years DESC;
-- Output
/*|company|loss_years|first_loss|last_loss|
  |-------|----------|----------|---------|
  |SHLDQ  |7         |2,012     |2,018    |
  |AIG    |5         |2,009     |2,020    |
  |BCS    |4         |2,012     |2,017    |
  |PCG    |4         |2,018     |2,021    |
  |AMZN   |3         |2,012     |2,022    |
  |NVDA   |2         |2,009     |2,010    |*/






-- CAGR - Compound Annual Growth Rate
-- Adapt to each company as opposed to years due to different year spans.
-- A1 — Each company's CAGR computed across its own actual reporting span
WITH company_bounds AS (
    SELECT 
        company,
        sector,
        MIN(year) AS first_year,
        MAX(year) AS last_year,
        MAX(year) - MIN(year) AS span_years
    FROM financials_raw
    WHERE revenue IS NOT NULL
    GROUP BY company, sector
),
revenue_at_bounds AS (
    SELECT 
        cb.company,
        cb.sector,
        cb.first_year,
        cb.last_year,
        cb.span_years,
        (SELECT revenue FROM financials_raw f WHERE f.company = cb.company AND f.year = cb.first_year) AS first_revenue,
        (SELECT revenue FROM financials_raw f WHERE f.company = cb.company AND f.year = cb.last_year) AS last_revenue
    FROM company_bounds cb
)
SELECT 
    company,
    sector,
    first_year,
    last_year,
    span_years,
    first_revenue,
    last_revenue,
    ROUND((last_revenue - first_revenue)::numeric, 0) AS absolute_growth,
    ROUND((last_revenue / NULLIF(first_revenue, 0))::numeric, 2) AS growth_multiple,
    ROUND(((POWER(last_revenue / NULLIF(first_revenue, 0), 1.0 / NULLIF(span_years, 0)) - 1) * 100)::numeric, 1) AS cagr_pct
FROM revenue_at_bounds
ORDER BY cagr_pct DESC NULLS LAST;
-- Uses each companies start and end years, not hard coded 2009-2022
-- NULLIF guard against divide by zero.
-- Returns absolute growth & CAGR.

-- Output
/*|company|sector         |first_year|last_year|span_years|first_revenue|last_revenue|absolute_growth|growth_multiple|cagr_pct|
  |-------|---------------|----------|---------|----------|-------------|------------|---------------|---------------|--------|
  |AMZN   |Logistics      |2,009     |2,022    |13        |24,509       |513,983     |489,474        |20.97          |26.4    |
  |GOOG   |Technology     |2,009     |2,022    |13        |23,651       |282,836     |259,185        |11.96          |21      |
  |AAPL   |Technology     |2,009     |2,022    |13        |42,905       |394,328     |351,423        |9.19           |18.6    |
  |PYPL   |FinTech        |2,014     |2,022    |8         |8,025        |27,518      |19,493         |3.43           |16.7    |
  |NVDA   |Electronics    |2,009     |2,023    |14        |3,424.859    |26,974      |23,549         |7.88           |15.9    |
  |MSFT   |Technology     |2,009     |2,023    |14        |58,437       |211,915     |153,478        |3.63           |9.6     |
  |INTC   |Electronics    |2,009     |2,022    |13        |35,127       |63,054      |27,927         |1.8            |4.6     |
  |PCG    |Manufacturing  |2,009     |2,022    |13        |13,399       |21,680      |8,281          |1.62           |3.8     |
  |MCD    |Food & Beverage|2,009     |2,022    |13        |22,744.7     |23,182.6    |438            |1.02           |0.1     |
  |AIG    |Banking        |2,009     |2,022    |13        |75,447       |56,437      |-19,010        |0.75           |-2.2    |
  |BCS    |Banking        |2,009     |2,022    |13        |45,992.04    |30,868.08   |-15,124        |0.67           |-3      |
  |SHLDQ  |Finance        |2,009     |2,018    |9         |46,770       |16,702      |-30,068        |0.36           |-10.8   |*/

-- Findings/Surprises in Data Output.
-- Decrease in Banking Sector despite economic growth throughout the financial industry (-3 cagr_pct)
-- AIG initial first_revenue of 75,447 is the highest of all the companies in the dataset.
-- The level of growth from AMZN is enormous in comparison to already massive companies.