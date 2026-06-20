-----------------------------------------------------------
-- BLOCK 1 - Continued. NVDA Fair Comparison + Consistency
-----------------------------------------------------------

-- Step 1 - NVDA 2009-2022 fair comparison
-- NVDA Computed over 14 years, while everyone else was 13.
-- Correct & Apply Fair Basis.
-- A1b. NVDA fair comparison: 2009-2022 to match other companies' window
SELECT company, 2009 AS first_year, 2022 AS last_year,
    (SELECT revenue FROM financials_raw WHERE company = 'NVDA' AND year = 2009) AS first_rev,
    (SELECT revenue FROM financials_raw WHERE company = 'NVDA' AND year = 2022) AS last_rev,
    (SELECT revenue FROM financials_raw WHERE company = 'NVDA' AND year = 2023) AS rev_2023,
    -- CAGR over 2009-2022 (13 years like the others)
    ROUND(
        ((POWER((SELECT revenue FROM financials_raw WHERE company = 'NVDA' AND year = 2022)::numeric 
          / (SELECT revenue FROM financials_raw WHERE company = 'NVDA' AND year = 2009)::numeric, 1.0 / 13
          ) - 1) * 100)::numeric, 1) AS cagr_2009_2022_pct
FROM (SELECT 'NVDA' AS company) AS dummy;

-- NVDA METHODOLOGY NOTE:
-- 2009-2023 (14 years): CAGR = 15.9% (02-exploration.sql)
-- 2009-2022 (13 years, matches others): CAGR = 17.2%
-- 2023 single-year change from 2022: $26,914 to $26,974, representing 1.30% YoY growth
-- Interpretation: NVDA's headline CAGR is materially affected by usage of 14 years vs. 13 years with a 1.30% YoY growth difference, 
-- by inclusion of the 2023 AI/GPU breakout year.




-- Step 2 - Consistency Scoring
-- CAGR = Who Growth the Most.
-- Consistency = Who Grew most Reliably.
-- A2. Year-over-year growth consistency per company
WITH yoy AS (
    SELECT company, sector, year, revenue,
        LAG(revenue) OVER (PARTITION BY company ORDER BY year) AS prev_revenue,
        CASE 
            WHEN LAG(revenue) OVER (PARTITION BY company ORDER BY year) IS NULL THEN NULL
            WHEN revenue > LAG(revenue) OVER (PARTITION BY company ORDER BY year) THEN 1 
            ELSE 0 
        END AS grew_yoy
    FROM financials_raw
    WHERE revenue IS NOT NULL
)
SELECT company, sector, SUM(grew_yoy) AS years_of_growth,
    COUNT(grew_yoy) AS total_yoy_comparisons,
    ROUND(100.0 * SUM(grew_yoy) / COUNT(grew_yoy), 1) AS consistency_pct
FROM yoy
GROUP BY company, sector
ORDER BY consistency_pct DESC;
-- Results - Interpretation
-- Three Companies, GOOG, PYPL, AMZN - Consistency % of 100%
-- Three Companies, SHLDQ, AIG, BCS - Consistency % Ranging from 0% to 38.50%

-- One Company, NVDA - 5th Largest CAGR (15.90%) yet Consistency % of 78.60% (indicating huge short term growth.)




------------------------------------------------------------------
-- BLOCK 2 - Continued. Composite Ranking + Bottom 3 Deep Dive
------------------------------------------------------------------
-- Step 1 - Composite Ranking
-- Combine CAGR & Consistency %
-- A3. Combined ranking: growth + consistency
WITH base AS (
    select company, sector, year, revenue
    FROM financials_raw
    WHERE revenue IS NOT NULL
),

