# Build Denormalized tables.
psql $CRIME_DATA_API_DEV_DB_URL -f denorm-offender.sql
psql $CRIME_DATA_API_DEV_DB_URL -f denorm-offenses.sql
psql $CRIME_DATA_API_DEV_DB_URL -f denorm-victims.sql

# Setup Materialized views.
psql $CRIME_DATA_API_DEV_DB_URL -f mat-views/cargo-theft.sql
psql $CRIME_DATA_API_DEV_DB_URL -f mat-views/hate-crime.sql
psql $CRIME_DATA_API_DEV_DB_URL -f mat-views/offender.sql
psql $CRIME_DATA_API_DEV_DB_URL -f mat-views/victim.sql
# psql $CRIME_DATA_API_DEV_DB_URL -f mat-views/offense.sql