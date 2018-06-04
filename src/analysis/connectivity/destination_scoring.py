import psycopg2
from psycopg2 import sql

conn = psycopg2.connect('host=192.168.40.225 dbname=bna_london user=gis password=gis')

a = {
  "destination_id": sql.Identifier("path_id"),
  "destination_block_ids": sql.Identifier("blockid10"),
  "destinations": sql.Identifier("neighborhood_paths"),
  "block_connections": sql.Identifier("neighborhood_connected_census_blocks"),
  "source_block": sql.Identifier("source_blockid10"),
  "target_block": sql.Identifier("target_blockid10"),
  "connection_true": sql.Identifier("high_stress"),
  "blocks": sql.Identifier("neighborhood_census_blocks"),
  "block_id": sql.Identifier("blockid10"),
  "score_attribute": sql.Identifier("trails_high_stress")
}

f = open("generalized_access_calc.sql")
raw = f.read()
f.close()

dests = [
    "colleges",
    "community_centers",
    "doctors",
    "dentists",
    "hospitals",
    "pharmacies",
    "parks",
    "retail",
    "schools",
    "social_services",
    "supermarkets",
    "transit",
    "universities"
]

for d in dests:
print("processing " + d)
print("high stress...")
a["destinations"] = sql.Identifier("neighborhood_" + d)
a["connection_true"] = sql.Identifier("high_stress")
a["score_attribute"] = sql.Identifier(d + "_high_stress")
q = sql.SQL(raw).format(**a)
cur = conn.cursor()
cur.execute(q)
conn.commit()
cur.close()
print("low stress...")
a["connection_true"] = sql.Identifier("low_stress")
a["score_attribute"] = sql.Identifier(d + "_low_stress")
q = sql.SQL(raw).format(**a)
cur = conn.cursor()
cur.execute(q)
conn.commit()
cur.close()