cagr_calc AS (
    select b1.company, b1.sector,
        MIN(b1.year) AS first_year,
        MAX(b1.year) AS last_year,
        MAX(b1.year) - MIN(b1.year) AS span_years,
        -- first revenue in series
        (
            SELECT b2.revenue
            FROM base b2
            WHERE b2.company = b1.company
            ORDER BY b2.year ASC
            LIMIT 1
        ) AS first_rev,
        -- last revenue in series
        (
            SELECT b3.revenue
            FROM base b3
            WHERE b3.company = b1.company
            ORDER BY b3.year DESC
            LIMIT 1
        ) AS last_rev
    FROM base b1
    GROUP BY b1.company, b1.sector
),

consistency_calc AS (
    SELECT
        company,
        ROUND(
            100.0 * SUM(CASE WHEN revenue > prev_revenue THEN 1 ELSE 0 END)
            / NULLIF(COUNT(prev_revenue), 0),
            1
        ) AS consistency_pct
    FROM (
        select company, year, revenue,
            LAG(revenue) OVER (PARTITION BY company ORDER BY year) AS prev_revenue
        FROM base
    ) t
    WHERE prev_revenue IS NOT NULL
    GROUP BY company
),

metrics AS (
    SELECT
        c.company,
        c.sector,
        ROUND(
            (POWER(c.last_rev / NULLIF(c.first_rev, 0), 1.0 / NULLIF(c.span_years, 0)) - 1) * 100,
            1
        ) AS cagr_pct,
        co.consistency_pct
    FROM cagr_calc c
    JOIN consistency_calc co
        ON c.company = co.company
)

SELECT
    m.company,
    m.sector,
    m.cagr_pct,
    m.consistency_pct,
    RANK() OVER (ORDER BY m.cagr_pct DESC) AS cagr_rank,
    RANK() OVER (ORDER BY m.consistency_pct DESC) AS consistency_rank,
    RANK() OVER (ORDER BY m.cagr_pct DESC)
      + RANK() OVER (ORDER BY m.consistency_pct DESC) AS composite_rank
FROM metrics m
ORDER BY composite_rank;
-- Results - Interpretation
-- Top Composite Rank - AMZN - High Growth & Consistency
-- Bottom Composite Rank - SHLDQ - Low Growth & Poor Consistency
-- Rank Divergence - 1. AAPL — Big divergence (CAGR 3rd vs Consistency 5th → gap = 2)

/*AAPL grows fast but not smoothly.

    CAGR rank: 3rd

    Consistency rank: 5th

    Interpretation:
    Apple has strong long term growth, but more year to year volatility than the top‑tier consistent growers 
    (AMZN, GOOG, PYPL, MSFT).
    This is a classic “high performer with bumps.”*/

-- One Company, NVDA - 5th Largest CAGR (15.90%) yet Consistency % of 78.60% (indicating huge short term growth.)

-- Most interesting divergences (the real story)
/*AAPL → High CAGR, lower consistency

    “Strong long‑term performer with noticeable volatility.”
    
MSFT → Lower CAGR, higher consistency

    “Steady compounder — not the fastest, but very reliable.”

NVDA → High CAGR, slightly lower consistency

    “Fast grower with cyclical swings.”

These three are the true divergence cases worth highlighting in your findings.*/




-- Step 2 - Bottom-3 Deep Dive 
-- B1. Each bottom-3 company, show peak year and trough year
WITH ranked AS (
    SELECT company, year, revenue,
        RANK() OVER (PARTITION BY company ORDER BY revenue DESC) AS peak_rank,
        RANK() OVER (PARTITION BY company ORDER BY revenue ASC) AS trough_rank
    FROM financials_raw
    WHERE company IN ('SHLDQ', 'BCS', 'AIG')  -- adjust to your actual bottom 3
      AND revenue IS NOT NULL
)
SELECT company,
       MAX(CASE WHEN peak_rank = 1 THEN year END) AS peak_year,
       MAX(CASE WHEN peak_rank = 1 THEN revenue END) AS peak_revenue,
       MAX(CASE WHEN trough_rank = 1 THEN year END) AS trough_year,
       MAX(CASE WHEN trough_rank = 1 THEN revenue END) AS trough_revenue
