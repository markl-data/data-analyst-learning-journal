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

    “Strong long term performer with noticeable volatility.”
    
MSFT → Lower CAGR, higher consistency

    “Steady compounder - not the fastest, but very reliable.”

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

/*Aggregate revenue never declined year-over-year between 2009-2022. 
 * The lowest growth year was 2016 (+1.1%). Even in 2020 (COVID), aggregate revenue grew +15.3%, suggesting the dataset
 * is heavily weighted toward secular growers (tech megacaps) whose growth dominated any cyclical 
 * or pandemic effects on the smaller/declining companies.".

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

    2020 is a valuation led boom, market cap surges faster than fundamentals.

2011 - early cycle boom

    Revenue YoY: +17.9%
    Net income YoY: +52.1%

Interpretation:

    2011 is a profit boom, driven by post crisis recovery.*/


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

→ Investors re rate the portfolio upward.
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
    
-- Interpretation of Sector Analysis
-- Sector CAGR Analysis (2009–2022)

/*Overall pattern

The sector level CAGR table shows a highly polarized growth landscape: a handful of sectors deliver explosive, 
secular growth, while others stagnate or structurally decline. 
The spread between the top and bottom sectors is extreme from +26% CAGR (Logistics) to –2.5% CAGR (Banking).

Cross Sector Insights
1. Growth is extremely concentrated

    Logistics + Technology account for almost all long term revenue expansion.
    These sectors alone explain the 4× aggregate revenue growth from 2009–2022.

2. Declining sectors don’t matter at the aggregate level

    Banking shrinks.
    SHLDQ (Finance/Retail) collapses.
    Manufacturing and Food & Beverage barely grow.

Yet aggregate revenue never declines because tech and logistics overwhelm everything else.
3. The dataset is structurally asymmetric

    Top 2 sectors: +26% and +16% CAGR
    Bottom 2 sectors: 0% and –2.5% CAGR

This is a winner‑take‑most distribution, not a balanced sector mix.
4. Electronics shows internal divergence

    NVDA behaves like a tech hyper growth name.
    INTC behaves like a mature, stagnating incumbent.

This explains the mid single digit sector CAGR.*/

-- Summary

/*    Sector CAGRs reveal a polarized growth landscape:
    Logistics and Technology are the dominant secular winners, Electronics is mixed, Manufacturing and Food & Beverage are slow growth, and Banking is structurally declining.
    The aggregate story of 2009–2022 is essentially the story of big tech and platform scale compounding overpowering weakness in legacy sectors.*/



-- Aggregate NPM over time
SELECT 
    year,
    SUM(net_income) / NULLIF(SUM(revenue), 0) * 100 AS aggregate_npm_pct
FROM financials_raw
WHERE year BETWEEN 2009 AND 2022
GROUP BY year
ORDER BY year;





------------------------------------------------------------------
-- BLOCK 1 - Question 3. Outlier Analysis
------------------------------------------------------------------
-- The Question
-- "Q3: Which companies are outliers on key metrics? Where sector-level comparison is possible 
-- 	(Technology: AAPL/GOOG/MSFT; Electronics: INTC/NVDA), do outliers reflect sector tailwinds or company-specific drivers?"

------------------------------------------------------------------
-- QUESTION 3: OUTLIERS + SECTOR PATTERNS
------------------------------------------------------------------
-- Sub-Questions:
--   A. Which companies are outliers on each headline metric (Revenue, Net Income, 
--      Market Cap, NPM)? Define "outlier" statistically using IQR or z-score.

--   B. Within the Technology sector (AAPL/GOOG/MSFT), how do the three compare?
--      Is there sector-tailwind dominance, or do individual drivers matter?

--   C. Within Electronics (INTC/NVDA), the divergent paths story - what does this 
--      tell us about sector vs company-specific factors?
--
-- Outlier Definition (Chosen Approach):
--   For each metric, compute Q1 and Q3 across the dataset

--   Outlier threshold: > Q3 + 1.5 × IQR (upper outlier) or < Q1 - 1.5 × IQR (lower outlier)

