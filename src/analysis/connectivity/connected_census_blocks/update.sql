----------------------------------------
-- INPUTS
-- location: neighborhood
-- :nb_max_trip_distance psql var must be set before running this script,
--      e.g. psql -v nb_max_trip_distance=2680 -f reachable_roads_high_stress_calc.sql
----------------------------------------
UPDATE  generated.neighborhood_connected_census_blocks AS ccb
SET     high_stress_cost = route.agg_cost
FROM    neighborhood_ways_net_vert sv,
        neighborhood_ways_net_vert tv,
        pgr_dijkstracost('
            SELECT  link_id AS id,
                    source_vert AS source,
                    target_vert AS target,
                    link_cost AS cost
            FROM    neighborhood_ways_net_link
            WHERE   blockid10 IS NULL
            OR      blockid10 IN (''{source}'',''{target}'')',
            sv.vert_id,
            tv.vert_id
        ) route
WHERE   {source} = sv.blockid10
AND     {target} = tv.blockid10;


UPDATE generated.neighborhood_connected_census_blocks
SET high_stress = TRUE WHERE high_stress_cost <= 2680;


CREATE INDEX nbccb_histress ON neighborhood_connected_census_blocks (high_stress)
    WHERE high_stress IS TRUE;


UPDATE  generated.neighborhood_connected_census_blocks AS ccb
SET     low_stress_cost = route.agg_cost
FROM    neighborhood_ways_net_vert sv,
        neighborhood_ways_net_vert tv,
        pgr_dijkstracost('
            SELECT  link_id AS id,
                    source_vert AS source,
                    target_vert AS target,
                    link_cost AS cost
            FROM    neighborhood_ways_net_link
            WHERE   link_stress = 1
            AND     (blockid10 IS NULL
                    OR blockid10 IN (''{source}'',''{target}''))',
            sv.vert_id,
            tv.vert_id
        ) route
WHERE   {source} = sv.blockid10
AND     {target} = tv.blockid10;

UPDATE generated.neighborhood_connected_census_blocks
SET low_stress = TRUE
WHERE high_stress
AND low_stress_cost::FLOAT / high_stress_cost <= 1.25;


CREATE INDEX nbccb_lostress ON neighborhood_connected_census_blocks (low_stress)
    WHERE low_stress IS TRUE;
