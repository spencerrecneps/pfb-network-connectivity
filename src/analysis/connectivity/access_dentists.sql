
-- set block-based score
UPDATE  neighborhood_census_blocks
SET     dentists_score =    CASE
                            WHEN dentists_high_stress IS NULL THEN NULL
                            WHEN dentists_high_stress = 0 THEN NULL
                            WHEN dentists_low_stress = 0 THEN 0
                            WHEN dentists_high_stress = dentists_low_stress THEN :max_score
                            WHEN :first = 0 THEN dentists_low_stress::FLOAT / dentists_high_stress
                            WHEN :second = 0
                                THEN    :first
                                        + ((:max_score - :first) * (dentists_low_stress::FLOAT - 1))
                                        / (dentists_high_stress - 1)
                            WHEN :third = 0
                                THEN    CASE
                                        WHEN dentists_low_stress = 1 THEN :first
                                        WHEN dentists_low_stress = 2 THEN :first + :second
                                        ELSE :first + :second
                                                + ((:max_score - :first - :second) * (dentists_low_stress::FLOAT - 2))
                                                / (dentists_high_stress - 2)
                                        END
                            ELSE        CASE
                                        WHEN dentists_low_stress = 1 THEN :first
                                        WHEN dentists_low_stress = 2 THEN :first + :second
                                        WHEN dentists_low_stress = 3 THEN :first + :second + :third
                                        ELSE :first + :second + :third
                                                + ((:max_score - :first - :second - :third) * (dentists_low_stress::FLOAT - 3))
                                                / (dentists_high_stress - 3)
                                        END
                            END;
