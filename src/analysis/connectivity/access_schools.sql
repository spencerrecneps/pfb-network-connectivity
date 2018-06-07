
-- set block-based score
UPDATE  neighborhood_census_blocks
SET     schools_score = CASE
                        WHEN schools_high_stress IS NULL THEN NULL
                        WHEN schools_high_stress = 0 THEN NULL
                        WHEN schools_low_stress = 0 THEN 0
                        WHEN schools_high_stress = schools_low_stress THEN :max_score
                        WHEN :first = 0 THEN schools_low_stress::FLOAT / schools_high_stress
                        WHEN :second = 0
                            THEN    :first
                                    + ((:max_score - :first) * (schools_low_stress::FLOAT - 1))
                                    / (schools_high_stress - 1)
                        WHEN :third = 0
                            THEN    CASE
                                    WHEN schools_low_stress = 1 THEN :first
                                    WHEN schools_low_stress = 2 THEN :first + :second
                                    ELSE :first + :second
                                            + ((:max_score - :first - :second) * (schools_low_stress::FLOAT - 2))
                                            / (schools_high_stress - 2)
                                    END
                        ELSE        CASE
                                    WHEN schools_low_stress = 1 THEN :first
                                    WHEN schools_low_stress = 2 THEN :first + :second
                                    WHEN schools_low_stress = 3 THEN :first + :second + :third
                                    ELSE :first + :second + :third
                                            + ((:max_score - :first - :second - :third) * (schools_low_stress::FLOAT - 3))
                                            / (schools_high_stress - 3)
                                    END
                        END;
