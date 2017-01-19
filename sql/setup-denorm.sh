# Build Denormalized tables.
psql $CRIME_DATA_API_DEV_DB_URL -f sql/denorm-offender.sql
psql $CRIME_DATA_API_DEV_DB_URL -f sqldenorm-offenses.sql
psql $CRIME_DATA_API_DEV_DB_URL -f sql/denorm-victims.sql

# Setup Materialized views.
psql $CRIME_DATA_API_DEV_DB_URL -f sq/mat-views/cargo-theft.sql
psql $CRIME_DATA_API_DEV_DB_URL -f sql/mat-views/hate-crime.sql
psql $CRIME_DATA_API_DEV_DB_URL -f sql/mat-views/offender.sql
psql $CRIME_DATA_API_DEV_DB_URL -f sql/mat-views/victim.sql
# psql $CRIME_DATA_API_DEV_DB_URL -f mat-views/offense.sql