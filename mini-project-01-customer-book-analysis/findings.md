# Customer Book Analysis — Findings

**To:** Sarah, CFO  
**From:** Mark, Junior Data Analyst  
**Date:** 2026-06-06  
**Period Analysed:** 2025-01-15 to 2026-04-30

---

## Topline

- **Total Customers:** 12
- **Total Revenue:** €137,920
- **Paid:** 82.70% • **Outstanding:** 13.60% • **Overdue:** 3.70%

- **Insight:**
- The customer book is generally healthy, with more than 80% of revenue paid and only 3.7% overdue, but the outstanding 13.6% warrants monitoring as it represents future credit exposure.

---

## Headline Finding

- Half of our revenue depends on three customers, and one of them - Manchester Manufacturing - sits at €9,600 overdue, a single risk that's larger than our total France exposure.

---

## 1. Customer concentration:

- Top customer: **[Manchester Manufacturing]** at €24,300 = **17.60%** of total revenue
- Top 3 customers generate €67,300 representing **48.80%** of total revenue
- Top 5 customers generate €92,660 representing **67.20%** of total revenue

**Interpretation:** 
- The customer book is highly concentrated, with nearly half of all revenue coming from just three customers and over two‑thirds from the top five.
- This level of concentration creates material dependency risk - losing even one of the top accounts would significantly impact revenue.

## 2. Geographic and industry performance

- Spain is the Standout Market: €22,800 per customer, almost 2x the global average €11,493. 
- Germany also outperforms, with €12,800 per customer, slightly above the global benchmark.
- France and Portugal significantly underperform, with €2,760 and €8,200 per customer respectively, well below the global average
- Automotive is the strongest sector by far: €22,800 per customer, nearly double the global average.
- Food is the weakest sector, with only €2,310 per customer, far below the global benchmark.

**Interpretation:**
- The customer book shows strong geographic skew, with Spain and Germany driving outsized value relative to their customer counts
- France and Portugal lag materially, suggesting weaker product‑market fit or lower pricing power in those markets.
- Industry performance mirrors the geographic pattern: a few sectors (Automotive, Industrial, Beverages) drive the majority of value, while Food materially underperforms

## 3. Product profitability

- Most profitable product: Software Licence - Annual, generating €35,000 in margin at €1,000 profit per unit.
- Least profitable product: Consulting Hours - Junior, generating only €3,960 at €60 profit per unit.
- No products show zero sales, the entire product catalogue is active.

**Interpretation:**
- Profitability is heavily skewed toward software, which delivers both high revenue and exceptional margins.
- Hardware and Training products perform reasonably well but lack the margin depth of software.

**Recommendation:**
- The company should prioritise software expansion, as it is the clear economic engine of the customer book.
- Low‑margin services - particularly Junior consulting, warrant a pricing review or tighter scoping to avoid eroding blended margins.

## 4. Credit risk

**Largest Unpaid Balances:**
| Customer                 | Unpaid Balance (€) |
|------------------------  |------------------- |
| Manchester Manufacturing |      9,600         |
| Galway Garments          |      7,350         |
| Lisbon Logistics         |      4,200         |
| Paris Patisserie         |      1,800         |
| Belfast Bakery           |        900         |


**Billing % (unpaid as a share of each customer’s own billings):**
| Customer                 | Country  | Total Billed (€) | Unpaid (€) | Billing % |
|------------------------  |----------|------------------|------------|-----------|
| Galway Garments          | Ireland  | 8,950            | 7,350      | 82.1%     |
| Paris Patisserie         | France   | 2,760            | 1,800      | 65.2%     |
| Lisbon Logistics         | Portugal | 8,200            | 4,200      | 51.2%     |
| Belfast Bakery           | UK       | 1,860            | 900        | 48.4%     |
| Manchester Manufacturing | UK       | 24,300           | 9,600      | 39.5%     |



**Recommendation:**
- The credit team should prioritise immediate follow‑up with Galway Garments and Paris Patisserie, as their unpaid percentages indicate potential liquidity issues.
- Manchester Manufacturing also warrants attention due to the absolute size of the exposure.
- A structured credit‑control plan for these three customers would materially reduce risk in the customer book.

**Note:**
- Manchester Manufacturing remains well within its credit limit (€9,600 unpaid against €120,000 limit), so the action is collections follow-up rather than credit-line review. Galway Garments, by contrast, is approaching limit utilisation and warrants both.

---

## Methodology notes

- All analysis based on 35 invoices across 12 customers and 8 products
- "Profit" defined as (unit price − unit cost) × quantity sold
- "At-risk amount" = sum of overdue and outstanding statuses
- Queries available in `analysis.sql`; exploratory work in `exploration.sql`

## Caveats

- Small dataset (35 invoices) - concentration figures should be treated as 
  directional rather than statistically significant
- No data on customer acquisition cost or contract terms; recommendations 
  are based on revenue/risk patterns only