--   Apply per metric, identify which companies show up as outliers across multiple metrics



-- Q3A. Outliers across the dataset for each headline metric
-- Using IQR method: 1.5 × IQR beyond Q1/Q3 thresholds
WITH metric_stats AS (
    SELECT 
        'revenue' AS metric,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY revenue) AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY revenue) AS q3
    FROM financials_raw WHERE revenue IS NOT NULL
    UNION ALL
    SELECT 'net_income',
           PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY net_income),
           PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY net_income)
    FROM financials_raw WHERE net_income IS NOT NULL
    UNION ALL
    SELECT 'market_cap',
           PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY market_cap),
           PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY market_cap)
    FROM financials_raw WHERE market_cap IS NOT NULL
    UNION ALL
    SELECT 'net_profit_margin',
           PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY net_profit_margin),
           PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY net_profit_margin)
    FROM financials_raw WHERE net_profit_margin IS NOT NULL
)
SELECT 
    metric,
    q1,
    q3,
    q3 - q1 AS iqr,
    q3 + 1.5 * (q3 - q1) AS upper_threshold,
    q1 - 1.5 * (q3 - q1) AS lower_threshold
FROM metric_stats;
/*
|metric           |q1           |q3            |iqr           |upper_threshold|lower_threshold|
|-----------------|-------------|--------------|--------------|---------------|---------------|
|revenue          |22,820.4     |77,849        |55,028.6      |160,391.9      |-59,722.5      |
|net_income       |844          |14,136        |13,292        |34,074         |-19,094        |
|market_cap       |41.1549987793|357.1074981689|315.9524993896|831.0362472534 |-432.7737503052|
|net_profit_margin|4.8277001381 |22.9344997406 |18.1067996025 |50.0946991444  |-22.3324992657 |
*/



-- Q3B. Find rows that exceed the upper-outlier threshold for any metric
-- (replace the threshold numbers with what Q3A returned for each metric)
SELECT company, year, sector, revenue, net_income, market_cap, net_profit_margin,
       CASE WHEN revenue > 160392 THEN 'Revenue' END AS rev_outlier,
       CASE WHEN net_income > 34074 THEN 'NetIncome' END AS ni_outlier,
       CASE WHEN market_cap > 831.036 THEN 'MarketCap' END AS mc_outlier,
       CASE WHEN net_profit_margin > 50.095 THEN 'NPM' END AS npm_outlier
FROM financials_raw
WHERE revenue > 160392
   OR net_income > 34074
   OR market_cap > 831.036
   OR net_profit_margin > 50.095
