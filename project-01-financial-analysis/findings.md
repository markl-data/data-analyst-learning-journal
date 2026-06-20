## SCHEMA CLEANUP (Day 18, Block 2): 
- The Kaggle CSV loaded with duplicate columns: an empty snake_case set
- and a populated Title Case set. The snake_case empties were dropped,
- and the Title Case populated columns were renamed to snake_case for
- SQL clarity. The "Debt/Equity Ratio" column was renamed to 
- "debt_equity_ratio" (slash removed for compatibility).