# Project 1: Financial Statements Analysis

**Author:** Mark<br>  
**Period covered by data:** 2009-2023 (15 years)<br>  
**Dataset source:** [Kaggle - Financial Statements of Major Companies 2009-2023](https://www.kaggle.com/datasets/rish59/financial-statements-of-major-companies2009-2023)

## Project Overview

This project analyses the financial statements of major listed companies between 2009 and 2023, using SQL for the analytical layer and Power BI for visualisation. The goal is to surface financial performance patterns, identify outlier companies, and produce a board-ready dashboard with accompanying findings document.

## Status

🟡 **In progress** - kickoff 18 June 2026, targeted completion ~3 July 2026

## File structure

- `data/` - raw CSV from Kaggle (not edited)
- `sql/` - analytical queries, in execution order
  - `00-schema.sql` - table definitions
  - `01-load.sql` - data loading commands
  - `02-exploration.sql` - data orientation queries
  - `03-analysis.sql` - analytical queries answering business questions
- `powerbi/` - Power BI dashboard file
- `screenshots/` - dashboard hero images
- `findings.md` - analytical narrative and recommendations

## Headline metrics

Four metrics anchor this analysis, each answering a distinct question:

1. **Revenue** - top-line growth signal; "how big is the business?"
2. **Net Income** - bottom-line profitability; "how much does the business earn?"
3. **Market Cap** - market valuation signal; "how does the market value the business?"
4. **Net Profit Margin** - efficiency signal; "how efficiently does revenue convert to profit?"

Supporting metrics (used in specific analyses but not headline):
- Operating Cash Flow, EPS, Debt/Equity Ratio, ROE, Number of Employees


## Analytical questions

This project will answer three guiding questions:

- Question 1 - Cross‑Company Performance
“Which companies have grown most consistently over 15 years, and which have declined? What does the bottom‑3 risk profile look like?”

- Question 2 - Cross‑Company Performance
“How have key financial metrics (revenue, margins, market cap) trended across the dataset? What inflection points are visible (post‑2008, COVID, tech boom, etc.)?”

- Question 3 — Outlier & Sector Analysis
"Which companies are outliers on key metrics? Where sector-level comparison is possible (Technology: AAPL, GOOG, MSFT; Electronics: INTC, NVDA), do outliers reflect sector tailwinds or company-specific drivers?"

- Note: Most sectors in this dataset have only one company, so sector-level analysis is focused on Technology (3 companies) and Electronics (2 companies). For other sectors, the analysis treats company performance as company-specific signal.

## Scope decisions:
- Companies in scope: 12 Distinct Companies  
- This gives: Enough variety, Enough stability, Enough data completeness, A clean dashboard footprint.

- Years in scope: All 15 years.
- Using the following: Window functions, Time Intelligence, DAX, Rolling metrics, YoY, MoM, CAGR

- Date of scope decision: 2026-06-19


## Methodology

# Headline Metrics

- Revenue, net income, market cap, and NPM computed annually per company. CAGR and YoY growth used for long‑run and consistency analysis.

# CAGR Formula
- CAGR=(Revenue2022Revenue2009)1/13−1

# Outlier Definition

- 1.5×IQR rule applied separately to revenue, net income, market cap, and NPM.

# Sector Taxonomy

- 9 sectors, mostly single‑company sectors (e.g., Logistics = AMZN). Reflects dataset structure.

# Year Range

- 2009–2022 used for comparability; 2023 excluded as partial.
- Units

    Revenue & net income: millions

    Market cap: billions

    Aggregates: trillions

# Data Cleaning

- Schema cleanup, column renaming, sector normalisation, and removal of incomplete rows.


## Findings Summary

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


## Tools

- PostgreSQL 18.4 (local)
- DBeaver
- VS Code
- Power BI Desktop
- Git/GitHub