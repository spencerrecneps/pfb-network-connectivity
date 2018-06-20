import psycopg2
from psycopg2 import sql

conn = psycopg2.connect('host=192.168.40.225 dbname=alameda_ctc user=gis password=gis')

a = {
  "destination_id": sql.Identifier("id"),
  "destination_block_ids": sql.Identifier("blockid10"),
  "destinations": sql.Identifier("comprehensive_data_paths"),
  "block_connections": sql.Identifier("existing_connected_census_blocks"),
  "source_block": sql.Identifier("source_blockid10"),
  "target_block": sql.Identifier("target_blockid10"),
  "connection_true": sql.Identifier("high_stress"),
  "blocks": sql.Identifier("comprehensive_data_census_blocks"),
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
    "universities",
    "paths"
]

for d in dests:
    print("processing " + d)
    print("high stress...")
    if d == "paths":
        a["destination_id"] = sql.Identifier("path_id")
        a["score_attribute"] = sql.Identifier("trails_high_stress")
        a["destinations"] = sql.Identifier("comprehensive_data_paths")
    else:
        a["destination_id"] = sql.Identifier("id")
        a["score_attribute"] = sql.Identifier(d + "_high_stress")
        a["destinations"] = sql.Identifier("neighborhood_" + d)
    a["connection_true"] = sql.Literal(True)
    q = sql.SQL(raw).format(**a)
    cur = conn.cursor()
    cur.execute(q)
    conn.commit()
    cur.close()
    print("low stress...")
    if d == "paths":
        a["score_attribute"] = sql.Identifier("trails_low_stress")
    else:
        a["destination_id"] = sql.Identifier("id")
        a["score_attribute"] = sql.Identifier(d + "_low_stress")
    a["connection_true"] = sql.Identifier("low_stress")
    q = sql.SQL(raw).format(**a)
    cur = conn.cursor()
    cur.execute(q)
    conn.commit()
    cur.close()





# update planned_facilities_census_blocks as c1
# set
#     colleges_high_stress = c2.colleges_high_stress,
#     community_centers_high_stress = c2.community_centers_high_stress,
#     doctors_high_stress = c2.doctors_high_stress,
#     dentists_high_stress = c2.dentists_high_stress,
#     hospitals_high_stress = c2.hospitals_high_stress,
#     pharmacies_high_stress = c2.pharmacies_high_stress,
#     parks_high_stress = c2.parks_high_stress,
#     retail_high_stress = c2.retail_high_stress,
#     schools_high_stress = c2.schools_high_stress,
#     social_services_high_stress = c2.social_services_high_stress,
#     supermarkets_high_stress = c2.supermarkets_high_stress,
#     transit_high_stress = c2.transit_high_stress,
#     universities_high_stress = c2.universities_high_stress,
#     trails_high_stress = c2.trails_high_stress,
#     pop_high_stress = c2.pop_high_stress,
#     emp_high_stress = c2.emp_high_stress
# from comprehensive_data_census_blocks c2
# where c1.blockid10 = c2.blockid10
