# Project 1 - Financial Statements Analysis

**Status:**  Design Phase
**Started:** 2026-05-30
**Target completion:** End of Week 4 (~21 June 2026)

## Goal
Practice and demonstrate fundamental SQL analytics skills (SELECT, WHERE, GROUP BY, HAVING, JOINs, aggregations) 
on a real-world financial dataset, and communicate findings.

## Dataset

- **Name:** Financial Statements of Major Companies (2009–2023)
- **Source:** Kaggle
- **URL:** https://www.kaggle.com/datasets/rish59/financial-statements-of-major-companies2009-2023
- **Format:** CSV
- **Size:** ~2,000 rows across 50 companies (to verify on load)
- **Downloaded:** 2026-05-30

## Tools

- PostgreSQL (local)
- DBeaver (SQL client)
- Git/GitHub (version control & hosting)

## Business questions (draft — to refine next week)

### Revenue, Profitability & Growth

1. Total annual revenue per company — one row per company per year
2. Year-over-year revenue growth for each company — compare revenue this year vs last year
3. Average net income per company across all years — long-term profitability
4. Total revenue per industry per year — industry-level performance
5. Top 5 companies by revenue in each year — ranking within each year

### Margins, Ratios & Efficiency

6. Average profit margin per company — net income ÷ revenue
7. Operating expenses as a percentage of revenue per company per year — cost efficiency
8. Total assets per company per year — balance sheet scale
9. Debt-to-equity ratio per company per year — leverage analysis
10. Companies with improving profit margins over time — trend detection

### Multi-Group, Multi-Metric, Real-Business Queries

11. Revenue, net income, and total assets per company per year — multi-metric reporting
12. Industry-level average revenue, net income, and margin — benchmarking
13. Companies with negative net income in any year — loss-making identification
14. Total revenue per country per year — geographic performance
15. Top 3 industries by total revenue each year — industry ranking

## Deliverables
- Cleaned dataset loaded into PostgreSQL
- A single `.sql` file with all queries, each preceded by a markdown comment stating the business question and followed by a 1–2 sentence interpretation of the result
- README explaining the project, findings, and how to reproduce

## Skills demonstrated
- SQL: aggregations, GROUP BY, HAVING, JOINs (once covered)
- Data cleaning at load
- Business-question framing
- Plain-English interpretation of results

## Open questions / decisions to make
- Whether to add charts (probably yes - saved as PNGs in a `/charts` folder)
- Whether to write a final "executive summary" markdown at the end (probably yes)
