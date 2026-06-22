# Financial Statements Analysis 2009–2022

Author: Mark<br>
Period: 2009–2022 (15 years; 2023 excluded as partial reporting)<br>
Companies: 12 major listed companies across 9 sectors<br>
Dataset: Kaggle — Financial Statements of Major Companies (2009–2023)<br>

## Executive Summary

This analysis examines 15 years of financial statements from 12 major listed companies across 9 sectors between 2009 and 2022. Using SQL for analytical computation and Power BI for visualisation, the project evaluates cross‑company performance, long‑run time‑series patterns, and statistical outliers.

The headline finding: A small cluster of mega‑cap technology and logistics companies generated almost all long‑run value creation, while several incumbents structurally declined producing a sharply bimodal performance distribution that sector averages completely obscure.

### Headline findings

- **Amazon was the dominant growth story:** 26.4% CAGR, growing revenue from 
  $24.5B to $514B adding more revenue in 13 years than Microsoft's entire 
  2022 revenue.

- **Three distinct decline patterns** characterise the dataset's worst 
  performers: death spiral (Sears, -10.8% CAGR), structural shrinkage 
  (Barclays, -3.0%), and strategic disposal (AIG, -2.2%)

- **The dataset has bimodal performance distribution** clear winners 
  (composite rank 2-8) and clear losers (rank 21-24), with little in between
- **Aggregate revenue never declined year-over-year**, even in COVID 2020 
  (+15.3%), but this is a function of dataset composition rather than 
  broader economic resilience.

- **Twin NPM peaks of 20.2% (2011) and 21.2% (2021)** mask very different 
  underlying stories: 2011 was broad-based post-crisis recovery; 2021 was 
  concentrated tech megacap dominance during the pandemic.

## Data preparation

- Column names normalised from mixed Title Case to snake_case
- Empty duplicate columns dropped from initial CSV load
- Sector taxonomy normalised: original `category` column had inconsistent 
  casing (Bank/BANK) and mixed abbreviation/full-word conventions. 
  A clean `sector` column was added with the following mapping: 
  [your mapping].

## Question 1: Cross-Company Performance

Question: Which companies have grown most consistently over 15 years, and which have declined? What does the bottom‑3 risk profile look like?

# Composite Performance Ranking

Performance was measured using two complementary signals:

    CAGR - long‑run growth rate

    Consistency — % of years with positive YoY growth

# Combined, these produce a clear three‑tier structure:

    Top tier (ranks 2–8): AMZN, GOOG, AAPL, PYPL, NVDA

    Middle tier (ranks 10–18): MSFT, INTC, PCG, MCD

    Bottom tier (ranks 21–24): AIG, BCS, SHLDQ

The ranking shows a small group of secular winners, a modest middle, and a cluster of structural decliners. There is no smooth gradient the dataset is bimodal.

# Three Distinct Decline Patterns

Sears Holdings (SHLDQ) - Death Spiral

    Revenue collapsed 64% (2009–2018).

    7 of 9 reporting years were loss‑making.

    Cause: retail disruption; Amazon and Walmart structurally eroded the model.

# Barclays (BCS) - Structural Shrinkage

    Revenue fell 45% (2010–2017).

    4 loss‑making years.

    Cause: post‑crisis UK regulation forcing balance‑sheet reduction.

# AIG — Strategic Disposal

    Revenue fell 42% (2009–2020).

    5 loss‑making years.

    Cause: post‑bailout asset sales to repay government support.

These companies share low ranks but represent different risk profiles: terminal decline, regulatory shrinkage, and deliberate downsizing.
Loss Years: Growth Investment vs Distress

# Loss years fall into four categories:

    Growth investment: AMZN (2012) - reinvestment in fulfilment and AWS.

    Cyclical downturn: NVDA (2009–10) - financial crisis trough.

    Structural distress: AIG, BCS, PCG - chronic balance‑sheet or legal issues.

    Terminal failure: SHLDQ - persistent losses until bankruptcy.

