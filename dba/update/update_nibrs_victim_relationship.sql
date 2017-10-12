UPDATE nibrs_victim_denorm_XXXX SET offense_id = nibrs_victim_offense.offense_id from nibrs_victim_offense where
nibrs_victim_denorm_XXXX.victim_id = nibrs_victim_offense.victim_id;

UPDATE nibrs_victim_denorm_XXXX SET offense_type_id = nibrs_offense_denorm_XXXX.offense_type_id,
offense_name = nibrs_offense_denorm_XXXX.offense_name
FROM nibrs_offense_denorm_XXXX  where
nibrs_victim_denorm_XXXX.offense_id  = nibrs_offense_denorm_XXXX.offense_id;

REFRESH MATERIALIZED VIEW offense_victim_counts_XXXX;

REFRESH MATERIALIZED VIEW offense_victim_counts_state;
REFRESH MATERIALIZED VIEW offense_victim_counts_ori;
