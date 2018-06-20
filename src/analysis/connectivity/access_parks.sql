
-- set block-based score
UPDATE  comprehensive_data_census_blocks
SET     parks_score =   CASE
                        WHEN parks_high_stress IS NULL THEN NULL
                        WHEN parks_high_stress = 0 THEN NULL
                        WHEN parks_low_stress = 0 THEN 0
                        WHEN parks_high_stress = parks_low_stress THEN :max_score
                        WHEN :first = 0 THEN parks_low_stress::FLOAT / parks_high_stress
                        WHEN :second = 0
                            THEN    :first
                                    + ((:max_score - :first) * (parks_low_stress::FLOAT - 1))
                                    / (parks_high_stress - 1)
                        WHEN :third = 0
                            THEN    CASE
                                    WHEN parks_low_stress = 1 THEN :first
                                    WHEN parks_low_stress = 2 THEN :first + :second
                                    ELSE :first + :second
                                            + ((:max_score - :first - :second) * (parks_low_stress::FLOAT - 2))
                                            / (parks_high_stress - 2)
                                    END
                        ELSE        CASE
                                    WHEN parks_low_stress = 1 THEN :first
                                    WHEN parks_low_stress = 2 THEN :first + :second
                                    WHEN parks_low_stress = 3 THEN :first + :second + :third
                                    ELSE :first + :second + :third
                                            + ((:max_score - :first - :second - :third) * (parks_low_stress::FLOAT - 3))
                                            / (parks_high_stress - 3)
                                    END
                        END;