The identical numerical event (“net income < 0”) masks very different business realities.
The Bimodal Distribution

# Three performance bands emerge:

    Secular winners: AMZN, GOOG, AAPL, PYPL, NVDA

    Mature middlers: MSFT, INTC, PCG, MCD

    Structural decliners: AIG, BCS, SHLDQ

The absence of a middle ground shows the dataset captures companies on divergent trajectories, not a representative economic sample.



## Question 2: Time-Series Patterns

# Aggregate Growth Shape

Aggregate revenue grew 4.2× from 2009 to 2022 and never declined YoY, including +15.3% in 2020. Net income followed a similar upward trend with dips in 2012, 2017, and 2022. The shape reflects the dominance of mega‑cap tech and logistics.
Inflection Points

    2011: broad‑based post‑crisis acceleration.

    2017: net‑income compression from U.S. tax‑code changes.

    2020: COVID divergence - tech accelerates, financials flatten.

    2021: strongest year in the dataset; synchronized revenue and margin surge.

    2022: mixed - revenue up, margins and market caps down.

# Sector‑Level Trends

    Logistics (AMZN): 26.4% CAGR

    Technology (AAPL, GOOG, MSFT): 16.2% CAGR

    Electronics (INTC + NVDA): 6.7% CAGR

    Banking (AIG, BCS): –2.5% CAGR

Sector labels hide major intra‑sector divergence especially in Electronics.
Loss‑Year Clustering

Loss years cluster in 2012, 2016–17, and 2020–22, but no year shows systemic distress. Losses are company‑specific: PCG’s wildfire liabilities, AIG’s disposals, NVDA’s cycle trough, SHLDQ’s collapse.
Twin NPM Peaks

    2011 (20.2%) - broad‑based recovery

    2021 (21.2%) - concentrated tech megacap dominance

Same headline, different drivers.



## Question 3: Outliers and Sector Patterns

# Statistical Outliers

Using the 1.5×IQR rule:

    33 upper outliers, almost all from AAPL, AMZN, GOOG, MSFT

    2 lower outliers, from PCG and SHLDQ

The distribution is heavily right‑skewed.

# Technology Sector Deep‑Dive

AAPL, GOOG, and MSFT show parallel YoY revenue patterns, confirming a sector tailwind. But margins diverge structurally: MSFT highest, GOOG mid‑range, AAPL lowest but stable. Market‑cap convergence in 2020–21 is followed by a broad 2022 correction.
Electronics Divergence

INTC and NVDA share a sector but not a trajectory:

    INTC: ~4.6% CAGR, stagnant revenue, declining profitability.

    NVDA: ~17% CAGR, explosive growth, $10B → $1T market cap.

This is the clearest example of why sector analysis can mislead company positioning matters more than sector labels.



## Methodology

# Headline Metrics

Revenue, net income, market cap, and NPM computed annually per company. CAGR and YoY growth used for long‑run and consistency analysis.

# CAGR Formula
CAGR=(Revenue2022Revenue2009)1/13−1

# Outlier Definition

1.5×IQR rule applied separately to revenue, net income, market cap, and NPM.

# Sector Taxonomy

9 sectors, mostly single‑company sectors (e.g., Logistics = AMZN). Reflects dataset structure.

# Year Range

2009–2022 used for comparability; 2023 excluded as partial.
Units

    Revenue & net income: millions

    Market cap: billions

    Aggregates: trillions

# Data Cleaning

Schema cleanup, column renaming, sector normalisation, and removal of incomplete rows.

## Caveats and Limitations

    Dataset is curated; survivorship bias favours winners.

    Mega‑cap tech firms distort aggregate metrics.

    Most sectors contain only one company; “sector analysis” often = company analysis.

    2017 NPM dip is a tax‑code artifact, not operational weakness.

    SHLDQ’s “Finance” classification reflects post‑bankruptcy structure, not historical retail identity.

