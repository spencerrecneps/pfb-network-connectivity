----------------------------------------
-- INPUTS
-- location: neighborhood
-- :nb_max_trip_distance psql var must be set before running this script,
--      e.g. psql -v nb_max_trip_distance=2680 -f reachable_roads_high_stress_calc.sql
----------------------------------------
UPDATE  generated.neighborhood_connected_census_blocks AS ccb
SET     high_stress_cost = route.agg_cost,
        high_stress = CASE WHEN route.agg_cost <= 2680 THEN TRUE ELSE FALSE END
FROM    neighborhood_ways_net_vert sv,
        neighborhood_ways_net_vert tv,
        pgr_dijkstracost('
            SELECT  link_id AS id,
                    source_vert AS source,
                    target_vert AS target,
                    link_cost AS cost
            FROM    neighborhood_ways_net_link
            WHERE   blockid10 IS NULL OR blockid10 IN ('''||{source}||''','''||{target}||''')',
            sv.vert_id,
            tv.vert_id
        ) route
WHERE   {source} = sv.blockid10
AND     {target} = tv.blockid10;
