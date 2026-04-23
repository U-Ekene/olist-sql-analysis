import sqlite3
import pandas as pd
from pathlib import Path

data_dir = Path("data")

def clean_table_name(filename):
    if filename.startswith("olist_"):
        filename = filename.removeprefix("olist_")
    if filename.endswith("_dataset.csv"):
        filename = filename.removesuffix("_dataset.csv")
    else:
        filename = filename.removesuffix(".csv")
    return filename

conn = sqlite3.connect("olist.db")

for csv_path in data_dir.glob("*.csv"):
    df = pd.read_csv(csv_path)
    table_name = clean_table_name(csv_path.name)
    df.to_sql(table_name, conn, if_exists="replace", index=False)
    print(f"Loaded {table_name}: {len(df)} rows")

conn.close()
print("Done")