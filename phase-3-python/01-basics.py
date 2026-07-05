# Variables and basic types
# Python has dynamic typing — no need to declare type

revenue = 514000           # int (whole number)
npm = 0.165                # float (decimal)
company = "Amazon"         # string (text)
is_profitable = True       # bool (True/False)

# Print to see output
print(revenue)
print(npm)
print(company)
print(is_profitable)

# Check the type of a variable
print(type(revenue))       # <class 'int'>
print(type(npm))           # <class 'float'>
print(type(company))       # <class 'str'>
print(type(is_profitable)) # <class 'bool'>



# Lists — ordered, mutable collections
# Like a single-column SQL result set

companies = ["AMZN", "GOOG", "AAPL", "MSFT"]
cagrs = [26.4, 21.0, 18.6, 9.6]

# Access by index (0-based — different from SQL's ROW_NUMBER starting at 1)
print(companies[0])        # AMZN
print(companies[-1])       # MSFT (negative indexing from end)

# Slice (get a range)
print(companies[0:2])      # ['AMZN', 'GOOG']
print(companies[:3])       # ['AMZN', 'GOOG', 'AAPL']

# Lists can grow
companies.append("NVDA")
print(companies)           # ['AMZN', 'GOOG', 'AAPL', 'MSFT', 'NVDA']

# Length of a list
print(len(companies))      # 5


# Dictionaries — key-value pairs
# Like a single-row result set with named columns

company_data = {
    "ticker": "AMZN",
    "sector": "Logistics",
    "cagr": 26.4,
    "consistency": 100.0,
    "rank": 2
}

# Access by key
print(company_data["ticker"])     # AMZN
print(company_data["cagr"])       # 26.4

# Add or update a key
company_data["latest_revenue"] = 514000
print(company_data)

# Check if a key exists
print("ticker" in company_data)   # True
print("ceo" in company_data)      # False

# Get all keys, all values
print(company_data.keys())
print(company_data.values())



# A list of dicts — the natural structure for tabular data
# This IS conceptually how a pandas DataFrame is organised

companies_data = [
    {"ticker": "AMZN", "sector": "Logistics", "cagr": 26.4, "consistency": 100.0},
    {"ticker": "GOOG", "sector": "Technology", "cagr": 21.0, "consistency": 100.0},
    {"ticker": "AAPL", "sector": "Technology", "cagr": 18.6, "consistency": 84.6},
    {"ticker": "MSFT", "sector": "Technology", "cagr": 9.6, "consistency": 92.9},
]

# Loop through (we'll cover for loops more later, but you'll need to see this)
for company in companies_data:
    print(f"{company['ticker']}: {company['cagr']}% CAGR")



# Functions — reusable bits of code

def calculate_cagr(start_value, end_value, years):
    """Calculate compound annual growth rate."""
    return ((end_value / start_value) ** (1 / years) - 1) * 100

# Use the function
amzn_cagr = calculate_cagr(24509, 513983, 13)
print(f"AMZN CAGR: {amzn_cagr:.2f}%")    # Should be ~26.4%

# Multiple calls
print(f"GOOG CAGR: {calculate_cagr(23651, 282836, 13):.2f}%")
print(f"AAPL CAGR: {calculate_cagr(42905, 394328, 13):.2f}%")