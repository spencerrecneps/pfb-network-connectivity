
-- set block-based score
UPDATE  neighborhood_census_blocks
SET     hospitals_score =   CASE
                            WHEN hospitals_high_stress IS NULL THEN NULL
                            WHEN hospitals_high_stress = 0 THEN NULL
                            WHEN hospitals_low_stress = 0 THEN 0
                            WHEN hospitals_high_stress = hospitals_low_stress THEN :max_score
                            WHEN :first = 0 THEN hospitals_low_stress::FLOAT / hospitals_high_stress
                            WHEN :second = 0
                                THEN    :first
                                        + ((:max_score - :first) * (hospitals_low_stress::FLOAT - 1))
                                        / (hospitals_high_stress - 1)
                            WHEN :third = 0
                                THEN    CASE
                                        WHEN hospitals_low_stress = 1 THEN :first
                                        WHEN hospitals_low_stress = 2 THEN :first + :second
                                        ELSE :first + :second
                                                + ((:max_score - :first - :second) * (hospitals_low_stress::FLOAT - 2))
                                                / (hospitals_high_stress - 2)
                                        END
                            ELSE        CASE
                                        WHEN hospitals_low_stress = 1 THEN :first
                                        WHEN hospitals_low_stress = 2 THEN :first + :second
                                        WHEN hospitals_low_stress = 3 THEN :first + :second + :third
                                        ELSE :first + :second + :third
                                                + ((:max_score - :first - :second - :third) * (hospitals_low_stress::FLOAT - 3))
                                                / (hospitals_high_stress - 3)
                                        END
                            END;
