# Olist SQL Analysis

SQL-based analysis of the Olist Brazilian E-Commerce dataset, 
covering ~100k orders across 9 related tables.

**Status:** In progress.

## About

This project explores a real-world e-commerce dataset through SQL, 
organized around business themes rather than SQL technique. The 
goal is to answer practical questions about delivery performance, 
customer behavior, seller performance, and product trends.

## Dataset

Brazilian E-Commerce Public Dataset by Olist, available on Kaggle:  
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

The dataset is not included in this repository due to size and 
licensing. To reproduce the analysis locally:

1. Download the dataset from the Kaggle link above.
2. Extract all CSV files into the `data/` folder at the project root.
3. Run `python load_data.py` to load the data into a local SQLite 
   database.

## Project Structure
olist-sql-analysis/
├── data/          # Raw CSVs (not committed)
├── sql/           # SQL queries organized by theme
├── load_data.py   # Loads CSVs into SQLite
├── DECISIONS.md   # Key design decisions
└── README.md

## Tech Stack

- Python 3 (pandas, sqlite3) for data loading
- SQLite for querying
- SQL for all analysis

## Analysis Themes

(To be expanded as work progresses.)

1. Dataset exploration
2. Customer and order patterns
3. Delivery performance
4. Seller analysis
5. Product and category insights
6. Advanced analytical patterns

## Key Findings

### Theme 1: Dataset shape

- **99,441 orders** across **25 months** (Sept 2016 – Oct 2018)
- **~97% of orders successfully delivered** meaning operational health 
  is strong
- **Heavy geographic concentration:** 3 states (SP, RJ, MG) account 
  for ~67% of all orders; São Paulo alone is 42%
- **Within SP, one city dominates:** São Paulo city has ~10× the 
  orders of the next-largest SP city (Campinas)
- **Low repeat purchase rate (~3.4%)**, this suggests Olist functioned 
  as a one-and-done marketplace rather than a loyalty-driven 
  platform during this period

### Theme 2: Customer & order patterns

- **96.9% of customers ordered exactly once** (93,099 of 96,096) there was
  near-total absence of repeat behavior. Olist functioned as a 
  one-and-done marketplace, not a loyalty platform.
- **One outlier customer placed 17 orders** — far above the rest 
  of the long tail (next-highest was 9). 
- **Order item prices range from R$0.85 to R$6,735** with a mean 
  of R$120.65. The gap between mean and the floor suggests a 
  right-skewed distribution.
- **Repeat customers cluster where total volume is highest** 
  (SP, RJ, MG) but at ~3% of customers per state, no region 
  shows disproportionately stronger loyalty than the national 
  average.
- **Average order value is highest in small, remote states** 
  (PB, AP, AC, AL — all ~R$200+) and lowest in major urban states. 
  Likely driven by shipping economics: remote shoppers reserve 
  online purchases for bigger-ticket items.

---
