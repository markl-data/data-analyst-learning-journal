## SCHEMA CLEANUP (Day 18, Block 2): 
- The Kaggle CSV loaded with duplicate columns: an empty snake_case set
- and a populated Title Case set. The snake_case empties were dropped,
- and the Title Case populated columns were renamed to snake_case for
- SQL clarity. The "Debt/Equity Ratio" column was renamed to 
- "debt_equity_ratio" (slash removed for compatibility).

## Data preparation

- Column names normalised from mixed Title Case to snake_case
- Empty duplicate columns dropped from initial CSV load
- Sector taxonomy normalised: original `category` column had inconsistent 
  casing (Bank/BANK) and mixed abbreviation/full-word conventions. 
  A clean `sector` column was added with the following mapping: 
  [your mapping].

## Question 1: Cross-company performance

### Top performers by CAGR (2009-2022 except where noted)
1. AMZN - 26.4% CAGR (Logistics) — revenue $24.5B → $514B
2. GOOG - 21.0% CAGR (Technology)
3. AAPL - 18.6% CAGR (Technology)
4. PYPL - 16.7% CAGR (FinTech, partial period 2014-2022)
5. NVDA - 15.9% CAGR (Electronics, span 2009-2023, see methodology note)

### Bottom performers by CAGR
1. SHLDQ — -10.8% CAGR (Finance/Retail) - full collapse to bankruptcy by 2018
2. BCS — -3.0% CAGR (Banking) - post-crisis European bank shrinkage
3. AIG — -2.2% CAGR (Banking) - bailout aftermath; was largest in 2009 dataset

### Bottom-3 risk profile (initial observations)
- All three are financial sector or financial-categorised
- SHLDQ stands apart: actively dying, 7 of 9 reporting years were loss-making
- AIG and BCS: persistent low-growth/decline rather than collapse
- Two distinct decline patterns: catastrophic (SHLDQ) vs structural (AIG, BCS)

### Loss-year patterns — the senior distinction
- Loss years from growth investment: AMZN (3 years, deliberate reinvestment)
- Loss years from market downturn: NVDA (2009-2010 financial crisis trough)
- Loss years from structural distress: AIG (5 chronic loss years), BCS (4)
- Loss years from business failure: SHLDQ (7 of 9 reporting years)

### Surprises and observations
- Banking sector decline despite broader economic recovery - banks shrank precisely because they had to deleverage
- AIG was the largest company in the dataset by 2009 revenue; lost 25% of revenue over 13 years
- AMZN added more revenue in 13 years (~$489B) than MSFT's entire 2022 revenue (~$212B)
- McDonald's is essentially flat (0.1% CAGR) - mature steady-state, not decline
- Methodology question: NVDA's 2023 reporting includes the AI/GPU boom year; 
  growth rate is computed over 14 years not 13, affecting direct comparison

### Bottom‑3 risk profile detail
- SHLDQ (Sears Holdings)

    Peak: 2009, $46.8B revenue

    Trough: 2018, $16.7B revenue

    Decline began: 2010 (first drop from 46.8 → 43.4)

    Pattern:

        Gradual early decline (2009–2013), then accelerating collapse (2014–2018).

        No reversal attempts — revenue falls every single year.

        Net income turns negative in 2012, years before the steep revenue collapse.

        Market cap collapses from $9B → $0.04B, confirming a terminal decline.

        Classic death‑spiral trajectory: profitability collapses first, revenue collapse follows, equity value wiped out.

- BCS (Barclays)

    Peak: 2010, $49.0B revenue

    Trough: 2017, $27.2B revenue

    Decline pattern:

        Gradual decline from 2010–2015 (49 → 38.9).

        Sudden drop in 2016 (38.9 → 29.1).

        Multiple reversal attempts (2013, 2018, 2021), but none sustained.

        Net income becomes volatile before the major revenue drop — several loss years (2012, 2014, 2015, 2017).

        Market cap oscillates, reflecting investor optimism repeatedly fading.

        Overall: stair‑step decline with false recoveries and profitability instability leading revenue weakness.

- AIG

    Peak: 2009, $75.4B revenue

    Trough: 2020, $43.7B revenue

    Decline pattern:

        Long, slow decline from 2009–2017 (75 → 49).

        Partial rebounds in 2012 and 2021–2022.

        Net income swings violently: early recovery (2010–2015), then multiple loss years (2016, 2017, 2020).

        Net income deterioration precedes the later revenue decline.

        Market cap mirrors sentiment: early recovery → long erosion → partial rebound.

        Overall: multi‑year grind downward with two rebound attempts, driven more by profit volatility than revenue collapse.


## Question 2: Time-Series Patterns

### Aggregate trend (2009–2022)

    Total revenue 2009 vs 2022, growth multiple:  
    $392B → $1.64T (4.2× increase, with no down years)

    Total net income trend, with any years of negative aggregate:  
    $34B → $274B (8× increase).
    Aggregate net income is never negative, but shows sharp dips in 2012, 2017, and 2022.

    Total market cap trend, with the trillion‑dollar tech effect:  
    $0.99T → $6.7T (6.8× increase).
    Massive step‑ups from 2018–2021, then a –36% valuation reset in 2022.

### Inflection points visible in data:

    2010–2011: Post‑crisis profit boom - revenue +12–18%, net income +52–106%.

    2012: Margin compression - revenue +14.6%, net income –18.4%.

    2017: Profit dip despite revenue growth - net income –7.7%, market cap +37%.

    2018–2020: Tech‑led expansion - strong revenue + profit growth, valuations rising.

    2021: Peak boom year - revenue +25.1%, net income +67.5%, market cap +35.9%.

    2022: Systemic downturn - revenue slows, net income –14.1%, market cap –36.2%.

### Sector-level trends

    Top growing sectors (by company CAGRs):

        Logistics (AMZN) - 26%

        Technology (AAPL, GOOG, MSFT) - high‑teens

        FinTech (PYPL) - ~17%

        Electronics (NVDA) - ~16%

    Declining sectors:

        Banking (AIG, BCS) - negative CAGRs

        Finance/Retail (SHLDQ) — –11%, terminal decline

        Manufacturing (PCG) - low single‑digit

        Food & Beverage (MCD) - flat

    Strongest signal:  
    Aggregate performance is dominated by big‑tech secular growth, overwhelming declines in banks and legacy retail.

### Loss-year clustering

    2012: Multiple companies in losses (AIG, BCS, SHLDQ) - post‑crisis cleanup.

    2016–2017: Cluster of losses across financials - mid‑cycle stress.

    2020–2022: Pandemic + tightening cycle — profit volatility spikes.

    Cluster patterns visible at: 2012, 2016–2017, 2020–2022.

### Surprises and observations:

    No aggregate revenue declines at all even in recession or tightening years.

    2012 and 2017 show strong revenue growth but falling net income → margin compression.

    2020–2021 show valuations rising much faster than fundamentals → multiple expansion.

    2022 is the only year where both profitability and valuation fall → true regime shift.

    The collapse of SHLDQ and long grind of AIG/BCS barely move the aggregate mega‑cap tech fully defines the macro shape.

### To investigate on Day 19
- Compute NVDA's 2009-2022 CAGR for fair tech-sector comparison
- Time-series patterns: when did each company's growth inflect?
- Per-sector aggregate trends