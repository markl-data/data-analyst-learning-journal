# Financial Statements Analysis 2009–2022

Author: Mark<br>
Period: 2009–2022 (13 years; 2023 excluded as partial reporting)<br>
Companies: 12 major listed companies across 9 sectors<br>
Dataset: Kaggle - Financial Statements of Major Companies (2009–2023)<br>

## Executive Summary

This analysis examines 13 years of financial statements from 12 major listed companies across 9 sectors between 2009 and 2022. Using SQL for analytical computation and Power BI for visualisation, the project evaluates cross‑company performance, long‑run time‑series patterns, and statistical outliers.

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



## Question 1: Cross-Company Performance

- Question: Which companies have grown most consistently over 13 years, and which have declined? What does the bottom‑3 risk profile look like?

### Composite Performance Ranking

Performance was measured using two complementary signals:
- **CAGR** (compound annual growth rate): how fast revenue grew over 2009-2022
- **Consistency** (% of years with positive year-over-year growth): how reliably it grew

Combining these into a composite rank (lower = better) produced:

| Composite  | Company          | Sector | CAGR  |
|------------|----------------- |--------|-------|
| 2 | AMZN   | Logistics        | 26.4%  | 100%  |
| 3 | GOOG   | Technology       | 21.0%  | 100%  |
| 5 | PYPL   | FinTech          | 16.7%  | 100%  |
| 8 | AAPL   | Technology       | 18.6%  | 84.6% |
| 10 | MSFT  | Technology       | 9.6%   | 92.9% |
| 11 | NVDA  | Electronics      | 17.2%  | 78.6% |
| 15 | INTC  | Electronics      | 4.6%   | 69.2% |
| 15 | PCG   | Manufacturing    | 3.8%   | 76.9% |
| 18 | MCD   | Food & Beverage  | 0.1%   | 46.2% |
| 21 | AIG   | Banking          | -2.2%  | 30.8% |
| 21 | BCS   | Banking          | -3.0%  | 38.5% |
| 24 | SHLDQ | Finance          | -10.8% | 0%    |

The composite ranking reveals three distinct performance bands rather than 
a smooth gradient. AMZN, GOOG, and PYPL achieved perfect consistency alongside strong CAGRs. 
SHLDQ scored the maximum composite of 24, last in both metrics reflecting a company that declined in every reporting year before filing bankruptcy in 2018.

Notably, NVDA's higher CAGR (17.2%) than MSFT's (9.6%) does not translate into a better composite rank, because NVDA's growth was volatile (78.6% consistency vs MSFT's 92.9%). 

The composite ranking surfaces what a single growth metric hides: consistent compounding matters as much as headline growth rate.

### Three Distinct Decline Patterns

The three lowest-ranked companies illustrate three very different decline 
stories. Treating them as a homogeneous "bottom 3" would miss the analytical 
point entirely.

**Sears Holdings (SHLDQ) - Death Spiral**
- Revenue: $46.8B (2009) → $16.7B (2018, last reporting year)
- 64% revenue loss in 9 years
- 7 of 9 reporting years were loss-making
- Filed Chapter 11 bankruptcy in October 2018

The Sears story is the textbook case of retail disruption. Amazon and Walmart 
squeezed traditional department stores into extinction over the dataset period, 
and Sears was the most prominent casualty. With losses in 78% of reporting 
years, the company wasn't slowing it was actively dying throughout the data.

**Barclays (BCS) - Structural Shrinkage**
- Revenue: $49.0B (2010 peak) → $27.2B (2017 trough)
- 45% revenue loss in 7 years
- 4 loss-making years across 2012-2017

Unlike Sears, Barclays peaked *after* the 2008 crisis (in 2010, briefly buoyed 
by recovery) before declining steadily. The cause was UK regulatory pressure 
post-2008, ring-fencing requirements and capital constraints forced sale or 
wind-down of business lines. Recovery began post-2017 once the regulatory 
shrinkage was complete.

**AIG - Strategic Disposal**
- Revenue: $75.4B (2009) → $43.7B (2020 trough)
- 42% revenue loss over 11 years
- 5 loss-making years scattered across the period
- Largest company in the dataset by 2009 revenue

AIG's decline is the most nuanced of the three. The company was systematically 
selling off business lines (life insurance, asset management) to repay its 
2008 government bailout. The shrinkage was *by design*, not by distress. Its 
2009 starting point of $75.4B already reflected post-crisis contraction; the 
subsequent decline was the intentional unwinding of a once-sprawling 
conglomerate.

**Same numerical signature, three different underlying realities.** The risk 
profile for each is genuinely different: SHLDQ was a business that no longer 
worked, BCS was a healthy business shrunk by external rules, and AIG was a 
deliberate restructuring.




