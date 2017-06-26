------------------------------------------
-- inputs
--   db_srid
------------------------------------------
DROP TABLE IF EXISTS neighborhood_census_blocks;
DROP TABLE IF EXISTS neighborhood_census_block_jobs;

CREATE TABLE neighborhood_census_blocks (
    id SERIAL PRIMARY KEY,
    geom geometry(multipolygon,:db_srid),
    blockid10 VARCHAR(15),
    pop10 INTEGER
);

CREATE TABLE neighborhood_census_block_jobs (
    id SERIAL PRIMARY KEY,
    geom geometry(multipolygon,:db_srid),
    blockid10 VARCHAR(15),
    jobs INTEGER
);

------------------------------------------
-- create blocks
------------------------------------------
INSERT INTO neighborhood_census_blocks (pop10, geom)
SELECT  100,
        ST_Multi((ST_Dump(ST_Polygonize(geom))).geom)
FROM    neighborhood_ways
WHERE   functional_class != 'path';

DELETE FROM neighborhood_census_blocks AS cb1
USING   neighborhood_boundary AS nb
WHERE   NOT ST_Intersects(cb1.geom,nb.geom);
DELETE FROM neighborhood_census_blocks WHERE ST_Area(geom) < 1000;
DELETE FROM neighborhood_census_blocks WHERE ST_Area(geom) * 2 / ST_Perimeter(geom) < 15;
