# Sales Performance Review - H1 2026

**To:** James, Head of Sales
**From:** Mark, Junior Data Analyst
**Date:** 2026-06-15
**Period analysed:** 2025-01 to 2026-04 (17 months)
**Purpose:** Input to half-year board meeting

---

## Topline

- Total revenue across the period was €137,920, with 82.7% paid, 13.6% outstanding, and 3.7% overdue.

- Revenue was driven primarily by Spain (Automotive), Ireland (Beverages), and the UK (Industrial/Electronics).

- Paid revenue dominates, but there are meaningful pockets of outstanding and overdue invoices in Ireland Retail, UK Industrial, and Portugal Industrial.

- The biggest signal: revenue is concentrated in a small number of countries and industries, creating both opportunity and risk.

---

## Headline finding

- Company growth is being carried by a narrow set of high‑performing segments (Spain Automotive, Ireland Beverages, UK Industrial), while several smaller segments show rising credit risk and declining momentum.

---

## 1. Customer trajectory

**Growing:** 

- Berlin Brewing GmbH - €5,000 → €7,800
- Cork Coffee Co - €600 → €3,750
- Dublin Distillery Ltd - €5,200 → €15,000
- Edinburgh Electronics - €1,440 → €7,200
- Galway Garments - €1,600 → €7,350
- Lisbon Logistics - €1,800 → €6,400
- These customers show clear, material expansion in the second half of their invoice history.

**Flat:** 

- Amsterdam Audio BV - €4,800 → €5,700
- Belfast Bakery - €960 → €900
- Madrid Motors SA - €12,000 → €10,800
- Manchester Manufacturing - €12,300 → €12,000

- These customers are stable, with small fluctuations but no meaningful trend.

**Declining / at-risk:** 

- London Lighting Group - €7,200 → €5,360

- Paris Patisserie - €1,800 → €960

- These customers show clear downward movement and warrant attention.

**Interpretation:** 

- Growth is concentrated in a few strong segments, notably Automotive in Spain and Beverages in Ireland.
- Declining customers tend to cluster in weaker industries (Food, Retail) and in countries with higher unpaid balances (Portugal, France).
- The pattern suggests a core of reliable, expanding customers and a long tail of stagnating or shrinking accounts.

**Caveat:**
- Several customers in our dataset have only 2-3 invoices, which makes their 'trajectory' classification dependent on single transactions rather than a true trend. 
- A customer flagged as 'growing' on the basis of a single recent large invoice should be treated as a watch-item rather than a confirmed pattern."

**Recommendation:** 

- Intervene with:

- Intervene with: London Lighting Group (meaningful decline in Retail) and Paris Patisserie (shrinking and in a weak Food segment).


- Double‑down on:

- Double‑down on: Dublin Distillery Ltd (strongest growth signal), Edinburgh Electronics and Galway Garments (consistent expansion), and Lisbon Logistics (strong late‑period growth in Industrial).

- These customers represent the highest ROI for incremental sales effort.

## 2. Product Momentum

- “Product performance is uniformly positive across all eight offerings.”

- All eight products show clear late‑period revenue expansion:

    Consulting Hours - Junior - €2,760 → €5,160

    Consulting Hours - Senior - €7,500 → €14,250

    Hardware Bundle - Basic - €4,800 → €6,400

    Hardware Bundle – Premium - €12,000 → €19,200

    Software Licence – Annual - €16,800 → €25,200

    Software Licence – Monthly - €2,040 → €3,360

    Training Course – On‑site - €1,800 → €7,200

    Training Course – Online - €4,050 → €5,400

**Caveat:**

- "Within our 35-invoice dataset, every product shows nominal late-period revenue uplift. However, sample sizes per product are thin (typically 2-5 invoices per half-period), and the Day 15 monthly view revealed substantial month-to-month volatility - a single large invoice can distort 'growth' figures by 100% or more. 
- The directional finding (no product is collapsing) holds, but the specific growth percentages should be treated as indicative rather than statistically robust."

**Recommendation on dropping products:** 

- Do NOT drop any products.

- Here’s the defensible reasoning James can take to the board:

    All products show positive growth, several with very strong acceleration.

    None show stagnation or decline.

    The two lowest‑revenue products are actually fast‑improving (On‑site Training especially).

    Dropping any product would remove revenue that is currently expanding, not shrinking.

- If anything, the data suggests doubling down on:

    Annual Software Licence

    Senior Consulting Hours

    On‑site Training

    Hardware Bundle - Premium

- These are your highest‑momentum offerings.

## 3. Pipeline health (time-to-pay proxy)

- We do not store payment timestamps, so true time‑to‑pay cannot be calculated.
- As a substitute, I analysed the age of outstanding/overdue invoices and the percentage of revenue currently unpaid by country and industry.
- Ireland Retail, UK Industrial, Portugal Industrial, and France Food show the slowest payment behaviour and the highest unpaid proportions.

**Recommendation:** 

- Credit control should focus on Ireland Retail and UK/Portugal Industrial first, these segments combine material revenue with elevated unpaid balances.
- France Food is small but consistently overdue and should be monitored closely.

---

## Methodology notes
- Dataset: 17‑month period, invoices across all customers and products
- “Trajectory” defined as: comparison of early‑period vs late‑period revenue per customer using window functions
- “Time‑to‑pay” not directly available; proxied using invoice age and % revenue unpaid
- Queries available in `analysis.sql`

## Caveats
- Some customers and products have only 2-5 invoices in the dataset. 
- For these, 'trajectory' calculations are dominated by individual transactions rather than sustained patterns. 
- A larger, longer dataset would be needed for confident growth/decline classifications
- Seasonal patterns may be exaggerated by missing months or one‑off invoices
- Revenue concentration increases sensitivity to performance in a few key segments