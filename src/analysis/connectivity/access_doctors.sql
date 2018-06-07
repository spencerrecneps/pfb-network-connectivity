
-- set block-based score
UPDATE  neighborhood_census_blocks
SET     doctors_score = CASE
                        WHEN doctors_high_stress IS NULL THEN NULL
                        WHEN doctors_high_stress = 0 THEN NULL
                        WHEN doctors_low_stress = 0 THEN 0
                        WHEN doctors_high_stress = doctors_low_stress THEN :max_score
                        WHEN :first = 0 THEN doctors_low_stress::FLOAT / doctors_high_stress
                        WHEN :second = 0
                            THEN    :first
                                    + ((:max_score - :first) * (doctors_low_stress::FLOAT - 1))
                                    / (doctors_high_stress - 1)
                        WHEN :third = 0
                            THEN    CASE
                                    WHEN doctors_low_stress = 1 THEN :first
                                    WHEN doctors_low_stress = 2 THEN :first + :second
                                    ELSE :first + :second
                                            + ((:max_score - :first - :second) * (doctors_low_stress::FLOAT - 2))
                                            / (doctors_high_stress - 2)
                                    END
                        ELSE        CASE
                                    WHEN doctors_low_stress = 1 THEN :first
                                    WHEN doctors_low_stress = 2 THEN :first + :second
                                    WHEN doctors_low_stress = 3 THEN :first + :second + :third
                                    ELSE :first + :second + :third
                                            + ((:max_score - :first - :second - :third) * (doctors_low_stress::FLOAT - 3))
                                            / (doctors_high_stress - 3)
                                    END
                        END;
