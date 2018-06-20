
-- set score
UPDATE  comprehensive_data_census_blocks
SET     emp_score = CASE
                    WHEN emp_high_stress IS NULL THEN NULL
                    WHEN emp_high_stress = 0 THEN NULL
                    WHEN emp_low_stress = 0 THEN 0
                    WHEN emp_high_stress = emp_low_stress THEN :max_score
                    WHEN :step1 = 0 THEN :max_score * emp_low_stress::FLOAT / emp_high_stress
                    WHEN emp_low_stress::FLOAT / emp_high_stress = :step3 THEN :score3
                    WHEN emp_low_stress::FLOAT / emp_high_stress = :step2 THEN :score2
                    WHEN emp_low_stress::FLOAT / emp_high_stress = :step1 THEN :score1
                    WHEN emp_low_stress::FLOAT / emp_high_stress > :step3
                        THEN    :score3
                                + (:max_score - :score3)
                                * (
                                    (emp_low_stress::FLOAT / emp_high_stress - :step3)
                                    / (1 - :step3)
                                )
                    WHEN emp_low_stress::FLOAT / emp_high_stress > :step2
                        THEN    :score2
                                + (:score3 - :score2)
                                * (
                                    (emp_low_stress::FLOAT / emp_high_stress - :step2)
                                    / (:step3 - :step2)
                                )
                    WHEN emp_low_stress::FLOAT / emp_high_stress > :step1
                        THEN    :score1
                                + (:score2 - :score1)
                                * (
                                    (emp_low_stress::FLOAT / emp_high_stress - :step1)
                                    / (:step2 - :step1)
                                )
                    ELSE        :score1
                                * (
                                    (emp_low_stress::FLOAT / emp_high_stress)
                                    / :step1
                                )
                    END;
