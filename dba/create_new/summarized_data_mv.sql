CREATE MATERIALIZED VIEW summarized_data_agency AS
select ori,  data_year as data_year,
   SUM(sum_hom_cleared) as homicide_cleared,
   (SUM(sum_rpe_ns_leg_cleared)+SUM(sum_rpe_frc_leg_cleared)) as rape_legacy_cleared,
  (SUM(sum_rpe_ns_cleared)+SUM(sum_rpe_frc_cleared)+SUM(sum_rpe_att_cleared)) as rape_cleared,
  (SUM(sum_rob_ns_cleared)+SUM(sum_rob_gun_cleared)+SUM(sum_rob_cut_cleared)+SUM(sum_rob_oth_cleared)+SUM(sum_rob_hff_cleared)) as robbery_cleared,
  (SUM(sum_ass_ns_cleared)+SUM(sum_ass_gun_cleared)+SUM(sum_ass_cut_cleared)+SUM(sum_ass_hff_cleared)+SUM(sum_hom_cleared)+SUM(sum_rpe_ns_leg_cleared)+SUM(sum_rpe_frc_leg_cleared)+SUM(sum_rpe_ns_cleared)+SUM(sum_rpe_frc_cleared)+SUM(sum_rpe_att_cleared)+SUM(sum_rob_ns_cleared)+SUM(sum_rob_gun_cleared)+SUM(sum_rob_cut_cleared)+SUM(sum_rob_oth_cleared)+SUM(sum_rob_hff_cleared)) as violent_crime_cleared,
  (SUM(sum_ass_ns_cleared)+SUM(sum_ass_gun_cleared)+SUM(sum_ass_cut_cleared)+SUM(sum_ass_hff_cleared)) as aggravated_assault_cleared,
  (SUM(sum_brg_ns_cleared)+SUM(sum_brg_feo_cleared)+SUM(sum_brg_ueo_cleared)+SUM(sum_brg_afe_cleared)) as burglary_cleared,
  SUM(sum_lar_tft_cleared) as larceny_cleared,
  (SUM(sum_mtr_ns_cleared)+SUM(sum_mtr_ato_cleared)+SUM(sum_mtr_trk_cleared)+SUM(sum_mtr_oth_cleared)) as motor_vehicle_theft_cleared,
  (SUM(sum_lar_tft_cleared)+SUM(sum_ars_cleared)+SUM(sum_brg_ns_cleared)+SUM(sum_brg_feo_cleared)+SUM(sum_brg_ueo_cleared)+SUM(sum_brg_afe_cleared)+SUM(sum_mtr_ns_cleared)+SUM(sum_mtr_ato_cleared)+SUM(sum_mtr_trk_cleared)+SUM(sum_mtr_oth_cleared)) as property_crime_cleared,
  (SUM(sum_ht_ns_cleared)+SUM(sum_ht_sex_cleared)+SUM(sum_ht_srv_cleared)) as human_trafficing_cleared,
  SUM(sum_ars_cleared) as arson_cleared,
  SUM(sum_hom_actual) as homicide_actual,
  (SUM(sum_rpe_ns_leg_actual)+SUM(sum_rpe_frc_leg_actual)) as rape_legacy_actual,
  (SUM(sum_rpe_ns_actual)+SUM(sum_rpe_frc_actual)+SUM(sum_rpe_att_actual)) as rape_actual,
  (SUM(sum_rob_ns_actual)+SUM(sum_rob_gun_actual)+SUM(sum_rob_cut_actual)+SUM(sum_rob_oth_actual)+SUM(sum_rob_hff_actual)) as robbery_actual,
  (SUM(sum_ass_ns_actual)+SUM(sum_ass_gun_actual)+SUM(sum_ass_cut_actual)+SUM(sum_ass_hff_actual)+SUM(sum_hom_actual)+SUM(sum_rpe_ns_leg_actual)+SUM(sum_rpe_frc_leg_actual)+SUM(sum_rpe_ns_actual)+SUM(sum_rpe_frc_actual)+SUM(sum_rpe_att_actual)+SUM(sum_rob_ns_actual)+SUM(sum_rob_gun_actual)+SUM(sum_rob_cut_actual)+SUM(sum_rob_oth_actual)+SUM(sum_rob_hff_actual)) as violent_crime_actual,
  (SUM(sum_ass_ns_actual)+SUM(sum_ass_gun_actual)+SUM(sum_ass_cut_actual)+SUM(sum_ass_hff_actual)) as aggravated_assault_actual,
  (SUM(sum_brg_ns_actual)+SUM(sum_brg_feo_actual)+SUM(sum_brg_ueo_actual)+SUM(sum_brg_afe_actual)) as burglary_actual,
   SUM(sum_lar_tft_actual) as larceny_actual,
  (SUM(sum_mtr_ns_actual)+SUM(sum_mtr_ato_actual)+SUM(sum_mtr_trk_actual)+SUM(sum_mtr_oth_actual)) as motor_vehicle_theft_actual,
  (SUM(sum_lar_tft_actual)+SUM(sum_ars_actual)+SUM(sum_brg_ns_actual)+SUM(sum_brg_feo_actual)+SUM(sum_brg_ueo_actual)+SUM(sum_brg_afe_actual)+SUM(sum_mtr_ns_actual)+SUM(sum_mtr_ato_actual)+SUM(sum_mtr_trk_actual)+SUM(sum_mtr_oth_actual)) as property_crime_actual,
  (SUM(sum_ht_ns_actual)+SUM(sum_ht_sex_actual)+SUM(sum_ht_srv_actual)) as human_trafficing_actual,
  SUM(sum_ars_actual) as arson_actual
