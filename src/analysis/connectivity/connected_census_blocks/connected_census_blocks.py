import psycopg2
from psycopg2 import sql
from psycopg2.extras import DictCursor
from tqdm import tqdm


db_connection_string = " ".join([
    "dbname=" + "bna_london",
    "user=" + "gis",
    "host=" + "192.168.40.225",
    "password=" + "gis"
])
conn = psycopg2.connect(db_connection_string)

cur = conn.cursor(cursor_factory=DictCursor)
cur.execute("select * from neighborhood_connected_census_blocks where source_blockid10='000000000010595'")
# cur.execute("select * from neighborhood_connected_census_blocks")

print("Retrieving census blocks")
block_pairs = cur.fetchall()

# high stress
f = open("/home/spencer/dev/pfb-network-connectivity/src/analysis/connectivity/connected_census_blocks/histress/update.sql")
raw = f.read()
f.close()

print("Testing high stress connections")
hscur = conn.cursor()
for pair in tqdm(block_pairs):
    subs = {
        "source": sql.Literal(pair["source_blockid10"]),
        "target": sql.Literal(pair["target_blockid10"])
    }
    q = sql.SQL(raw).format(**subs)
    hscur.execute(q)
conn.commit()
del hscur

# low stress
f = open("/home/spencer/dev/pfb-network-connectivity/src/analysis/connectivity/connected_census_blocks/lostress/update.sql")
raw = f.read()
f.close()

print("Testing low stress connections")
lscur = conn.cursor()
for pair in tqdm(block_pairs):
    subs = {
        "source": sql.Literal(pair["source_blockid10"]),
        "target": sql.Literal(pair["target_blockid10"])
    }
    q = sql.SQL(raw).format(**subs)
    lscur.execute(q)
conn.commit()
del lscur