FROM ranked
GROUP BY company
ORDER BY company;

-- B2. Full multi-year revenue + net_income profile for bottom 3
SELECT company, year, revenue, net_income, market_cap
FROM financials_raw
WHERE company IN ('SHLDQ', 'BCS', 'AIG')
ORDER BY company, year;





------------------------------------------------------------------
-- BLOCK 4 - Question 2. Time-Series Patterns + Inflection Points
------------------------------------------------------------------
--   Q2: How have key financial metrics (revenue, margins, market cap) trended across the dataset? 
-- Cont: What inflection points are visible (post-2008 recovery, COVID impact, tech boom periods)?

-- QUESTION 2: TIME-SERIES PATTERNS
-- Sub-questions:
--   A. How has aggregate revenue/profit/market cap trended across 2009-2022?
--   B. What years stand out as inflection points (sharp changes)?
--   C. Do specific events align with the inflection points?
--      - Post-2009: recovery from financial crisis
--      - 2014-2016: oil price collapse, China growth slowdown
--      - 2020: COVID
--      - 2022: rate hikes, tech correction
--
-- Approach:
--   1. Aggregate revenue per year across all 12 companies - see the overall trend
--   2. YoY growth rate per year - surface inflection points
--   3. Same for net_income (different inflections expected)
--   4. Per-sector trends - to see if some sectors led/lagged

-- Q2A. Aggregate trend across all companies per year
SELECT 
    year,
    COUNT(DISTINCT company) AS companies_reporting,
    SUM(revenue) AS total_revenue,
    SUM(net_income) AS total_net_income,
    SUM(market_cap) AS total_market_cap,
    AVG(net_profit_margin) AS avg_npm
FROM financials_raw
WHERE year BETWEEN 2009 AND 2022
GROUP BY year
ORDER BY year;

-- Shape of Total Revenue (Smooth vs Step Wise)

/*Total revenue moves in clear step wise jumps, not a smooth curve.
Step pattern:
    2009 → 2011: strong upward steps (392B → 520B)
    2012 → 2014: continued growth but with a dip in 2012 NPM
    2015 → 2017: plateauing, small steps
    2018 → 2020: large upward steps (971B → 1.2T)
    2021 → 2022: another big step (1.5T → 1.64T)

Interpretation
    Total revenue grows in discrete jumps, driven by the tech mega‑caps (AAPL, AMZN, GOOG, MSFT, NVDA).
    This is not a smooth compounding curve it’s a staircase, each step corresponding to a strong year for the tech sector.*/

-- Years Where Total Revenue Fell

/*There is only one revenue decline in the entire dataset:
2011 → 2012

    520B → 596B → no decline  
    Actually, revenue never falls the dataset.

Interpretation

    Total revenue never declines, even in recession years (2012, 2016, 2020).
    This means the aggregate portfolio is dominated by secular growers, 
    mainly big tech whose growth outweighs declines in banks, retailers, or cyclicals.*/


-- Net Income vs Revenue (NPM Compression or Expansion)
-- Revenue grows every year, but net income does not.

/*Let’s look at total net income:

    2009 → 2011: strong expansion (33B → 105B)
    2012: sharp drop (105B → 85B)
    2013–2016: recovery and stabilisation
    2017: drop (98B)
    2018–2020: strong expansion (143B → 190B)
    2021: massive jump (319B)
    2022: drop (274B)*/

/*Interpretation

    Net income is more volatile than revenue.
    NPM compresses in 2012 and 2017, and expands strongly in 2020–2021.
    This shows that profitability cycles are not perfectly aligned with revenue cycles margins swing more dramatically.*/




