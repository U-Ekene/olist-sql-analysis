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

### Theme 3: Delivery performance

- **Average delivery time is 12.6 days**, with a max of 209.6 days. 
  Reasonable for Brazilian e-commerce in 2016-2018, but the long 
  tail of catastrophic delays pulls the mean up.
- **8.1% of orders are late** (7,826 of 96,478). Most cause the 
  bulk of customer-service load even though they're a small share 
  of total volume.
- **Northeast Brazil has the worst delivery performance.** Alagoas 
  (24% late), Maranhão (20%), Piauí (16%) all run 2-3× the national 
  rate. Distance from southern distribution hubs is the likely driver.
- **Rio de Janeiro is the standout among high-volume states** at 
  13.5% late on 12,350 orders, generating 1,664 absolute late 
  orders — more than the entire Northeast combined. The biggest 
  operational lever isn't the worst-rate state, it's the worst 
  state by absolute count.
- **Delivery performance was volatile in late 2017 / early 2018.** 
  Stable 3-5% late through most of 2017, then Black Friday 2017 
  hit 14.3% late, followed by a sustained crisis in Feb-March 2018 
  (16% then 21% late) before recovery. Operations didn't scale 
  smoothly with volume.

### Theme 4: Seller analysis

- **3,095 sellers, R$13.6M total revenue**, with massive spread 
  (R$3.50 to R$229,473 — a 65,500× ratio). 
- **Top 10 sellers (0.3% of total) generate ~13% of revenue**, 
  while ~80% of sellers earn below the mean. Strong concentration 
  among a small group of high-performers.
- **Two seller business models in the top 10:** high-volume sellers 
  (1,000-2,000 items, ~R$100/item) and premium sellers (~400 items, 
  ~R$500/item) — different routes to similar revenue.
- **Revenue and review quality correlate but not perfectly.** Most 
  top-10 sellers cluster between 4.0-4.3 review scores. One 
  outlier (R$188k revenue, 3.35 review score) shows a successful 
  seller with notably weaker customer satisfaction — a flag for 
  marketplace operations.
- **Supply is heavily concentrated in São Paulo:** SP has 1,849 
  sellers (60% of total) generating 64% of revenue. This explains 
  Theme 3's delivery-rate gap — sellers cluster in the southeast, 
  so orders to the Northeast travel long distances.
- **Two states punch above their weight on per-seller productivity:** 
  Bahia (R$15,029 per seller from 19 sellers) and Pernambuco 
  (R$10,165 per seller from 9 sellers) — small but high-leverage 
  markets where each seller produces 2-3× the SP average.

### Theme 5: Products & categories

- **Top revenue categories span broad consumer needs.** 
  health_beauty (R$1.26M), watches_gifts (R$1.20M), and 
  bed_bath_table (R$1.04M) lead — Olist sells across many categories 
  is a horizontal . Notable absence: no fashion-specific category in the top 10.
- **Watches/gifts has the highest revenue per item (~R$201)** — 
  roughly 2× the platform average. Premium-pricing category that 
  matches the "premium seller" profile from Theme 4.
- **Books dominate customer satisfaction** (general interest 4.45, 
  technical 4.37). Predictable products with low variability 
  reliably score higher than complex ones. Food and stationery 
  also perform well (4.19-4.32).
- **Revenue and quality are decoupled in this marketplace.** Three 
  of the top 6 highest-revenue categories — bed_bath_table, 
  furniture_decor, computers_accessories — appear in the 
  bottom 10 by review score. The platform's biggest revenue 
  drivers are also among its weakest customer experiences.
- **Office furniture is the standout problem area** at 3.49 avg 
  review across 1,687 reviews — a clear outlier with strong 
  sample size. Bulky/fragile/technically complex products 
  consistently underperform on satisfaction, suggesting a 
  systemic shipping or expectation-mismatch issue.

### Theme 6: Advanced patterns (window functions)

- **Within-state seller rankings reveal concentration patterns 
  invisible in national rankings.** Bahia's #1 seller earned 
  R$222,776 — about 15× their state's #3, confirming Theme 4's 
  finding that BA's high per-seller average is driven by an 
  outlier. SP and other large states show much flatter top-3 
  distributions.
- **Olist hit a step-change in November 2017 (Black Friday).** 
  Order volume jumped 60% in one month and never returned to 
  pre-November levels. The platform transitioned from "ramp-up 
  startup" to "established marketplace" in that single month.
- **Most of the dataset's growth happened in the second half.** 
  It took 16 months to reach the first 50,000 orders, but only 
  8 months to reach the next 46,000. 
- **Growth flattened in mid-2018.** Month-over-month change 
  bounces between -10% and +3% from April 2018 onward, with no 
  sustained direction. The platform stabilized around 
  6,000-7,000 orders per month — neither growing nor declining.
- **The Feb-March 2018 delivery crisis (Theme 3) directly 
  followed the Black Friday volume jump.** Operations couldn't 
  scale with the new normal, and late delivery rates spiked 
  to 16-21% before recovery in April.

---
