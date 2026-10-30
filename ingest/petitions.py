import json
import os

import duckdb
import pandas as pd
import requests

os.makedirs("data", exist_ok=True)
con = duckdb.connect("data/warehouse.duckdb")
con.execute("create schema if not exists raw")
rows = []
for page in range(1, 6):
    resp = requests.get(
        "https://petition.parliament.uk/petitions.json",
        params={"state": "open", "page": page},
        timeout=30,
    )
    resp.raise_for_status()
    r = resp.json()
    rows += [{"id": p["id"], "payload": json.dumps(p)} for p in r["data"]]

df = pd.DataFrame(rows)
con.execute("create or replace table raw.petitions as select * from df")
print(con.execute("select count(*) from raw.petitions").fetchone())
con.close()
