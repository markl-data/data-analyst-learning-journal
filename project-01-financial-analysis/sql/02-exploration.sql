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



