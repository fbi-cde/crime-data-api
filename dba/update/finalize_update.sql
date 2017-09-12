-- Rename/replace views.


drop materialized view IF EXISTS hc_counts_states;
ALTER MATERIALIZED VIEW hc_counts_states_new RENAME TO hc_counts_states;
drop materialized view IF EXISTS offense_hc_counts_ori;
ALTER MATERIALIZED VIEW offense_hc_counts_ori_new RENAME TO offense_hc_counts_ori;
drop materialized view IF EXISTS offense_hc_counts_states;
ALTER MATERIALIZED VIEW offense_hc_counts_states_new RENAME TO offense_hc_counts_states;
drop materialized view IF EXISTS hc_counts_ori;
ALTER MATERIALIZED VIEW hc_counts_ori_new RENAME TO hc_counts_ori;


CREATE INDEX hc_counts_state_id_year_idx ON hc_counts_states (state_id, year);
CREATE INDEX offense_hc_counts_state_id_year_idx ON offense_hc_counts_states (state_id, year);
CREATE INDEX hc_counts_ori_year_idx ON hc_counts_ori (ori, year);
CREATE INDEX offense_hc_counts_ori_year_idx ON offense_hc_counts_ori (ori, year);

drop materialized view  IF EXISTS ct_counts_ori;
ALTER materialized view ct_counts_ori_new RENAME TO ct_counts_ori; 
drop materialized view  IF EXISTS ct_counts_states;
ALTER materialized view ct_counts_states_new RENAME TO ct_counts_states; 
drop materialized view  IF EXISTS offense_ct_counts_states;
ALTER materialized view offense_ct_counts_states_new RENAME TO offense_ct_counts_states; 
drop materialized view  IF EXISTS offense_ct_counts_ori;
ALTER materialized view offense_ct_counts_ori_new RENAME TO offense_ct_counts_ori; 

CREATE INDEX ct_counts_state_id_idx ON ct_counts_states (state_id, year);
CREATE INDEX offense_ct_counts_state_id_idx ON offense_ct_counts_states (state_id, year);
CREATE INDEX ct_counts_ori_idx ON ct_counts_ori (ori, year);
CREATE INDEX offense_ct_counts_ori_idx ON offense_ct_counts_ori (ori, year);

drop materialized view IF EXISTS offender_counts_states CASCADE;
ALTER MATERIALIZED VIEW offender_counts_states_temp RENAME TO offender_counts_states;
CREATE INDEX CONCURRENTLY offender_counts_state_year_id_idx ON offender_counts_states (state_id, year);

drop materialized view IF EXISTS offender_counts_ori CASCADE;
ALTER MATERIALIZED VIEW offender_counts_ori_temp RENAME TO offender_counts_ori;
CREATE INDEX CONCURRENTLY offender_counts_ori_year_idx ON offender_counts_ori (ori, year);


drop materialized view  IF EXISTS offense_offender_counts_states;
ALTER MATERIALIZED VIEW offense_offender_counts_states_temp RENAME TO offense_offender_counts_states;
CREATE INDEX CONCURRENTLY offense_offender_counts_state_id_idx ON offense_offender_counts_states (state_id, year, offense_name);

drop materialized view  IF EXISTS offense_offender_counts_ori;
ALTER MATERIALIZED VIEW offense_offender_counts_ori_temp RENAME TO offense_offender_counts_ori;
CREATE INDEX CONCURRENTLY offense_offender_counts_ori_idx ON offense_offender_counts_ori (ori, year, offense_name);

drop materialized view IF EXISTS victim_counts_states CASCADE;
ALTER MATERIALIZED VIEW victim_counts_states_temp RENAME TO victim_counts_states;
CREATE INDEX CONCURRENTLY victim_counts_state_year_id_idx ON victim_counts_states (state_id, year);

drop materialized view IF EXISTS victim_counts_ori CASCADE;
ALTER MATERIALIZED VIEW victim_counts_ori_temp RENAME TO victim_counts_ori;
CREATE INDEX CONCURRENTLY victim_counts_ori_year_idx ON victim_counts_ori (ori, year);

drop materialized view  IF EXISTS offense_victim_counts_states;
ALTER MATERIALIZED VIEW offense_victim_counts_states_temp RENAME TO offense_victim_counts_states;
CREATE INDEX CONCURRENTLY offense_victim_counts_state_id_idx ON offense_victim_counts_states (state_id, year, offense_name);

drop materialized view  IF EXISTS offense_victim_counts_ori;
ALTER MATERIALIZED VIEW offense_victim_counts_ori_temp RENAME TO offense_victim_counts_ori;
CREATE INDEX CONCURRENTLY offense_victim_counts_ori_idx ON offense_victim_counts_ori (ori, year, offense_name);

drop materialized view  IF EXISTS offense_counts_states CASCADE;
ALTER MATERIALIZED VIEW offense_counts_states_temp RENAME TO offense_counts_states;
CREATE INDEX CONCURRENTLY offense_counts_state_year_id_idx ON offense_counts_states (state_id, year);

drop materialized view  IF EXISTS offense_counts_ori CASCADE;
ALTER MATERIALIZED VIEW offense_counts_ori_temp RENAME TO offense_counts_ori;
CREATE INDEX CONCURRENTLY offense_counts_ori_year_idx ON offense_counts_ori (ori, year);

drop materialized view IF EXISTS  offense_offense_counts_states;
ALTER MATERIALIZED VIEW offense_offense_counts_states_temp RENAME TO offense_offense_counts_states;
CREATE INDEX CONCURRENTLY offense_offense_counts_state_id_idx ON offense_counts_states (state_id, year, offense_name);

drop materialized view IF EXISTS  offense_offense_counts_ori;
ALTER MATERIALIZED VIEW offense_offense_counts_ori_temp RENAME TO offense_offense_counts_ori;
CREATE INDEX CONCURRENTLY offense_offense_counts_ori_idx ON offense_counts_ori (ori, year, offense_name);

-- Refresh year count view.
INSERT INTO nibrs_years (year) VALUES ($YEAR);

-- DONE.