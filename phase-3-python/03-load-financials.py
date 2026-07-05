import pandas as pd

# Load the CSV
df = pd.read_csv("data/Financial Statements.csv")

# First look
print(df.head())
print()
print(df.shape)
print()
print(df.columns.tolist())

# Five inspection methods (the standard "what is this?" toolkit)
print(df.head())
print()
print(df.shape)
print()  
print(df.dtypes)
print()
print(df.describe())
print()

# Companies in the data
print(df["Company"].unique())
print()

# Year range
print(df["Year"].min(), "to", df["Year"].max())
print()

# Rows per company (sanity check)
print(df["Company"].value_counts())

# Create a sector column from Category
# Same mapping we did in SQL Day 18
sector_map = {
    "IT": "Technology",
    "Tech": "Technology",
    "Software": "Technology",  
    "Logistics": "Logistics",
    "ELEC": "Electronics",
    "Electronics": "Electronics",
    "Bank": "Banking",
    "BANK": "Banking",
    "Finance": "Finance",
    "FinTech": "FinTech",
    "Manufacturing": "Manufacturing",
    "Food": "Food & Beverage",
    "F&B": "Food & Beverage",
}

# Look at what's actually in the Category column first
print(df["Category"].unique())
print()
