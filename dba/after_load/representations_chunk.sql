\timing on
INSERT INTO nibrs_incident_representation (incident_id, representation)
SELECT (representation->'incident_id')::text::bigint, representation
FROM (
  SELECT ROW_TO_JSON(incident) AS representation
  FROM   (
    SELECT   incident_id,
             cargo_theft_flag,
             submission_date,
             incident_date,
             report_date_flag,
             incident_hour,
             incident_status,
             ( SELECT ROW_TO_JSON(innerag)
               FROM ( SELECT rat.agency_type_name AS agency_type,
                             ra.ori,
                             ra.legacy_ori,
                             ra.ucr_agency_name,
                             ra.ncic_agency_name,
                             ra.pub_agency_name,
                             ra.agency_status,
                             ra.judicial_dist_code,
                             ra.fid_code,
                             ra.department_id,
                             ra.added_date,
                             ra.dormant_year,
                             ( SELECT ROW_TO_JSON(innerst)
                               FROM ( SELECT rs.state_name,
                                             rs.state_code,
                                             rs.state_abbr,
                                             rs.state_postal_abbr,
                                             rs.state_fips_code,
                                             rs.state_pub_freq_months,
                                             ( SELECT ROW_TO_JSON(innerdiv)
                                               FROM ( SELECT rd.division_code,
                                                             rd.division_name,
                                                             rd.division_desc,
                                                             ( SELECT ROW_TO_JSON(innerreg)
                                                               FROM ( SELECT rr.region_code,
                                                                             rr.region_name,
                                                                             rr.region_desc
                                                                      FROM   ref_region rr
                                                                      WHERE  rr.region_id = rd.region_id
                                                                    ) innerreg
                                                              ) AS region
                                                      FROM   ref_division rd
                                                      WHERE  rd.division_id = rs.division_id
                                                    ) innerdiv
                                              ) AS division
                                      FROM   ref_state rs
                                      WHERE  rs.state_id = ra.state_id
                                    ) innerst
                              ) AS state,
                              rt.tribe_name,
                              ( SELECT ROW_TO_JSON(innerruc)
                                FROM ( SELECT ruc.campus_name,
                                              ru.university_abbr,
                                              ru.university_name
                                       FROM   ref_university_campus ruc
                                       JOIN   ref_university ru ON (ruc.university_id = ru.university_id)
                                       WHERE  ruc.campus_id = ra.campus_id
                                     ) innerruc
                                ) AS campus,
                              ( SELECT ROW_TO_JSON(innercity)
                                FROM ( SELECT rcity.city_name
                                       FROM   ref_city rcity
                                       WHERE  rcity.city_id = ra.city_id
                                     ) innercity
                              ) AS city,
                              ( SELECT ROW_TO_JSON(innerfo)
                                FROM ( SELECT rfo.field_office_code,
                                              rfo.field_office_name,
                                              rfo.field_office_alpha_code,
                                              rfo.field_office_numeric_code
                                       FROM   ref_field_office rfo
                                       WHERE  rfo.field_office_id = ra.field_office_id
                                     ) innerfo
                              ) AS field_office,
                              ( SELECT ROW_TO_JSON(innerpf)
                                FROM ( SELECT rpf.population_family_name,
                                              rpf.population_family_desc
                                       FROM   ref_population_family rpf
                                       WHERE  rpf.population_family_id = ra.population_family_id
                                     ) innerpf
                              ) population_family,
                              ( SELECT ROW_TO_JSON(innersa)
                                FROM ( SELECT rsa.sai,
                                              rsa.agency_name,
                                              rs.state_abbr,
                                              rsa.agency_email,
                                              rsa.agency_website,
                                              rsa.comments
                                       FROM   ref_submitting_agency rsa
                                       LEFT OUTER JOIN ref_state rs ON (rsa.state_id = rs.state_id)
                                       WHERE  rsa.agency_id = ra.submitting_agency_id
                                     ) innersa
                              ) submitting_agency,
                              rd.department_name
                      FROM   ref_agency ra
                      JOIN   ref_agency_type rat ON (rat.agency_type_id = ra.agency_type_id)
                      LEFT OUTER JOIN ref_department rd ON (ra.department_id = rd.department_id)
                      LEFT OUTER JOIN ref_tribe rt ON (ra.tribe_id = rt.tribe_id)
                      WHERE  ra.agency_id = nibrs_incident.agency_id
                    ) innerag
             ) AS agency,
             ( SELECT ARRAY_TO_JSON(ARRAY_AGG(ROW_TO_JSON(inner0)))
               FROM ( SELECT no.attempt_complete_flag,
                             no.num_premises_entered,
                             no.method_entry_code,
                             ( SELECT ROW_TO_JSON(inner0a)
                               FROM ( SELECT notyp.offense_code,
                                             notyp.offense_name,
                                             notyp.crime_against,
                                             notyp.ct_flag,
                                             notyp.hc_flag,
                                             notyp.offense_category_name
                                      FROM   nibrs_offense_type notyp
                                      WHERE  notyp.offense_type_id = no.offense_type_id
                                    ) inner0a
                             ) offense_type,
                             ( SELECT ROW_TO_JSON(innerloc)
                               FROM ( SELECT nlt.location_code,
                                             nlt.location_name
                                      FROM   nibrs_location_type nlt
                                      WHERE  nlt.location_id = no.location_id
                                    ) innerloc
                             ) AS location,
                             ( SELECT ARRAY_TO_JSON(ARRAY_AGG(ROW_TO_JSON(inner0b)))
                               FROM   ( SELECT ncat.criminal_act_code,
                                               ncat.criminal_act_name
                                        FROM   nibrs_criminal_act nca
                                        JOIN   nibrs_criminal_act_type ncat ON (nca.criminal_act_id = ncat.criminal_act_id)
                                        WHERE  nca.offense_id = no.offense_id) inner0b
                             ) criminal_acts,
                             ( SELECT ARRAY_TO_JSON(ARRAY_AGG(ROW_TO_JSON(innerwpn)))
                               FROM ( SELECT nwt.weapon_code,
                                             nwt.weapon_name
                                      FROM   nibrs_weapon nw
                                      JOIN   nibrs_weapon_type nwt ON (nwt.weapon_id = nw.weapon_id)
                                      WHERE  nw.offense_id = no.offense_id
                                    ) innerwpn
                             ) weapons
                      FROM   nibrs_offense no
                      WHERE  no.incident_id = nibrs_incident.incident_id) inner0
             ) offenses,
             ( SELECT ROW_TO_JSON(inner1)
               FROM ( SELECT nci.cleared_except_code, nci.cleared_except_name
                      FROM   nibrs_cleared_except nci
                      WHERE  nci.cleared_except_id = nibrs_incident.cleared_except_id
                    ) inner1
             ) cleared_except,
             ( SELECT ARRAY_TO_JSON(ARRAY_AGG(ROW_TO_JSON(innerprop)))
               FROM ( SELECT nplt.prop_loss_name,
                             np.stolen_count,
                             np.recovered_count
                      FROM   nibrs_property np
                      JOIN   nibrs_prop_loss_type nplt ON (np.prop_loss_id = nplt.prop_loss_id)
                      WHERE  np.incident_id = nibrs_incident.incident_id
                    ) innerprop
             ) property,
             ( SELECT ARRAY_TO_JSON(ARRAY_AGG(ROW_TO_JSON(innervic)))
               FROM ( SELECT nvt.victim_type_code,
                             nvt.victim_type_name,
                             nast.assignment_type_code,
                             nast.assignment_type_name,
                             nat.activity_type_code,
                             nat.activity_type_name,
                             nv.sex_code,
                             nv.age_num, --  TODO: oh noes, the age weirdness
                             nibrs_age.age_name,
                             ne.ethnicity_code,
                             ne.ethnicity_name,
                             rr.race_code,
                             rr.race_desc,
                             nv.resident_status_code,
                             nv.age_range_low_num,
                             nv.age_range_high_num,
                             nv.outside_agency_id -- TODO: what is this?
                      FROM   nibrs_victim nv
                      JOIN   nibrs_victim_type nvt ON (nvt.victim_type_id = nv.victim_type_id)
                      LEFT OUTER JOIN nibrs_assignment_type nast ON (nv.assignment_type_id = nast.assignment_type_id)
                      LEFT OUTER JOIN nibrs_age ON (nv.age_id = nibrs_age.age_id)
                      LEFT OUTER JOIN nibrs_ethnicity ne ON (nv.ethnicity_id = ne.ethnicity_id)
                      LEFT OUTER JOIN ref_race rr ON (nv.race_id = rr.race_id)
                      LEFT OUTER JOIN nibrs_activity_type nat ON (nv.activity_type_id = nat.activity_type_id)
                      WHERE  nv.incident_id = nibrs_incident.incident_id
                    ) innervic
             ) victims,
             ( SELECT ARRAY_TO_JSON(ARRAY_AGG(ROW_TO_JSON(innerarr)))
               FROM ( SELECT narr.arrest_num,
                             narr.arrest_date,
                             narr.multiple_indicator,
                             narr.resident_code,
                             narr.under_18_disposition_code,
                             narr.clearance_ind,
                             narr.sex_code,
                             narr.age_num, --  TODO: oh noes, the age weirdness
                             nibrs_age.age_name,
                             ne.ethnicity_code,
                             ne.ethnicity_name,
                             rr.race_code,
                             rr.race_desc,
                             narr.age_range_low_num,
                             narr.age_range_high_num,
                             ( SELECT ROW_TO_JSON(inneroftyp)
                               FROM ( SELECT notyp.offense_code,
                                             notyp.offense_name,
                                             notyp.crime_against,
                                             notyp.ct_flag,
                                             notyp.hc_flag,
                                             notyp.hc_code,
                                             notyp.offense_category_name
                                      FROM   nibrs_offense_type notyp
                                      WHERE  notyp.offense_type_id = narr.offense_type_id
                                    ) inneroftyp
                             ) offense_type
                      FROM   nibrs_arrestee narr
                      LEFT OUTER JOIN nibrs_age ON (narr.age_id = nibrs_age.age_id)
                      LEFT OUTER JOIN nibrs_ethnicity ne ON (narr.ethnicity_id = ne.ethnicity_id)
                      LEFT OUTER JOIN ref_race rr ON (narr.race_id = rr.race_id)
                      WHERE  narr.incident_id = nibrs_incident.incident_id
                    ) innerarr
             ) arrestees,
             ( SELECT ARRAY_TO_JSON(ARRAY_AGG(ROW_TO_JSON(innerofndr)))
               FROM ( SELECT
                             nof.sex_code,
                             nof.age_num, --  TODO: oh noes, the age weirdness
                             nibrs_age.age_name,
                             ne.ethnicity_code,
                             ne.ethnicity_name,
                             rr.race_code,
                             rr.race_desc,
                             nof.age_range_low_num,
                             nof.age_range_high_num
                      FROM   nibrs_offender nof
                      LEFT OUTER JOIN nibrs_age ON (nof.age_id = nibrs_age.age_id)
                      LEFT OUTER JOIN nibrs_ethnicity ne ON (nof.ethnicity_id = ne.ethnicity_id)
                      LEFT OUTER JOIN ref_race rr ON (nof.race_id = rr.race_id)
                      WHERE  nof.incident_id = nibrs_incident.incident_id
                    ) innerofndr
             ) offenders
    FROM     nibrs_incident
    WHERE    incident_id > ( SELECT COALESCE(MAX(incident_id), 0) FROM nibrs_incident_representation)
    ORDER BY incident_id ASC
    LIMIT    10000
  ) incident
) repr
