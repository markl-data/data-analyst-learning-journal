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

### To investigate on Day 19
- Compute NVDA's 2009-2022 CAGR for fair tech-sector comparison
- Time-series patterns: when did each company's growth inflect?
- Per-sector aggregate trends