-- Q2B. Year-over-year growth rate of aggregate metrics
WITH yearly_totals AS (
    SELECT 
        year,
        SUM(revenue) AS total_revenue,
        SUM(net_income) AS total_net_income,
        SUM(market_cap) AS total_market_cap
    FROM financials_raw
    WHERE year BETWEEN 2009 AND 2022
    GROUP BY year
),
with_lags AS (
    SELECT
        year,
        total_revenue,
        total_net_income,
        total_market_cap,
        LAG(total_revenue)    OVER (ORDER BY year) AS prev_rev,
        LAG(total_net_income) OVER (ORDER BY year) AS prev_income,
        LAG(total_market_cap) OVER (ORDER BY year) AS prev_mcap
    FROM yearly_totals
)
SELECT
    year,
    total_revenue,
    ROUND(
        ( (total_revenue - prev_rev) / NULLIF(prev_rev, 0) * 100 )::numeric
    , 1) AS revenue_yoy_pct,
    ROUND(
        ( (total_net_income - prev_income) / NULLIF(prev_income, 0) * 100 )::numeric
    , 1) AS net_income_yoy_pct,
    ROUND(
        ( (total_market_cap - prev_mcap) / NULLIF(prev_mcap, 0) * 100 )::numeric
    , 1) AS market_cap_yoy_pct
FROM with_lags
ORDER BY year;

-- 1. Systemic negative YoY events (broad stress signals)

/*Look for years where multiple metrics show negative YoY.
2022 — the only true systemic downturn

    Net income YoY: –14.1%
    Market cap YoY: –36.2%
    Revenue YoY: still +8.7% (but sharply decelerated)

Interpretation:

    2022 is the only year where profitability and valuation collapse together, despite revenue still growing.
    This is a classic macro tightening / risk off year: margins compress, multiples contract.

No other year shows multi‑metric contraction

    Revenue never goes negative
    Market cap dips in isolated years (2013, 2018), but not with revenue
    Net income dips in 2012 and 2017, but revenue still grows

Conclusion:

    2022 is the only systemic stress event in the dataset*/

-- 2. Boom periods (massive positive jumps)

/*Look for years with double‑digit growth across multiple metrics.
2021 - the biggest boom

    Revenue YoY: +25.1%

    Net income YoY: +67.5%

    Market cap YoY: +35.9%

Interpretation:

    2021 is a synchronized boom: revenue, profits, and valuation all explode upward.
    This is the strongest year in the entire dataset.

2020 - pre boom acceleration

    Revenue YoY: +15.3%
    Net income YoY: +9.6%
    Market cap YoY: +50.6%

Interpretation:

    2020 is a valuation‑led boom, market cap surges faster than fundamentals.

2011 - early cycle boom

    Revenue YoY: +17.9%
    Net income YoY: +52.1%

Interpretation:

    2011 is a profit‑led boom, driven by post‑crisis recovery.*/


-- 3. Revenue vs Net Income Divergences (margin compression / expansion)
/*Margin Compression Years (revenue up, net income down)
2012

    Revenue YoY: +14.6%
    Net income YoY: –18.4%

→ Severe margin compression - revenue rises but profits collapse.
2017

    Revenue YoY: +10.4%
    Net income YoY: –7.7%

→ Profitability deteriorates despite healthy revenue growth.
2022

    Revenue YoY: +8.7%
    Net income YoY: –14.1%

→ Late cycle squeeze: revenue slows, margins fall sharply.
Margin Expansion Years (net income grows faster than revenue)
2010–2011

    Net income YoY: +105.6%, +52.1%
    Revenue YoY: +12.5%, +17.9%

→ Early cycle profit surge.
2018

    Revenue YoY: +16.3%
    Net income YoY: +45.6%

→ Strong margin expansion.
2021

    Revenue YoY: +25.1%
    Net income YoY: +67.5%

→ Peak profitability expansion.*/

