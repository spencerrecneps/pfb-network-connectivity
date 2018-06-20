
-- set block-based score
UPDATE  comprehensive_data_census_blocks
SET     retail_score =  CASE
                        WHEN retail_high_stress IS NULL THEN NULL
                        WHEN retail_high_stress = 0 THEN NULL
                        WHEN retail_low_stress = 0 THEN 0
                        WHEN retail_high_stress = retail_low_stress THEN :max_score
                        WHEN :first = 0 THEN retail_low_stress::FLOAT / retail_high_stress
                        WHEN :second = 0
                            THEN    :first
                                    + ((:max_score - :first) * (retail_low_stress::FLOAT - 1))
                                    / (retail_high_stress - 1)
                        WHEN :third = 0
                            THEN    CASE
                                    WHEN retail_low_stress = 1 THEN :first
                                    WHEN retail_low_stress = 2 THEN :first + :second
                                    ELSE :first + :second
                                            + ((:max_score - :first - :second) * (retail_low_stress::FLOAT - 2))
                                            / (retail_high_stress - 2)
                                    END
                        ELSE        CASE
                                    WHEN retail_low_stress = 1 THEN :first
                                    WHEN retail_low_stress = 2 THEN :first + :second
                                    WHEN retail_low_stress = 3 THEN :first + :second + :third
                                    ELSE :first + :second + :third
                                            + ((:max_score - :first - :second - :third) * (retail_low_stress::FLOAT - 3))
                                            / (retail_high_stress - 3)
                                    END
                        END;
