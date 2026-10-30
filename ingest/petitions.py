# ingest/petitions.py
import json

import duckdb
import pandas as pd
import requests

con = duckdb.connect("data/warehouse.duckdb")
con.execute("create schema if not exists raw")
rows = []
for page in range(1, 6):
    r = requests.get(
        "https://petition.parliament.uk/petitions.json",
        params={"state": "open", "page": page},
    ).json()
    rows += [{"id": p["id"], "payload": json.dumps(p)} for p in r["data"]]

df = pd.DataFrame(rows)
con.execute("create or replace table raw.petitions as select * from df")
print(con.execute("select count(*) from raw.petitions").fetchone())
con.close()
