
-- set block-based score
UPDATE  comprehensive_data_census_blocks
SET     universities_score =    CASE
                                WHEN universities_high_stress IS NULL THEN NULL
                                WHEN universities_high_stress = 0 THEN NULL
                                WHEN universities_low_stress = 0 THEN 0
                                WHEN universities_high_stress = universities_low_stress THEN :max_score
                                WHEN :first = 0 THEN universities_low_stress::FLOAT / universities_high_stress
                                WHEN :second = 0
                                    THEN    :first
                                            + ((:max_score - :first) * (universities_low_stress::FLOAT - 1))
                                            / (universities_high_stress - 1)
                                WHEN :third = 0
                                    THEN    CASE
                                            WHEN universities_low_stress = 1 THEN :first
                                            WHEN universities_low_stress = 2 THEN :first + :second
                                            ELSE :first + :second
                                                    + ((:max_score - :first - :second) * (universities_low_stress::FLOAT - 2))
                                                    / (universities_high_stress - 2)
                                            END
                                ELSE        CASE
                                            WHEN universities_low_stress = 1 THEN :first
                                            WHEN universities_low_stress = 2 THEN :first + :second
                                            WHEN universities_low_stress = 3 THEN :first + :second + :third
                                            ELSE :first + :second + :third
                                                    + ((:max_score - :first - :second - :third) * (universities_low_stress::FLOAT - 3))
                                                    / (universities_high_stress - 3)
                                            END
                                END;