ORDER BY company, year;
/*
|company|year |sector     |revenue|net_income|market_cap|net_profit_margin|rev_outlier|ni_outlier|mc_outlier|npm_outlier|
|-------|-----|-----------|-------|----------|----------|-----------------|-----------|----------|----------|-----------|
|AAPL   |2,012|Technology |156,508|41,733    |500.61    |26.6651          |           |NetIncome |          |           |
|AAPL   |2,013|Technology |170,910|37,037    |504.79    |21.6705          |Revenue    |NetIncome |          |           |
|AAPL   |2,014|Technology |182,795|39,510    |647.36    |21.6144          |Revenue    |NetIncome |          |           |
|AAPL   |2,015|Technology |233,715|53,394    |586.86    |22.8458          |Revenue    |NetIncome |          |           |
|AAPL   |2,016|Technology |215,639|45,687    |617.59    |21.1868          |Revenue    |NetIncome |          |           |
|AAPL   |2,017|Technology |229,234|48,351    |868.87    |21.0924          |Revenue    |NetIncome |MarketCap |           |
|AAPL   |2,018|Technology |265,595|59,531    |748.54    |22.4142          |Revenue    |NetIncome |          |           |
|AAPL   |2,019|Technology |260,174|55,256    |1,304.76  |21.2381          |Revenue    |NetIncome |MarketCap |           |
|AAPL   |2,020|Technology |274,515|57,411    |2,255.97  |20.9136          |Revenue    |NetIncome |MarketCap |           |
|AAPL   |2,021|Technology |365,817|94,680    |2,913.28  |25.8818          |Revenue    |NetIncome |MarketCap |           |
|AAPL   |2,022|Technology |394,328|99,803    |2,066.94  |25.3096          |Revenue    |NetIncome |MarketCap |           |
|AMZN   |2,017|Logistics  |177,866|3,033     |563.54    |1.7052           |Revenue    |          |          |           |
|AMZN   |2,018|Logistics  |232,887|10,073    |734.42    |4.3253           |Revenue    |          |          |           |
|AMZN   |2,019|Logistics  |280,522|11,588    |916.15    |4.1309           |Revenue    |          |MarketCap |           |
|AMZN   |2,020|Logistics  |386,064|21,331    |1,634.16  |5.5252           |Revenue    |          |MarketCap |           |
|AMZN   |2,021|Logistics  |469,822|33,364    |1,691     |7.1014           |Revenue    |          |MarketCap |           |
|AMZN   |2,022|Logistics  |513,983|-2,722    |856.94    |-0.5296          |Revenue    |          |MarketCap |           |
|GOOG   |2,019|Technology |161,857|34,343    |917.82    |21.2181          |Revenue    |NetIncome |MarketCap |           |
|GOOG   |2,020|Technology |182,527|40,269    |1,179.4   |22.0619          |Revenue    |NetIncome |MarketCap |           |
|GOOG   |2,021|Technology |257,637|76,033    |1,910.26  |29.5117          |Revenue    |NetIncome |MarketCap |           |
|GOOG   |2,022|Technology |282,836|59,972    |1,144.35  |21.2038          |Revenue    |NetIncome |MarketCap |           |
|MSFT   |2,019|Technology |125,843|39,240    |1,203.06  |31.1817          |           |NetIncome |MarketCap |           |
|MSFT   |2,020|Technology |143,015|44,281    |1,681.61  |30.9625          |           |NetIncome |MarketCap |           |
|MSFT   |2,021|Technology |168,088|61,271    |2,525.08  |36.4517          |Revenue    |NetIncome |MarketCap |           |
|MSFT   |2,022|Technology |198,270|72,738    |1,787.73  |36.6863          |Revenue    |NetIncome |MarketCap |           |
|MSFT   |2,023|Technology |211,915|72,361    |2,451.23  |34.1462          |Revenue    |NetIncome |MarketCap |           |
|NVDA   |2,023|Electronics|26,974 |4,368     |1,000.35  |16.1934          |           |          |MarketCap |           |
*/



-- Q3C. Find rows that fall below the lower-outlier threshold (especially for NPM)
SELECT company, year, sector, net_income, net_profit_margin
FROM financials_raw
WHERE net_income < -19094
   OR net_profit_margin < -22.33
ORDER BY company, year;
/*
|company|year |sector       |net_income|net_profit_margin|
|-------|-----|-------------|----------|-----------------|
|PCG    |2,018|Manufacturing|-6,851    |-40.8795         |
|PCG    |2,019|Manufacturing|-7,656    |-44.6961         |
*/





------------------------------------------------------------------
-- BLOCK 2 - Question 3. Technology Sector Triple Deep-Dive
------------------------------------------------------------------

-- The Premise
-- AAPL, GOOG, MSFT are three of the world's most valuable companies, in the same broad sector, with full 2009-2022 reporting. 
-- The Question: 
-- is their growth a sector tailwind (all of tech rose, these three rode it) or individual execution (each had unique drivers)?

