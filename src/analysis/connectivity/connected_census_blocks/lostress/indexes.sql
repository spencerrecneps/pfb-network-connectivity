CREATE INDEX nbccb_lostress ON neighborhood_connected_census_blocks (low_stress)
    WHERE low_stress IS TRUE;
