
-- set block-based score
UPDATE  neighborhood_census_blocks
SET     transit_score =   CASE
                        WHEN transit_high_stress IS NULL THEN NULL
                        WHEN transit_high_stress = 0 THEN NULL
                        WHEN transit_low_stress = 0 THEN 0
                        WHEN transit_high_stress = transit_low_stress THEN :max_score
                        WHEN :first = 0 THEN transit_low_stress::FLOAT / transit_high_stress
                        WHEN :second = 0
                            THEN    :first
                                    + ((:max_score - :first) * (transit_low_stress::FLOAT - 1))
                                    / (transit_high_stress - 1)
                        WHEN :third = 0
                            THEN    CASE
                                    WHEN transit_low_stress = 1 THEN :first
                                    WHEN transit_low_stress = 2 THEN :first + :second
                                    ELSE :first + :second
                                            + ((:max_score - :first - :second) * (transit_low_stress::FLOAT - 2))
                                            / (transit_high_stress - 2)
                                    END
                        ELSE        CASE
                                    WHEN transit_low_stress = 1 THEN :first
                                    WHEN transit_low_stress = 2 THEN :first + :second
                                    WHEN transit_low_stress = 3 THEN :first + :second + :third
                                    ELSE :first + :second + :third
                                            + ((:max_score - :first - :second - :third) * (transit_low_stress::FLOAT - 3))
                                            / (transit_high_stress - 3)
                                    END
                        END;