-- Q3D. Technology sector trio: per-company per-year metrics
SELECT company, year, revenue, net_income, market_cap, net_profit_margin
FROM financials_raw
WHERE sector = 'Technology'
ORDER BY company, year;
/*
|company|year |revenue|net_income|market_cap|net_profit_margin|
|-------|-----|-------|----------|----------|-----------------|
|AAPL   |2,009|42,905 |8,235     |189.8     |19.1936          |
|AAPL   |2,010|65,225 |14,013    |296.89    |21.4841          |
|AAPL   |2,011|108,249|25,922    |376.4     |23.9466          |
|AAPL   |2,012|156,508|41,733    |500.61    |26.6651          |
|AAPL   |2,013|170,910|37,037    |504.79    |21.6705          |
|AAPL   |2,014|182,795|39,510    |647.36    |21.6144          |
|AAPL   |2,015|233,715|53,394    |586.86    |22.8458          |
|AAPL   |2,016|215,639|45,687    |617.59    |21.1868          |
|AAPL   |2,017|229,234|48,351    |868.87    |21.0924          |
|AAPL   |2,018|265,595|59,531    |748.54    |22.4142          |
|AAPL   |2,019|260,174|55,256    |1,304.76  |21.2381          |
|AAPL   |2,020|274,515|57,411    |2,255.97  |20.9136          |
|AAPL   |2,021|365,817|94,680    |2,913.28  |25.8818          |
|AAPL   |2,022|394,328|99,803    |2,066.94  |25.3096          |
|GOOG   |2,009|23,651 |6,520     |195.27    |27.5675          |
|GOOG   |2,010|29,321 |8,505     |188.54    |29.0065          |
|GOOG   |2,011|37,905 |9,737     |207.65    |25.6879          |
|GOOG   |2,012|46,039 |10,737    |230.54    |23.3215          |
|GOOG   |2,013|55,519 |12,733    |371.53    |22.9345          |
|GOOG   |2,014|66,001 |14,136    |354.75    |21.4179          |
|GOOG   |2,015|74,989 |15,826    |521.67    |21.1044          |
|GOOG   |2,016|90,272 |19,478    |530.84    |21.577           |
|GOOG   |2,017|110,855|12,662    |726.47    |11.4221          |
|GOOG   |2,018|136,819|30,736    |719.63    |22.4647          |
|GOOG   |2,019|161,857|34,343    |917.82    |21.2181          |
|GOOG   |2,020|182,527|40,269    |1,179.4   |22.0619          |
|GOOG   |2,021|257,637|76,033    |1,910.26  |29.5117          |
|GOOG   |2,022|282,836|59,972    |1,144.35  |21.2038          |
|MSFT   |2,009|58,437 |14,569    |270.64    |24.9311          |
|MSFT   |2,010|62,484 |18,760    |238.78    |30.0237          |
|MSFT   |2,011|69,943 |23,150    |218.38    |33.0984          |
|MSFT   |2,012|73,723 |16,978    |224.8     |23.0295          |
|MSFT   |2,013|77,849 |21,863    |312.3     |28.0839          |
|MSFT   |2,014|86,833 |22,074    |382.88    |25.4212          |
|MSFT   |2,015|93,580 |12,193    |443.17    |13.0295          |
|MSFT   |2,016|91,154 |20,539    |483.16    |22.5322          |
|MSFT   |2,017|96,571 |25,489    |659.91    |26.3941          |
|MSFT   |2,018|110,360|16,571    |779.67    |15.0154          |
|MSFT   |2,019|125,843|39,240    |1,203.06  |31.1817          |
|MSFT   |2,020|143,015|44,281    |1,681.61  |30.9625          |
|MSFT   |2,021|168,088|61,271    |2,525.08  |36.4517          |
|MSFT   |2,022|198,270|72,738    |1,787.73  |36.6863          |
|MSFT   |2,023|211,915|72,361    |2,451.23  |34.1462          |
*/

-- Inflection points - did all three accelerate at the same time?

-- The three companies do not accelerate at the same time. 
-- Each has its own growth curve and inflection points:

/*    AAPL

        Major acceleration: 2010 → 2012 (65B → 156B revenue)

        Secondary surge: 2020 → 2021 (274B → 365B)

        Apple’s growth is step‑wise, driven by product cycles (iPhone, Services)*/.

/*    GOOG

        Major acceleration: 2016 → 2018 (90B → 136B)

        Another surge: 2020 → 2021 (182B → 257B)

        Google’s curve is smoother, with fewer plateaus.*/

/*    MSFT

        First inflection: 2017 → 2019 (96B → 125B) — cloud era

        Second surge: 2020 → 2021 (143B → 168B)

        Microsoft accelerates later than AAPL and GOOG.*/

 -- Conclusion:

