----------------------------------------
-- Input variables:
--      :max_score - Maximum score value
--      :first - Value of first available destination (if 0 then ignore--a basic ratio is used for the score)
--      :second - Value of second available destination (if 0 then ignore--a basic ratio is used after 1)
--      :third - Value of third available destination (if 0 then ignore--a basic ratio is used after 2)
----------------------------------------
-- set block-based raw numbers


-- set block-based score
UPDATE  comprehensive_data_census_blocks
SET     colleges_score =    CASE
                            WHEN colleges_high_stress IS NULL THEN NULL
                            WHEN colleges_high_stress = 0 THEN NULL
                            WHEN colleges_low_stress = 0 THEN 0
                            WHEN colleges_high_stress = colleges_low_stress THEN :max_score
                            WHEN :first = 0 THEN colleges_low_stress::FLOAT / colleges_high_stress
                            WHEN :second = 0
                                THEN    :first
                                        + ((:max_score - :first) * (colleges_low_stress::FLOAT - 1))
                                        / (colleges_high_stress - 1)
                            WHEN :third = 0
                                THEN    CASE
                                        WHEN colleges_low_stress = 1 THEN :first
                                        WHEN colleges_low_stress = 2 THEN :first + :second
                                        ELSE :first + :second
                                                + ((:max_score - :first - :second) * (colleges_low_stress::FLOAT - 2))
                                                / (colleges_high_stress - 2)
                                        END
                            ELSE        CASE
                                        WHEN colleges_low_stress = 1 THEN :first
                                        WHEN colleges_low_stress = 2 THEN :first + :second
                                        WHEN colleges_low_stress = 3 THEN :first + :second + :third
                                        ELSE :first + :second + :third
                                                + ((:max_score - :first - :second - :third) * (colleges_low_stress::FLOAT - 3))
                                                / (colleges_high_stress - 3)
                                        END
                            END;
