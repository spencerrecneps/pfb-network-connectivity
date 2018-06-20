
-- set block-based score
UPDATE  comprehensive_data_census_blocks
SET     trails_score =  CASE
                        WHEN trails_high_stress IS NULL THEN NULL
                        WHEN trails_high_stress = 0 THEN NULL
                        WHEN trails_low_stress = 0 THEN 0
                        WHEN trails_high_stress = trails_low_stress THEN :max_score
                        WHEN :first = 0 THEN trails_low_stress::FLOAT / trails_high_stress
                        WHEN :second = 0
                            THEN    :first
                                    + ((:max_score - :first) * (trails_low_stress::FLOAT - 1))
                                    / (trails_high_stress - 1)
                        WHEN :third = 0
                            THEN    CASE
                                    WHEN trails_low_stress = 1 THEN :first
                                    WHEN trails_low_stress = 2 THEN :first + :second
                                    ELSE :first + :second
                                            + ((:max_score - :first - :second) * (trails_low_stress::FLOAT - 2))
                                            / (trails_high_stress - 2)
                                    END
                        ELSE        CASE
                                    WHEN trails_low_stress = 1 THEN :first
                                    WHEN trails_low_stress = 2 THEN :first + :second
                                    WHEN trails_low_stress = 3 THEN :first + :second + :third
                                    ELSE :first + :second + :third
                                            + ((:max_score - :first - :second - :third) * (trails_low_stress::FLOAT - 3))
                                            / (trails_high_stress - 3)
                                    END
                        END;