/*    The trio does not move in sync.
      Apple accelerates first (2010–12), Google next (2016–18), Microsoft last (2017–19).
      All three surge together only in 2020–2021. */
        
-- NPM divergence - how different are their margins?
        
-- Net profit margins show clear structural differences:
/*
Company	Typical NPM Range	Notes
AAPL	    ~20–26%	        Hardware + services mix; margins stable but not highest
GOOG	    ~21–29%	        Advertising economics; margins dip in 2017 (tax hit)
MSFT	   ~23–36%	        Highest margins due to cloud + software mix */
/*
Key Observations:

    MSFT has the highest margins in the sector, peaking at 36%+ in 2021–2022.

    GOOG is usually second, except for the 2017 dip (11.4%).

    AAPL has the lowest margins of the trio, but the most stable.

Conclusion:

    Microsoft is the margin leader, Google is mid‑range, Apple is stable but lower.
    The trio’s NPM divergence reflects their business models: software > ads > hardware.*/

-- Market cap timing who crossed $1T first? When did they converge?

-- Based on the dataset:

/*   AAPL crosses $1T first: 2019 (1.30T)

     MSFT crosses $1T the same year: 2019 (1.20T)

     GOOG crosses $1T in 2020 (1.18T)

Convergence:

    2020–2021: all three sit in the $1.1T–$2.9T range

    2021 is the peak convergence year:

        AAPL: 2.91T
        MSFT: 2.52T
        GOOG: 1.91T

Divergence in 2022:

    AAPL: 2.06T
    MSFT: 1.79T
    GOOG: 1.14T

Conclusion:

    Apple leads the trillion dollar race, Microsoft follows closely, Google arrives last.
    They converge in 2020–2021, then diverge again in 2022.*/
        
-- Summary Analysis
-- Summary (Technology Trio)

/*  Acceleration timing differs: Apple leads (2010–12), Google follows (2016–18), Microsoft last (2017–19).

    Margins diverge structurally: MSFT highest, GOOG mid, AAPL lowest but stable.

    Trillion‑dollar timing: AAPL first (2019), MSFT second (2019), GOOG last (2020).

    2022 correction: All three decline together; GOOG suffers the steepest valuation reset.*/
        
        
-- -- Q3E. Technology trio: YoY growth in revenue per company
WITH yoy AS (
    SELECT 
        company,
        year,
        revenue,
        LAG(revenue) OVER (PARTITION BY company ORDER BY year) AS prev_revenue,
        ROUND(100.0 * (revenue - LAG(revenue) OVER (PARTITION BY company ORDER BY year))
              / NULLIF(LAG(revenue) OVER (PARTITION BY company ORDER BY year), 0), 1) AS yoy_pct
    FROM financials_raw
    WHERE sector = 'Technology'
)
SELECT year,
       MAX(CASE WHEN company = 'AAPL' THEN yoy_pct END) AS aapl_yoy,
       MAX(CASE WHEN company = 'GOOG' THEN yoy_pct END) AS goog_yoy,
       MAX(CASE WHEN company = 'MSFT' THEN yoy_pct END) AS msft_yoy
FROM yoy
WHERE prev_revenue IS NOT NULL
GROUP BY year
ORDER BY year;

/* =================================================================================
   Q3E — Technology Trio YoY Revenue Analysis (AAPL, GOOG, MSFT) - Summary Analysis
   =================================================================================

   Sector level signals occur when all three companies move in the same
   direction; company specific signals occur when one diverges.

   1) 2010–2012: All three show strong double‑digit YoY growth.
      → Clear sector tailwind (post‑crisis digital expansion).

   2) 2016–2017: AAPL (-7.7%) and MSFT (-2.6%) slow, GOOG moderates but stays high.
      → Sector wide pause, with Apple’s decline tied to iPhone cycle softness.

   3) 2020–2021: All three accelerate sharply (AAPL +33%, GOOG +41%, MSFT +17%).
      → COVID era sector boom (cloud, ads, devices, remote work).

   4) 2022: All three decelerate together.
      → Sector correction driven by macro tightening and valuation reset.

   5) Company pecific divergences:
      - AAPL negative YoY in 2016 and 2019 while GOOG/MSFT grow → product cycle.
      - GOOG’s 2017 dip to +11% → tax hit, not sector weakness.
      - MSFT shows the smoothest YoY curve → diversified cloud/software mix.

   Overall:
      The trio exhibits synchronized booms (2010–12, 2020–21),
      synchronized slowdowns (2016–17, 2022),
      and clear company specific dips tied to product cycles or one‑off events.
*/



