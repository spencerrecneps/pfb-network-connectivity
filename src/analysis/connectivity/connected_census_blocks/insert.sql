












INSERT INTO generated.neighborhood_connected_census_blocks (
    source_blockid10, target_blockid10, high_stress_cost,
)
SELECT  source.blockid10,
        target.blockid10
FROM    generated.neighborhood_census_blocks source,
        generated.neighborhood_census_blocks target
WHERE   ST_DWithin(source.geom,target.geom,2680);     -- max trip distance