-- 4. Revenue vs Market Cap Divergences (valuation regime shifts)
/*Multiple Compression (market cap lags revenue)
2018

    Revenue YoY: +16.3%
    Market cap YoY: +3.1%

→ Revenue surges but valuations barely move → early compression.
2022

    Revenue YoY: +8.7%
    Market cap YoY: –36.2%

→ Massive multiple contraction → regime shift.
Multiple Expansion (market cap outpaces revenue)
2013

    Revenue YoY: +6%
    Market cap YoY: +25.5%

→ Investors re‑rate the portfolio upward.
2020

    Revenue YoY: +15.3%
    Market cap YoY: +50.6%

→ Extreme expansion valuations run ahead of fundamentals.
2021

    Revenue YoY: +25.1%
    Market cap YoY: +35.9%

→ Strong expansion continues.*/


-- Summary
/*Systemic downturn:  
→ 2022 is the only year where profitability and valuation fall together.

Boom periods:  
→ 2021 (synchronized boom), 2020 (valuation boom), 2011 (profit boom).

Margin cycles:  
→ Compression in 2012, 2017, 2022; expansion in 2010–11, 2018, 2021.

Valuation regime shifts:  
→ Expansion in 2013, 2020, 2021; compression in 2018, 2022.*/





------------------------------------------------------------------
-- BLOCK 5 - Question 2. Sector Trends + Loss Clustering
------------------------------------------------------------------
-- Q2C. Sector-level revenue trends
SELECT 
    sector,
    year,
    SUM(revenue) AS sector_revenue,
    COUNT(DISTINCT company) AS companies_in_sector
FROM financials_raw
WHERE year BETWEEN 2009 AND 2022
  AND revenue IS NOT NULL
GROUP BY sector, year
ORDER BY sector, year;


-- Q2D. Sector CAGR over 2009-2022 (for sectors with enough data)
WITH sector_bounds AS (
    SELECT 
        sector,
        SUM(CASE WHEN year = 2009 THEN revenue END) AS sector_2009,
        SUM(CASE WHEN year = 2022 THEN revenue END) AS sector_2022,
        COUNT(DISTINCT company) AS company_count
    FROM financials_raw
    WHERE year IN (2009, 2022)
    GROUP BY sector
)
SELECT 
    sector,
    company_count,
    sector_2009,
    sector_2022,
    ROUND(sector_2022::numeric / NULLIF(sector_2009, 0)::numeric, 2) AS growth_multiple,
    ROUND(((POWER(sector_2022::numeric / NULLIF(sector_2009, 0)::numeric, 1.0/13) - 1) * 100)::numeric, 1) AS sector_cagr_pct
FROM sector_bounds
WHERE sector_2009 > 0 AND sector_2022 > 0
ORDER BY sector_cagr_pct DESC;


-- Q2D. Sector CAGR over 2009-2022 (for sectors with enough data)
WITH sector_bounds AS (
    SELECT 
        sector,
        SUM(CASE WHEN year = 2009 THEN revenue END) AS sector_2009,
        SUM(CASE WHEN year = 2022 THEN revenue END) AS sector_2022,
        COUNT(DISTINCT company) AS company_count
    FROM financials_raw
    WHERE year IN (2009, 2022)
    GROUP BY sector
)
SELECT 
    sector,
    company_count,
    sector_2009,
    sector_2022,
    ROUND(sector_2022::numeric / NULLIF(sector_2009, 0)::numeric, 2) AS growth_multiple,
    ROUND(((POWER(sector_2022::numeric / NULLIF(sector_2009, 0)::numeric, 1.0/13) - 1) * 100)::numeric, 1) AS sector_cagr_pct
FROM sector_bounds
WHERE sector_2009 > 0 AND sector_2022 > 0
ORDER BY sector_cagr_pct DESC;



-- Q2E. Loss-year frequency by year
SELECT 
    year,
    COUNT(*) AS total_companies,
    SUM(CASE WHEN net_income < 0 THEN 1 ELSE 0 END) AS companies_with_losses,
    SUM(net_income) AS aggregate_net_income
FROM financials_raw
WHERE year BETWEEN 2009 AND 2022
GROUP BY year
ORDER BY year;
    
    
    