import pandas as pd

# Create a Series from a list
cagrs = pd.Series([26.4, 21.0, 18.6, 9.6, 17.2])
print(cagrs)
print()  # blank line for readability

# Series with custom index labels
cagrs_by_company = pd.Series(
    [26.4, 21.0, 18.6, 9.6, 17.2],
    index=["AMZN", "GOOG", "AAPL", "MSFT", "NVDA"]
)
print(cagrs_by_company)
print()

print(cagrs_by_company["AMZN"])    # 26.4
print(cagrs_by_company["NVDA"])    # 17.2



# Create a DataFrame from a list of dicts (remember this pattern from Block 2)
companies_data = [
    {"ticker": "AMZN", "sector": "Logistics", "cagr": 26.4, "consistency": 100.0},
    {"ticker": "GOOG", "sector": "Technology", "cagr": 21.0, "consistency": 100.0},
    {"ticker": "AAPL", "sector": "Technology", "cagr": 18.6, "consistency": 84.6},
    {"ticker": "MSFT", "sector": "Technology", "cagr": 9.6, "consistency": 92.9},
    {"ticker": "NVDA", "sector": "Electronics", "cagr": 17.2, "consistency": 78.6},
]

df = pd.DataFrame(companies_data)
print(df)
print()



# Inspect the DataFrame
print(df.head(3))         # First 3 rows
print()

print(df.shape)           # (rows, columns) → (5, 4)
print()

print(df.columns.tolist()) # List of column names
print()

print(df.dtypes)          # Data type of each column
print()

print(df.describe())      # Statistical summary of numeric columns
print()



# Select a single column (returns a Series)
print(df["cagr"])
print()

# Select multiple columns (returns a DataFrame)
print(df[["ticker", "cagr"]])
print()

# Filter rows by condition (this is huge — the equivalent of SQL WHERE)
high_growth = df[df["cagr"] > 15]
print(high_growth)
print()



# Technology sector only
tech_only = df[df["sector"] == "Technology"]
print(tech_only)
print()

# Multiple conditions (note the parentheses around each — required)
high_growth_tech = df[(df["sector"] == "Technology") & (df["cagr"] > 15)]
print(high_growth_tech)
print()

# This fails — Python doesn't know how to combine two Series with `and`
df[(df["cagr"] > 15) and (df["sector"] == "Technology")]   # ERROR

# This works — `&` knows how to combine True/False arrays
df[(df["cagr"] > 15) & (df["sector"] == "Technology")]   # ✅

# The reflex to develop: any time you have multiple conditions on a DataFrame, type the parentheses before typing the conditions. Like:
df[() & ()]



# Sort by CAGR descending
sorted_df = df.sort_values("cagr", ascending=False)
print(sorted_df)
print()

# Group by sector and aggregate
sector_summary = df.groupby("sector").agg(
    avg_cagr=("cagr", "mean"),
    company_count=("ticker", "count")
)
print(sector_summary)
print()

# new_column_name = (source_column, function_to_apply)
df.groupby("sector").mean(numeric_only=True)