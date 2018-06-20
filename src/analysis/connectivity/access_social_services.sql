
-- set block-based score
UPDATE  comprehensive_data_census_blocks
SET     social_services_score = CASE
                                WHEN social_services_high_stress IS NULL THEN NULL
                                WHEN social_services_high_stress = 0 THEN NULL
                                WHEN social_services_low_stress = 0 THEN 0
                                WHEN social_services_high_stress = social_services_low_stress THEN :max_score
                                WHEN :first = 0 THEN social_services_low_stress::FLOAT / social_services_high_stress
                                WHEN :second = 0
                                    THEN    :first
                                            + ((:max_score - :first) * (social_services_low_stress::FLOAT - 1))
                                            / (social_services_high_stress - 1)
                                WHEN :third = 0
                                    THEN    CASE
                                            WHEN social_services_low_stress = 1 THEN :first
                                            WHEN social_services_low_stress = 2 THEN :first + :second
                                            ELSE :first + :second
                                                    + ((:max_score - :first - :second) * (social_services_low_stress::FLOAT - 2))
                                                    / (social_services_high_stress - 2)
                                            END
                                ELSE        CASE
                                            WHEN social_services_low_stress = 1 THEN :first
                                            WHEN social_services_low_stress = 2 THEN :first + :second
                                            WHEN social_services_low_stress = 3 THEN :first + :second + :third
                                            ELSE :first + :second + :third
                                                    + ((:max_score - :first - :second - :third) * (social_services_low_stress::FLOAT - 3))
                                                    / (social_services_high_stress - 3)
                                            END
                                END;
