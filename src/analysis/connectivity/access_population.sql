
-- set score
UPDATE  neighborhood_census_blocks
SET     pop_score = CASE
                    WHEN pop_high_stress IS NULL THEN NULL
                    WHEN pop_high_stress = 0 THEN NULL
                    WHEN pop_low_stress = 0 THEN 0
                    WHEN pop_high_stress = pop_low_stress THEN :max_score
                    WHEN :step1 = 0 THEN :max_score * pop_low_stress::FLOAT / pop_high_stress
                    WHEN pop_low_stress::FLOAT / pop_high_stress = :step3 THEN :score3
                    WHEN pop_low_stress::FLOAT / pop_high_stress = :step2 THEN :score2
                    WHEN pop_low_stress::FLOAT / pop_high_stress = :step1 THEN :score1
                    WHEN pop_low_stress::FLOAT / pop_high_stress > :step3
                        THEN    :score3
                                + (:max_score - :score3)
                                * (
                                    (pop_low_stress::FLOAT / pop_high_stress - :step3)
                                    / (1 - :step3)
                                )
                    WHEN pop_low_stress::FLOAT / pop_high_stress > :step2
                        THEN    :score2
                                + (:score3 - :score2)
                                * (
                                    (pop_low_stress::FLOAT / pop_high_stress - :step2)
                                    / (:step3 - :step2)
                                )
                    WHEN pop_low_stress::FLOAT / pop_high_stress > :step1
                        THEN    :score1
                                + (:score2 - :score1)
                                * (
                                    (pop_low_stress::FLOAT / pop_high_stress - :step1)
                                    / (:step2 - :step1)
                                )
                    ELSE        :score1
                                * (
                                    (pop_low_stress::FLOAT / pop_high_stress)
                                    / :step1
                                )
                    END;
