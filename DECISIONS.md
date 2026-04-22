# Design Decisions

A log of key decisions made during this project and the reasoning 
behind them.

## Dataset: Olist Brazilian E-Commerce

Chose the Olist dataset (9 related tables, ~100k orders) over 
simpler alternatives like Chinook or NYC Taxi. Olist offers:
- Real multi-table relationships requiring meaningful joins
- Authentic data quality issues (missing values, mixed languages, 
  inconsistent timestamps)
- Rich analytical angles across delivery, sellers, customers, 
  and products

This better reflects the data conditions of a real analytics 
environment.

## Database: SQLite

Chose SQLite for this project because it requires zero setup (no 
server, no user management, no port configuration) and the SQL 
syntax is standard. The analysis doesn't need concurrent access, 
replication, or the other features PostgreSQL provides, so the 
added complexity isn't justified.

A PostgreSQL migration is planned for a future version.

## Analysis Structure: Business Themes

Organized queries around business themes (delivery performance, 
seller analysis, etc.) rather than SQL complexity tiers (basic → 
joins → window functions). 

Rationale: a theme-based structure reads as analytical work rather 
than a syntax exercise, and SQL complexity grows naturally as the 
business questions become more sophisticated.

## Data Loading: Python Script

Created `load_data.py` to load CSVs into SQLite programmatically 
rather than using a GUI tool. This makes the project reproducible 
— anyone cloning the repo can run one command and recreate the 
database.

## Repository Hygiene

- Raw CSVs are gitignored due to size and redistribution concerns. 
  Download instructions are provided in the README.
- The generated SQLite database file is also gitignored as a 
  build artifact.