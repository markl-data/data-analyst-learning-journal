# Project 1: Financial Statements Analysis

**Author:** Mark
**Period covered by data:** 2009-2023 (15 years)
**Dataset source:** [Kaggle - Financial Statements of Major Companies 2009-2023](https://www.kaggle.com/datasets/rish59/financial-statements-of-major-companies2009-2023)

## Project Overview

This project analyses the financial statements of major listed companies between 2009 and 2023, using SQL for the analytical layer and Power BI for visualisation. The goal is to surface financial performance patterns, identify outlier companies, and produce a board-ready dashboard with accompanying findings document.

## Status

🟡 **In progress** - kickoff 22 June 2026, targeted completion ~3 July 2026

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


## Analytical questions

This project will answer three guiding questions:

1. Question 1 - How many companies?
2. Question 2 - How many years?
3. Question 3 - What three analytical questions?

Scope decisions:
- Companies in scope: Top 25 companies by market cap or revenue.  
- This gives: Enough variety, Enough stability, Enough data completeness, A clean dashboard footprint.

- Years in scope: All 15 years.
- Using the following: Window functions, Time Intelligence, DAX, Rolling metrics, YoY, MoM, CAGR

- Date of scope decision: 2026-06-22

- Additional Questions

- Question 1 - Cross‑Company Performance
- “Which companies have grown most consistently over 15 years, and which have declined? What does the bottom‑3 risk profile look like?”

- Question 2 - Cross‑Company Performance
- “How have key financial metrics (revenue, margins, market cap) trended across the dataset? What inflection points are visible (post‑2008, COVID, tech boom, etc.)?”

- Question 3 — Outlier & Sector Analysis
- “Which companies are outliers on key metrics, and are these driven by sector‑level patterns or company‑specific factors?”

## Methodology

[Will be completed as the project progresses]


## Findings summary

[Will be completed at project close]

## Day 17 Progress

- Folder structure created
- Initial README scaffold
- Data orientation completed (CSV inspected, mental model formed)
- Data loaded into local PostgreSQL (database: `financial_statements`)
- Initial exploration queries run; data shape understood
- Scope decisions made (see Analytical Questions section)

## Day 18 plan

- Build out 02-exploration.sql with deeper data quality checks
- Begin 03-analysis.sql with queries for guiding question 1 (Cross-Company Performance)

## Tools

- PostgreSQL 18.4 (local)
- DBeaver
- VS Code
- Power BI Desktop
- Git/GitHub