-- indexes
CREATE UNIQUE INDEX idx_neighborhood_blockpairs ON neighborhood_connected_census_blocks (source_blockid10,target_blockid10);
CREATE INDEX IF NOT EXISTS idx_neighborhood_blockpairs_lstress ON neighborhood_connected_census_blocks (low_stress) WHERE low_stress IS TRUE;
CREATE INDEX IF NOT EXISTS idx_neighborhood_blockpairs_hstress ON neighborhood_connected_census_blocks (high_stress) WHERE high_stress IS TRUE;
ANALYZE neighborhood_connected_census_blocks;