from public.summarized_data GROUP BY ori, data_year;

CREATE MATERIALIZED VIEW summarized_data_agency_homicide AS
select ori,  data_year as data_year,
format('homicide') as offense,
SUM(homicide_cleared) as cleared,
SUM(homicide_actual) as actual
from public.summarized_data_agency GROUP BY ori, data_year;

CREATE MATERIALIZED VIEW summarized_data_agency_rape AS
select ori,  data_year as data_year,
format('rape') as offense,
SUM(rape_cleared) as cleared,
SUM(rape_actual) as actual
from public.summarized_data_agency GROUP BY ori, data_year;

CREATE MATERIALIZED VIEW summarized_data_agency_rape_leg AS
select ori,  data_year as data_year,
format('rape-legacy') as offense,
SUM(rape_legacy_cleared) as cleared,
SUM(rape_legacy_actual) as actual
from public.summarized_data_agency GROUP BY ori, data_year;

CREATE MATERIALIZED VIEW summarized_data_agency_robbery AS
select ori,  data_year as data_year,
format('robbery') as offense,
SUM(robbery_cleared) as cleared,
SUM(robbery_actual) as actual
from public.summarized_data_agency GROUP BY ori, data_year;

CREATE MATERIALIZED VIEW summarized_data_agency_aggravated AS
select ori,  data_year as data_year,
format('aggravated-assault') as offense,
SUM(aggravated_assault_cleared) as cleared,
SUM(aggravated_assault_actual) as actual
from public.summarized_data_agency GROUP BY ori, data_year;

CREATE MATERIALIZED VIEW summarized_data_agency_mvt AS
select ori,  data_year as data_year,
format('motor-vehicle-theft') as offense,
SUM(motor_vehicle_theft_cleared) as cleared,
SUM(motor_vehicle_theft_actual) as actual
from public.summarized_data_agency GROUP BY ori, data_year;

CREATE MATERIALIZED VIEW summarized_data_agency_buglary AS
select ori,  data_year as data_year,
format('buglary') as offense,
SUM(burglary_cleared) as cleared,
SUM(burglary_actual) as actual
from public.summarized_data_agency GROUP BY ori, data_year;

CREATE MATERIALIZED VIEW summarized_data_agency_ht AS
select ori,  data_year as data_year,
format('human-trafficing') as offense,
SUM(human_trafficing_cleared) as cleared,
SUM(human_trafficing_actual) as actual
from public.summarized_data_agency GROUP BY ori, data_year;

CREATE MATERIALIZED VIEW summarized_data_agency_vc AS
select ori,  data_year as data_year,
format('violent-crime') as offense,
SUM(violent_crime_cleared) as cleared,
SUM(violent_crime_actual) as actual
from public.summarized_data_agency GROUP BY ori, data_year;

CREATE MATERIALIZED VIEW summarized_data_agency_pc AS
select ori,  data_year as data_year,
format('property-crime') as offense,
SUM(property_crime_cleared) as cleared,
SUM(property_crime_actual) as actual
from public.summarized_data_agency GROUP BY ori, data_year;

CREATE MATERIALIZED VIEW summarized_data_agency_arson AS
select ori,  data_year as data_year,
format('arson') as offense,
SUM(arson_cleared) as cleared,
SUM(arson_actual) as actual
from public.summarized_data_agency GROUP BY ori, data_year;

CREATE MATERIALIZED VIEW summarized_data_agency_larceny AS
select ori,  data_year as data_year,
format('larceny') as offense,
SUM(larceny_cleared) as cleared,
SUM(larceny_actual) as actual
from public.summarized_data_agency GROUP BY ori, data_year;

CREATE MATERIALIZED VIEW summarized_data_agency_combined AS
select * from summarized_data_agency_larceny
union select * from summarized_data_agency_arson
union select * from summarized_data_agency_pc
union select * from summarized_data_agency_vc
union select * from summarized_data_agency_ht
union select * from summarized_data_agency_buglary
union select * from summarized_data_agency_mvt
union select * from summarized_data_agency_aggravated
union select * from summarized_data_agency_robbery
union select * from summarized_data_agency_rape_leg
union select * from summarized_data_agency_rape
union select * from summarized_data_agency_homicide;
