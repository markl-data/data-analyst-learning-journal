# Capstone: Lending Club Loan Default Analysis

## Capstone Narrative Arc

This analysis conducts a four-stage audit of Lending Club's credit risk 
management, moving from baseline validation → segmentation → temporal 
stability → improvement potential.

Each question builds on the previous, producing a coherent findings 
narrative rather than isolated observations.

- Q1: Baseline (does grade work as risk indicator?)
- Q2: Segmentation (where does risk concentrate by loan purpose?)
- Q3: Stability (has grade calibration held over time?)  
- Q4: Improvement (do borrower characteristics add signal beyond grade?)

## Q1 — Grade as Default Predictor

**What I'll compute:** Default rate (% Charged Off) by loan grade A–G, computed on terminal loans only (Fully Paid vs Charged Off), with sample sizes and confidence intervals for each grade.

**Anticipated finding shape:** Either a steep, monotonic gradient (e.g., Grade A ~5–6% vs Grade G ~35–50%) confirming that Lending Club’s grading is strongly risk‑differentiated, or pockets of non‑monotonicity where specific grades/sub‑grades appear mispriced.

**Narrative significance:** Establishes how well the existing risk‑grading system works and becomes the baseline against which all later borrower‑ and loan‑level drivers are compared.

---

## Q2 — Default by Purpose / Segment

**What I'll compute:** Default rate by primary loan purpose (e.g., debt consolidation, credit card, small business, home improvement), restricted to terminal loans, with both rate and share of total losses per purpose.

**Anticipated finding shape:** A defensible result would show that certain purposes (e.g., small business, renewable energy) have materially higher default rates and/or outsized contributions to total portfolio losses compared with mainstream purposes like debt consolidation.

**Narrative significance:** Reveals which economic uses of credit are structurally riskier, adding a segmentation layer on top of grade and showing where Lending Club’s portfolio is most exposed.

---

## Q3 — Default Over Time (Temporal Stability)

**What I'll compute:** Default rate by issue year (and optionally by grade within year), using only terminal loans, to trace how overall risk and grade‑level calibration have changed across the 11‑year window.

**Anticipated finding shape:** Either a stable pattern where grade separation remains consistent over time, or evidence of drift/compression (e.g., rising default rates in later cohorts, weaker separation between grades) that suggests changing underwriting or macro conditions.

**Narrative significance:** Connects the static grade analysis to time, showing whether Lending Club’s risk model has remained robust or degraded, and framing the capstone as an audit of temporal stability in credit risk.

---

## Q4 — Borrower Characteristics Beyond Grade

**What I'll compute:** Default rate across bins/deciles of key borrower features (DTI, income, FICO, employment length), both overall and within grade bands, to test whether these characteristics add predictive power beyond the existing grade.

**Anticipated finding shape:** A compelling result would show clean, monotonic relationships (e.g., higher DTI deciles or lower income/FICO bands with sharply higher default) that persist even when controlling for grade, indicating under‑captured risk drivers.

**Narrative significance:** This becomes the capstone’s deeper insight: it shows whether a borrower‑feature‑based model could refine or outperform Lending Club’s grade system, and sets up a narrative about how underwriting could be improved using richer borrower signals.

## Data & Methodology

### Sampling Strategy
We use **Option A — a 200K stratified sample** drawn from the full 2.26M‑row Lending Club dataset.  
Stratification preserves the true proportion of terminal outcomes (Fully Paid vs Charged Off), ensuring the development sample remains representative of the full portfolio.  
All exploratory analysis, feature engineering, and model development occur on this 200K sample, with **final validation performed on the full dataset**.

---

### Column Feature Set
Our refined feature set consists of ~28 columns grouped into two modelling categories and two exclusion categories.

#### Core Loan Fields
- id  
- loan_amnt  
- funded_amnt  
- term  
- int_rate  
- installment  
- grade  
- sub_grade  
- loan_status  
- purpose  
- issue_d  
- application_type  
- addr_state  

#### Borrower Characteristics
- annual_inc  
- verification_status  
- emp_length  
- home_ownership  
- dti  
- fico_range_low  
- fico_range_high  
- earliest_cr_line  
- open_acc  
- total_acc  
- revol_bal  
- revol_util  
- inq_last_6mths  
- delinq_2yrs  
- mths_since_last_delinq  

---

### Default Definition
We define **default** strictly as **Charged Off** — the only legally final outcome indicating loan failure.  
All other statuses (Fully Paid, Current, Late, Grace Period, Default) are excluded from the primary target.  
A secondary “distressed” label may be created for early‑warning analysis, grouping Late, Grace Period, and Default statuses together, but this is not used for the main predictive modelling.

---

### Excluded Data
The following columns are excluded due to leakage risk, sparsity, conditionality, or irrelevance to origination‑based modelling:

#### Post‑Origination Outcomes (Leakage)
- total_pymnt  
- recoveries  
- collection_recovery_fee  
- last_pymnt_d  
- last_credit_pull_d  
- chargeoff_within_12_mths  

#### Joint Application Fields (Conditional / Sparse)
- All `sec_app_*` fields  
- All `_joint` fields  

#### Hardship / Settlement Fields (Conditional / Rare)
- All `hardship_*` fields  
- All `settlement_*` fields  

#### Free‑Text Fields (Unstructured / Not Model‑Ready)
- desc  
- title  
- emp_title  
- url  
- member_id  

#### Operational / Structural Fields
- policy_code  
- batch_enrolled  

#### High‑Null / Niche Credit Behaviour Fields
- mths_since_recent_bc_dlq  
- mths_since_recent_inq  
- mths_since_recent_revol_delinq  
- mths_since_recent_bc  
- num_tl_120dpd_2m  
- num_tl_30dpd  

---

This methodology section defines the analytical foundation for the capstone: a clean sample, a disciplined feature set, a strict default definition, and a clear exclusion policy that prevents leakage and ensures model validity.


## Not in Scope

The following are deliberately excluded to keep the capstone focused:

- **Predictive modelling (ML classification):** This project provides 
  descriptive and diagnostic analysis of credit risk, not a predictive 
  model. Modeling is a natural follow-up piece.
- **Joint applications:** Excluded due to rarity and different risk profile.
- **Hardship and settlement analysis:** Deferred to future work.
- **Investor-side analysis:** How different investor strategies performed 
  is separate scope.
- **External economic overlay:** Comparison to macro indicators (rates, 
  unemployment) requires additional data sources.

  ## Deliverables (Phase 4)

- Cleaned dataset (SQL-loaded, quality-checked)
- Analysis notebook(s) (SQL + pandas)
- Power BI dashboard for portfolio audience
- `findings.md` polished document
- README with reproducibility instructions
