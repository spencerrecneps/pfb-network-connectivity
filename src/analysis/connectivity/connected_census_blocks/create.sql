----------------------------------------
-- INPUTS
-- location: neighborhood
-- :nb_max_trip_distance and :nb_output_srid psql vars must be set before running this script,
--      e.g. psql -v nb_max_trip_distance=2680 -v nb_output_srid=2163 -f connected_census_blocks.sql
----------------------------------------
DROP TABLE IF EXISTS generated.neighborhood_connected_census_blocks;

CREATE TABLE generated.neighborhood_connected_census_blocks (
    id SERIAL PRIMARY KEY,
    source_blockid10 VARCHAR(15),
    target_blockid10 VARCHAR(15),
    low_stress BOOLEAN,
    low_stress_cost INT,
    high_stress BOOLEAN,
    high_stress_cost INT
);