### Loss Years: Growth Investment vs Distress

Six companies had at least one loss-making year during the period. 
These cluster into four distinct categories with very different implications:

**Loss years from growth investment** (deliberate, strategic):
- **AMZN:** 3 loss years (2012 and surrounding) - losses from reinvestment in 
  fulfilment infrastructure and AWS expansion

**Loss years from market downturn** (cyclical):
- **NVDA:** 2 loss years (2009-2010) - financial crisis trough; the company 
  recovered strongly and grew at 17.2% CAGR thereafter

**Loss years from structural distress** (chronic):
- **AIG:** 5 loss years across 2009-2020 - persistent unprofitability during 
  bailout repayment
- **BCS:** 4 loss years 2012-2017 - regulatory shrinkage period
- **PCG:** 4 loss years 2018-2021 - wildfire liability charges and 2019 
  bankruptcy

**Loss years from business failure** (terminal):
- **SHLDQ:** 7 of 9 reporting years - chronic unprofitability ending in 
  bankruptcy

The numerical event ("net income < 0") looks identical across these 22 
company-year observations. **The underlying business reality couldn't be more 
different.** Mistaking AMZN's 2012 growth-investment loss for a distress signal 
or AIG's strategic-disposal loss for failure would lead to entirely wrong 
analytical conclusions.

### The Bimodal Performance Distribution

The composite ranking does not show a smooth performance gradient. Instead, 
it reveals three distinct bands:

- **Secular winners** (composite rank 2-8): AMZN, GOOG, PYPL, AAPL - 
  consistent high growth
- **Mature middlers** (rank 10-18): MSFT, NVDA, INTC, PCG, MCD -
  varying growth rates, mixed consistency
- **Structural decliners** (rank 21-24): AIG, BCS, SHLDQ -
  negative CAGR and low consistency

The absence of a smooth gradient between these bands suggests the dataset 
captures companies in clearly differentiated trajectories rather than a 
typical performance distribution. This bimodality has implications for any 
inference drawn from the data: **the dataset is not a random sample of the 
economy.** Selection biases toward survivors and toward extreme cases 
(megacap winners + textbook decliners) shape every aggregate finding.



## Question 2: Time-Series Patterns

- Question: “How have key financial metrics (revenue, margins, market cap) trended across the dataset? What inflection points are visible (post‑2008, COVID, tech boom, etc.)?”

### Aggregate Growth Shape

Aggregate revenue across the 12 companies grew from $392B in 2009 to $1,639B in 2022 - a 4.2× multiple over 13 years. Growth was discrete rather than smooth, with the strongest years (2021 at +25.1%) reflecting tech megacap 
acceleration and the weakest (2016 at +1.1%) reflecting broader plateau.

Notably, aggregate revenue never declined year-over-year across the entire period, even through COVID 2020 (+15.3%). This resilience is a function of dataset composition rather than broader economic strength - the secular 
growers (tech megacaps) overpowered any cyclical weakness elsewhere.

### Inflection Points and Likely Drivers

- **2009-2011:** Post-crisis recovery strongest broad profitability year was 2011 (zero loss-makers, $105B aggregate net income)

- **2017:** Net income compression (-7.7% YoY) likely driven by US Tax Cuts and Jobs Act causing one-time tax charges across major US corporates 
  while revenue continued growing

- **2020 (COVID):** Striking divergence aggregate revenue +15.3%, aggregate net income +9.6%, market cap +50.6%. Tech megacaps' boom (cloud, 
  e-commerce, streaming) more than offset weakness elsewhere

- **2021:** Recovery surge across all metrics (revenue +25.1%, net income 
  +67.5%, market cap +35.9%)

- **2022:** Market cap correction (-36.2%) while revenue held steady (+8.7%) valuations contracted before operating performance, foreshadowing the 
  tech-sector valuation reset


### Sector-Level Trends

Sector CAGRs reveal a polarised growth landscape:
- Logistics 26.4% (AMZN only - sector ≡ company)
- Technology 16.2% (3 companies - real sector analysis possible)
- Electronics 6.7% (2 companies - masks divergent paths between INTC and NVDA)
- Manufacturing 3.8%, Food & Beverage 0.1%
- Banking -2.5% (2 companies - both declining)

Sector labels hide major intra-sector divergence, especially in Electronics 
(see Q3 deep-dive).

### Loss-Year Clustering

Loss years cluster in 2012, 2016-17, and 2020-22, but no year shows systemic 
distress. The "everyone profitable" year was 2011 (zero loss-makers, $105B 
aggregate net income). 
COVID 2020 had only 2 loss-makers, reinforcing the secular-growth dominance of the dataset. 

