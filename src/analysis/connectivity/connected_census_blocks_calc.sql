----------------------------------------
-- INPUTS
-- location: neighborhood
-- vars:
--      :nb_max_trip_distance
--      :nb_max_deviation
--      :thread_num
--      :thread_no
--      e.g. psql -v nb_max_trip_distance=3300 -v thread_num=1 -v thread_no=8 -f connected_census_blocks.sql
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

INSERT INTO generated.neighborhood_connected_census_blocks (
    source_blockid10, target_blockid10,
    low_stress, low_stress_cost, high_stress, high_stress_cost
)
SELECT  source.blockid10,
        target.blockid10,
        CASE    WHEN lostress.maxcost = -1
                    THEN FALSE
                WHEN lostress.maxcost > (histress.maxcost * (1 + :nb_max_deviation))
                    THEN FALSE
                ELSE TRUE
                END,
        CASE WHEN lostress.maxcost = -1 THEN NULL ELSE lostress.maxcost END,
        TRUE,
        histress.maxcost
FROM    neighborhood_census_blocks source,
        neighborhood_census_blocks target,
        (
            SELECT  array_agg(v.vert_id) AS vert_ids
            FROM    neighborhood_ways_net_vert v
            WHERE   v.road_id = ANY(source.road_ids)
        ) source_verts,
        (
            SELECT  array_agg(v.vert_id) AS vert_ids
            FROM    neighborhood_ways_net_vert v
            WHERE   v.road_id = ANY(target.road_ids)
        ) target_verts,
        (
            SELECT  COALESCE(MAX(agg_cost),-1) AS maxcost
            FROM    pgr_dijkstraCost('
                        SELECT  link_id AS id,
                                source_vert AS source,
                                target_vert AS target,
                                link_cost AS cost
                        FROM    neighborhood_ways_net_link',
                        source_verts.vert_ids,
                        target_verts.vert_ids,
                        directed := true
        )) histress,
        (
            SELECT  COALESCE(MAX(agg_cost),-1) AS maxcost
            FROM    pgr_dijkstraCost('
                        SELECT  link_id AS id,
                                source_vert AS source,
                                target_vert AS target,
                                link_cost AS cost
                        FROM    neighborhood_ways_net_link
                        WHERE   link_stress = 1',
                        source_verts.vert_ids,
                        target_verts.vert_ids,
                        directed := true
        )) lostress
WHERE   source.id % :thread_num = :thread_no
WHERE   ST_Intersects(source.geom,neighborhood_boundary.geom)
AND     ST_DWithin(source.geom,target.geom,:nb_max_trip_distance);
