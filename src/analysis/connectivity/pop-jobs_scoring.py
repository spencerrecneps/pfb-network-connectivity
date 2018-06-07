import psycopg2
from psycopg2 import sql

conn = psycopg2.connect('host=192.168.30.220 dbname=anne_arundel user=gis password=gis')

a = {
  "destination_id": sql.Identifier("blockid10"),
  "destination_block_ids": sql.Identifier("blockid10"),
  "destinations": sql.Identifier("neighborhood_census_blocks"),
  "block_connections": sql.Identifier("neighborhood_connected_census_blocks"),
  "source_block": sql.Identifier("source_blockid10"),
  "target_block": sql.Identifier("target_blockid10"),
  "connection_true": sql.Identifier("high_stress"),
  "blocks": sql.Identifier("neighborhood_census_blocks"),
  "block_id": sql.Identifier("blockid10"),
  "score_attribute": sql.Identifier("pop_high_stress"),
  "val": sql.Identifier("pop10")
}

f = open("pop-jobs_access_calc.sql")
raw = f.read()
f.close()


print("processing pop")
print("high stress...")
a["destinations"] = sql.Identifier("neighborhood_census_blocks")
a["connection_true"] = sql.Literal(True)
a["score_attribute"] = sql.Identifier("pop_high_stress")
q = sql.SQL(raw).format(**a)
cur = conn.cursor()
cur.execute(q)
conn.commit()
cur.close()

print("low stress...")
a["connection_true"] = sql.Identifier("low_stress")
a["score_attribute"] = sql.Identifier("pop_low_stress")
q = sql.SQL(raw).format(**a)
cur = conn.cursor()
cur.execute(q)
conn.commit()
cur.close()


print("processing emp")
print("high stress...")
a["destinations"] = sql.Identifier("neighborhood_census_block_jobs")
a["connection_true"] = sql.Literal(True)
a["score_attribute"] = sql.Identifier("emp_high_stress")
a["val"] = sql.Identifier("jobs")
q = sql.SQL(raw).format(**a)
cur = conn.cursor()
cur.execute(q)
conn.commit()
cur.close()

print("low stress...")
a["connection_true"] = sql.Identifier("low_stress")
a["score_attribute"] = sql.Identifier("emp_low_stress")
q = sql.SQL(raw).format(**a)
cur = conn.cursor()
cur.execute(q)
conn.commit()
cur.close()