Cluster years reflect individual 
company troughs PCG's wildfire liabilities, AIG's disposals, NVDA's cycle 
trough, SHLDQ's collapse rather than systemic economic events.

### Twin NPM Peaks

Net profit margins across the dataset peak twice 2011 and 2021, but the underlying drivers could not be more different. The 2011 peak (20.2%) reflects a broad‑based post‑crisis recovery: most companies expanded margins simultaneously as credit conditions normalised, cost structures reset, and demand rebounded. Margin strength in this period is distributed across sectors, with banks, insurers, and manufacturers all contributing to the uplift.

The 2021 peak (21.2%), by contrast, is almost entirely a tech‑megacap phenomenon. Apple, Google, and Microsoft posted some of the highest margins in their histories, driven by pandemic‑era digital demand, operating leverage in cloud and software, and unusually favourable cost structures. Outside technology, margin performance was mixed, PCG, AIG, and BCS all saw compression, and several companies faced inflation‑driven cost pressure.

The identical headline “NPM peak” masks two fundamentally different stories: 2011 was broad and cyclical; 2021 was narrow and structural. 
Understanding this distinction is essential when interpreting long‑run profitability trends or drawing conclusions about sector resilience.

## Question 3: Outliers and Sector Patterns

- Question: "Which companies are outliers on key metrics? Where sector-level comparison is possible (Technology: AAPL, GOOG, MSFT; Electronics: INTC, NVDA), do outliers reflect sector tailwinds or company-specific drivers?"

### Statistical Outliers

Using the 1.5×IQR rule:

    33 upper outliers, almost all from AAPL, AMZN, GOOG, MSFT

    2 lower outliers, from PCG and SHLDQ

The upper tail is overwhelmingly concentrated in AAPL, AMZN, GOOG, and MSFT, whose scale and compounding generate repeated extreme values across multiple metrics. These outliers are not noise, they reflect genuine structural dominance by a small cluster of mega‑cap firms.

Lower outliers are rare and come from PCG (bankruptcy‑related losses) and SHLDQ (terminal decline), both representing company‑specific distress rather than sector‑wide weakness. The asymmetry of the outlier distribution - many extreme winners, very few extreme losers, reinforces the dataset’s right‑skewed performance profile and the outsized influence of tech megacaps on aggregate results.

### Technology Sector Deep-Dive (AAPL/GOOG/MSFT)

AAPL, GOOG, and MSFT show parallel YoY revenue patterns, confirming a sector tailwind. But margins diverge structurally: MSFT highest, GOOG mid‑range, AAPL lowest but stable. Market‑cap convergence in 2020–21 is followed by a broad 2022 correction.

Market‑cap behaviour reinforces the pattern: all three expand sharply through the 2010s, converge in 2020–2021, and then correct in 2022. 
The sector’s long‑run dominance is clear, but the internal variation highlights a key analytical point: the tech sector rises together, but each company captures the tailwind differently.

### Electronics Divergence (INTC vs NVDA)

The Electronics sector contains the dataset’s most dramatic intra‑sector divergence. 

Intel (INTC) and Nvidia (NVDA) share the same sector label, yet their trajectories over 2009–2022 could not be more different. Intel grows at a modest ~4.6% CAGR, with largely flat revenue and declining profitability, reflecting missed transitions in GPUs, AI acceleration, and advanced manufacturing. 
Nvidia compounds at ~17% CAGR, driven by explosive demand for GPUs, data‑centre compute, and AI workloads.

Market‑cap behaviour amplifies the contrast: Intel oscillates between $100B–$200B with no structural expansion, while Nvidia rises from ~$10B to over $1T, becoming one of the most valuable companies in the world. Both companies operate in “Electronics,” but their strategic positioning, CPUs vs GPUs, legacy manufacturing vs accelerated compute determines completely opposite outcomes.

This divergence is the clearest example in the dataset of why sector labels alone are analytically insufficient. The Electronics sector’s headline CAGR of 6.7% masks a stagnant incumbent and a hyper‑growth outlier, demonstrating that company‑specific positioning dominates sector classification in explaining long‑run performance.

## Methodology

### CAGR Formula

CAGR Calculation:

    Formula: CAGR = (Last_Year_Revenue / First_Year_Revenue)^(1 / Years) - 1

Applied per company across each company's actual reporting span
For companies with full 2009-2022 reporting (most): 13-year window
For PYPL: 2014-2022 (post-IPO; 8-year window)
For SHLDQ: 2009-2018 (pre-bankruptcy; 9-year window)
For NVDA: 2009-2022 used for fair comparison (excludes partial 2023 reporting boost)

