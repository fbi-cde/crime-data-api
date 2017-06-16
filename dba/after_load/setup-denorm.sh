# Build Denormalized tables.
psql $CRIME_DATA_API_DB_URL -f after_load/denorm-offender.sql
psql $CRIME_DATA_API_DB_URL -f after_load/denorm-offenses.sql
psql $CRIME_DATA_API_DB_URL -f after_load/denorm-victims.sql
psql $CRIME_DATA_API_DB_URL -f after_load/denorm-incidents.sql
psql $CRIME_DATA_API_DB_URL -f after_load/denorm-property.sql
psql $CRIME_DATA_API_DB_URL -f after_load/denorm-arrestee.sql
psql $CRIME_DATA_API_DB_URL -f after_load/denorm-agencies.sql

# Setup Materialized views.
psql $CRIME_DATA_API_DB_URL -f after_load/mat-views/cargo-theft.sql
psql $CRIME_DATA_API_DB_URL -f after_load/mat-views/hate-crime.sql
psql $CRIME_DATA_API_DB_URL -f after_load/mat-views/offender.sql
psql $CRIME_DATA_API_DB_URL -f after_load/mat-views/victim.sql
psql $CRIME_DATA_API_DB_URL -f after_load/mat-views/offense.sql
psql $CRIME_DATA_API_DB_URL -f after_load/mat-views/offense-offenses.sql
psql $CRIME_DATA_API_DB_URL -f after_load/mat-views/offender-offenses.sql
psql $CRIME_DATA_API_DB_URL -f after_load/mat-views/victim-offenses.sql
