CREATE INDEX nbccb_histress ON neighborhood_connected_census_blocks (high_stress)
    WHERE high_stress IS TRUE;
