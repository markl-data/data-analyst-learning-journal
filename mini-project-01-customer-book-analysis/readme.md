# Mini-Project 1: Customer Book Analysis

**Brief:** First analytical brief from the (simulated) CFO. Four questions about 
customer concentration, geographic performance, product profitability, and 
overdue risk. Deliverable: half-page markdown summary.

**Author:** Mark Losty
**Date:** 2026-06-05
**Tools:** PostgreSQL 18.4, DBeaver
**Data:** `finance_practice` schema - 12 customers, 8 products, 35 invoices 
(synthetic dataset built during Week 1)

## Project Structure
- `exploration.sql` - initial database exploration, messy queries, dead ends
- `analysis.sql` - final polished queries that produced the findings
- `findings.md` - written summary for the CFO

## The Brief

> "Mark - welcome to the team. I'd like a quick analysis from you by end of Friday on the state of our customer book and sales pipeline. Specifically, I'd like to understand:

> Q1. Who are our most valuable customers, and is our revenue dangerously concentrated in a small number of them?
> Q2. Which countries and industries are over/underperforming relative to our overall book?
> Q3. Which products are the strongest profit contributors, and which are the weakest? Should we consider dropping any?
> Q4. Are there any worrying patterns in our overdue and outstanding balances?

> Send me back a short markdown document with your findings, the SQL queries that produced them, and any recommendations. Don't make it long - half a page of insight is more useful to me than five pages of data. - Sarah, CFO"

## How to reproduce

1. Connect to local PostgreSQL with the `finance_practice` database loaded
2. Run `analysis.sql` in DBeaver - each block is annotated with the business 
   question it answers
3. The narrative interpretation of each result is in `findings.md`