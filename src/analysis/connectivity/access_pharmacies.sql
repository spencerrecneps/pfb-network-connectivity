
-- set block-based score
UPDATE  neighborhood_census_blocks
SET     pharmacies_score =  CASE
                            WHEN pharmacies_high_stress IS NULL THEN NULL
                            WHEN pharmacies_high_stress = 0 THEN NULL
                            WHEN pharmacies_low_stress = 0 THEN 0
                            WHEN pharmacies_high_stress = pharmacies_low_stress THEN :max_score
                            WHEN :first = 0 THEN pharmacies_low_stress::FLOAT / pharmacies_high_stress
                            WHEN :second = 0
                                THEN    :first
                                        + ((:max_score - :first) * (pharmacies_low_stress::FLOAT - 1))
                                        / (pharmacies_high_stress - 1)
                            WHEN :third = 0
                                THEN    CASE
                                        WHEN pharmacies_low_stress = 1 THEN :first
                                        WHEN pharmacies_low_stress = 2 THEN :first + :second
                                        ELSE :first + :second
                                                + ((:max_score - :first - :second) * (pharmacies_low_stress::FLOAT - 2))
                                                / (pharmacies_high_stress - 2)
                                        END
                            ELSE        CASE
                                        WHEN pharmacies_low_stress = 1 THEN :first
                                        WHEN pharmacies_low_stress = 2 THEN :first + :second
                                        WHEN pharmacies_low_stress = 3 THEN :first + :second + :third
                                        ELSE :first + :second + :third
                                                + ((:max_score - :first - :second - :third) * (pharmacies_low_stress::FLOAT - 3))
                                                / (pharmacies_high_stress - 3)
                                        END
                            END;
