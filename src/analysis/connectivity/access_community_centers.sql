

-- set block-based score
UPDATE  comprehensive_data_census_blocks
SET     community_centers_score =   CASE
                                    WHEN community_centers_high_stress IS NULL THEN NULL
                                    WHEN community_centers_high_stress = 0 THEN NULL
                                    WHEN community_centers_low_stress = 0 THEN 0
                                    WHEN community_centers_high_stress = community_centers_low_stress THEN :max_score
                                    WHEN :first = 0 THEN community_centers_low_stress::FLOAT / community_centers_high_stress
                                    WHEN :second = 0
                                        THEN    :first
                                                + ((:max_score - :first) * (community_centers_low_stress::FLOAT - 1))
                                                / (community_centers_high_stress - 1)
                                    WHEN :third = 0
                                        THEN    CASE
                                                WHEN community_centers_low_stress = 1 THEN :first
                                                WHEN community_centers_low_stress = 2 THEN :first + :second
                                                ELSE :first + :second
                                                        + ((:max_score - :first - :second) * (community_centers_low_stress::FLOAT - 2))
                                                        / (community_centers_high_stress - 2)
                                                END
                                    ELSE        CASE
                                                WHEN community_centers_low_stress = 1 THEN :first
                                                WHEN community_centers_low_stress = 2 THEN :first + :second
                                                WHEN community_centers_low_stress = 3 THEN :first + :second + :third
                                                ELSE :first + :second + :third
                                                        + ((:max_score - :first - :second - :third) * (community_centers_low_stress::FLOAT - 3))
                                                        / (community_centers_high_stress - 3)
                                                END
                                    END;
