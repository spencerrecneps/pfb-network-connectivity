----------------------------------------
-- INPUTS
-- location: neighborhood
----------------------------------------
UPDATE  neighborhood_ways SET speed_limit = NULL;

UPDATE  neighborhood_ways
SET     speed_limit = substring(osm.maxspeed from '\d+')::INT
FROM    neighborhood_osm_full_line osm
WHERE   neighborhood_ways.osm_id = osm.osm_id
AND     osm.maxspeed LIKE '% mph';

UPDATE  neighborhood_ways
SET     speed_limit = (osm.maxspeed::INT * 0.621371)::INT
FROM    neighborhood_osm_full_line osm
WHERE   neighborhood_ways.osm_id = osm.osm_id
AND     osm.maxspeed NOT LIKE '%mph%';
