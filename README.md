## Beverage Distribution Sales Analysis
### Uncovering channel performance and supplier trends 
across a 300K+ row wholesale dataset

---
### Why This Matters
This project was built to demonstrate practical SQL skills
that apply directly to data analyst roles — specifically the
ability to work with messy, real-world data rather than
clean, pre-formatted datasets.

The goal was to go beyond basic SELECT queries and show:
- How to identify and handle data quality issues
- How to extract business insights from raw transactional data
- How to design and populate a normalized relational schema
- How to verify results by comparing outputs across approaches

This dataset was chosen because it reflects the kind of
data a junior analyst would realistically encounter —
inconsistent categories, missing values, unexpected entries,
and a flat structure that needed to be redesigned.

---
### Tools
PostgreSQL

---

### Dataset
307,645 rows | 2020 fiscal year | 396 suppliers | 9 product categories

---

### Business Questions To Answer
1. Which product category drives the most revenue by channel?
2. What does the seasonal sales curve look like across the year?
3. Who are the top 10 suppliers by warehouse volume?
4. Are there products being sold at retail with no warehouse record?
5. How many products exist per category?

---

### Key Findings
- 🍺 BEER dominates warehouse distribution at $6.5M — nearly 6x higher than WINE
- 🥃 LIQUOR leads retail sales at $802K despite low warehouse volume
- 📅 July is the peak retail month at $277K — April is the slowest at $80K
- 🏆 Crown Imports leads all suppliers at $1.65M in warehouse sales
- ⚠️ 10 products have retail sales but zero warehouse records

---

### Data Quality Findings
- 1,129 dead rows removed (0.37% of dataset)
- 167 rows with unknown suppliers flagged rather than deleted
- 9 item types discovered vs 3 expected
- Negative warehouse values found in DUNNAGE and REF — likely returns

---

### Project Structure
Warehouse-Retail-Sales-SQL/
│
├── sql/
│   ├── 01_setup.sql
│   ├── 02_cleaning.sql
│   ├── 03_exploration.sql
│   ├── 04_schema.sql
│
├── data/
│   ├── warehouse_retail_sales.csv
│
├── README.md