-- Q3F. Technology trio: NPM comparison per year
SELECT year,
       MAX(CASE WHEN company = 'AAPL' THEN net_profit_margin END) AS aapl_npm,
       MAX(CASE WHEN company = 'GOOG' THEN net_profit_margin END) AS goog_npm,
       MAX(CASE WHEN company = 'MSFT' THEN net_profit_margin END) AS msft_npm
FROM financials_raw
WHERE sector = 'Technology' AND net_profit_margin IS NOT NULL
GROUP BY year
ORDER BY year;
/* 
============================================================================
   Q3F — Technology Trio Net Profit Margin (NPM) Comparison
============================================================================

   Margin profiles differ sharply across AAPL, GOOG, and MSFT, and the data
   confirms the expected hierarchy:

   • MSFT typically has the highest margins (often 30–36%):
       Driven by software + cloud economics; peaks in 2021–2022 at ~36%.
       Only major dip is 2015 (13%) due to restructuring/one offs.

   • GOOG sits in the middle (generally 21–29%):
       High gross margins from ads but heavy R&D spend.
       2017 is the only major anomaly (11%) due to tax related charges.

   • AAPL consistently has the lowest margins (20–26%):
       Hardware mix keeps margins below GOOG/MSFT, though very stable.
       Peaks in 2012 (26.7%) and 2021 (25.9%) during strong product cycles.

   Sector‑level signals:
       - 2021 shows synchronized margin expansion across all three.
       - 2022 shows MSFT stable at high levels, GOOG compressing, AAPL steady.
       - Long run pattern: MSFT > GOOG > AAPL in nearly every year.

   Overall:
       The trio’s margin structure reflects business models:
       software > ads > hardware, with MSFT the clear profitability leader.
*/



-- Q3G. Electronics: INTC vs NVDA trajectory
SELECT year, company, revenue, net_income, market_cap
FROM financials_raw
WHERE sector = 'Electronics'
ORDER BY year, company;
-- You'll see two companies side by side over time. Look at the trajectories:

-- INTC: roughly flat / mildly growing over 13 years
-- NVDA: massively growing, particularly in later years
/* 
 ============================================================================
   Q3G — Electronics Sector Divergence: INTC vs NVDA
 ============================================================================

   INTC and NVDA share the same sector label ("Electronics / Semiconductors")
   but their trajectories from 2009–2023 are completely opposite.

   • INTC:
       Revenue roughly flat (35B → 63B), mild growth but no breakout.
       Net income stable but stagnant; peaks in 2018–2019 then declines sharply.
       Market cap oscillates between 100B–260B with no structural upward trend.
       → Classic incumbent pattern: mature CPU business, missed major growth waves.

   • NVDA:
       Revenue explodes (3.4B → 26.9B), especially post 2016.
       Net income surges from losses to multi billion profitability.
       Market cap jumps from ~10B to over 1T by 2023.
       → Captures GPU, gaming, data center, and AI acceleration cycles.

   • Sector insight:
       Same sector, opposite outcomes - NVDA is a hyper growth outlier,
       INTC is a stagnating incumbent. This is the clearest example in the
       dataset of why sector level analysis can hide company specific realities.

   Overall:
       INTC vs NVDA is a textbook divergence: CPUs plateau, GPUs dominate.
       NVDA rides structural megatrends; INTC misses them.
*/


SELECT year, COUNT(DISTINCT company), SUM(market_cap) AS total_mc
FROM financials_raw
WHERE year IN (2022, 2023)
GROUP BY year;



