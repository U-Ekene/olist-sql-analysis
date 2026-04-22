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

(To be filled in as analysis completes.)

---