### Outlier Definition

Outliers were identified using the 1.5×IQR rule, applied separately to revenue, net income, market cap, and net profit margin. This method flags values that sit far outside the typical range of each metric without imposing arbitrary thresholds. 
The approach is intentionally statistical rather than judgment‑based, ensuring that extreme observations whether driven by scale (AAPL, AMZN) or distress (PCG, SHLDQ) are captured consistently across the dataset.

### Sector Taxonomy

Companies were grouped into nine sectors based on their primary business model in the 2009–2022 period. 
Because the dataset contains only one company in most sectors, sector‑level results often reflect individual company behaviour rather than broad industry dynamics. 
This taxonomy is therefore descriptive rather than comprehensive: Logistics is effectively Amazon, Electronics is INTC + NVDA, and Banking is AIG + BCS. 
The goal is consistency ensuring each company is evaluated within a stable, clearly defined sector framework.

### Year Range

2009-2022 used for comparability; 2023 excluded as partial reporting (only 
AMZN and NVDA reported full 2023 figures).

### Units Convention

- **Revenue and net income:** millions of USD
- **Market cap:** billions of USD  
- **Aggregate cards:** trillions of USD (with units labelled explicitly to 
  prevent misreading)

### Data Cleaning

The raw Kaggle dataset required substantial normalisation before analysis. 

Column names were standardised, duplicated fields removed, and sector labels harmonised to ensure consistent grouping across companies.Missing or partial rows were excluded rather than imputed to avoid introducing artificial trends into long‑run time‑series calculations. 

Finally, revenue, net income, and market‑cap fields were converted into consistent units and data types, enabling accurate SQL aggregation and Power BI modelling.

## Caveats and Limitations

This analysis is rigorous within its constraints, but several limitations 
warrant explicit acknowledgment:

**Dataset selection bias.** The 12 companies in this dataset were curated 
rather than randomly sampled. Companies that survived to be included are 
disproportionately winners or extreme cases (textbook decliners). 
Aggregate findings ("revenue never declined year-over-year") should not be 
generalised to the broader economy.

**Trillion-dollar megacap distortion.** AAPL, GOOG, MSFT, and AMZN are 
substantially larger than the other eight companies and dominate every 
absolute-value comparison. Percentage-based comparisons (CAGR, NPM) provide 
a more level analytical lens, but aggregate metrics inevitably reflect 
megacap behaviour.

**Sector analysis constrained by dataset shape.** Most sectors contain only 
one company, so "sector analysis" reduces to individual company analysis 
for those sectors. Meaningful cross-sector comparison was only possible for 
Technology (3 companies) and Electronics (2).

**2017 net income compression is a tax-code artefact.** The dip visible 
across multiple US-headquartered companies in 2017 reflects the Tax Cuts 
and Jobs Act causing one-time tax charges on overseas profits not real 
margin compression. This was specifically caveated in Q2's NPM trend 
analysis.

**SHLDQ's "Finance" classification is post-bankruptcy holding structure.** 
Sears was historically a retail conglomerate. The dataset's classification 
likely reflects the post-bankruptcy holding company arrangement rather than 
the company's actual business throughout the analysis period.

**2023 data partial.** Only AMZN and NVDA reported full 2023 figures; 
2023 is excluded from the primary analysis to maintain like-for-like 
comparison.

**Loss-year classification is interpretive.** Distinguishing growth-investment 
losses (AMZN) from structural distress losses (AIG, BCS) requires external 
context about each company's business model and strategic stance. 
The classification is defensible but not purely data-driven.

## Tools and Reproducibility

To reproduce this analysis:

1. **Download the dataset** from [Kaggle](https://www.kaggle.com/datasets/rish59/financial-statements-of-major-companies2009-2023)
2. **Load into PostgreSQL** using `sql/00-schema.sql` and `sql/01-load.sql`
3. **Run analytical queries** from `sql/02-exploration.sql` and `sql/03-analysis.sql`
4. **The Power BI dashboard** requires Power BI Desktop; data model and DAX 
   measures are documented in this findings document

All SQL queries are commented inline. All DAX measure definitions follow 
the patterns described in the Methodology section. The dashboard is built 
on a single-table model (no separate Date dimension, because annual-grain 
data with one row per company-year doesn't benefit from one).

**Tools used:**
- PostgreSQL 18.4 (local instance)
- DBeaver (database client)
- VS Code (SQL editing, markdown authoring)
- Power BI Desktop (data model, DAX measures, visualisation)
- Git/GitHub (version control)