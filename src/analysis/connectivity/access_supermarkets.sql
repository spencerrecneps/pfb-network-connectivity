
-- set block-based score
UPDATE  neighborhood_census_blocks
SET     supermarkets_score =    CASE
                                WHEN supermarkets_high_stress IS NULL THEN NULL
                                WHEN supermarkets_high_stress = 0 THEN NULL
                                WHEN supermarkets_low_stress = 0 THEN 0
                                WHEN supermarkets_high_stress = supermarkets_low_stress THEN :max_score
                                WHEN :first = 0 THEN supermarkets_low_stress::FLOAT / supermarkets_high_stress
                                WHEN :second = 0
                                    THEN    :first
                                            + ((:max_score - :first) * (supermarkets_low_stress::FLOAT - 1))
                                            / (supermarkets_high_stress - 1)
                                WHEN :third = 0
                                    THEN    CASE
                                            WHEN supermarkets_low_stress = 1 THEN :first
                                            WHEN supermarkets_low_stress = 2 THEN :first + :second
                                            ELSE :first + :second
                                                    + ((:max_score - :first - :second) * (supermarkets_low_stress::FLOAT - 2))
                                                    / (supermarkets_high_stress - 2)
                                            END
                                ELSE        CASE
                                            WHEN supermarkets_low_stress = 1 THEN :first
                                            WHEN supermarkets_low_stress = 2 THEN :first + :second
                                            WHEN supermarkets_low_stress = 3 THEN :first + :second + :third
                                            ELSE :first + :second + :third
                                                    + ((:max_score - :first - :second - :third) * (supermarkets_low_stress::FLOAT - 3))
                                                    / (supermarkets_high_stress - 3)
                                            END
                                END;
