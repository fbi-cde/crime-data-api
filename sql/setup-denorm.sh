# Build Denormalized tables.
psql $CRIME_DATA_API_DEV_DB_URL -f sql/denorm-offender.sql
psql $CRIME_DATA_API_DEV_DB_URL -f sql/denorm-offenses.sql
psql $CRIME_DATA_API_DEV_DB_URL -f sql/denorm-victims.sql

# Setup Materialized views.
psql $CRIME_DATA_API_DEV_DB_URL -f sql/mat-views/cargo-theft.sql
psql $CRIME_DATA_API_DEV_DB_URL -f sql/mat-views/hate-crime.sql
psql $CRIME_DATA_API_DEV_DB_URL -f sql/mat-views/offender.sql
psql $CRIME_DATA_API_DEV_DB_URL -f sql/mat-views/victim.sql
psql $CRIME_DATA_API_DEV_DB_URL -f sql/mat-views/offense.sql
psql $CRIME_DATA_API_DEV_DB_URL -f sql/mat-views/offense-offenses.sql
psql $CRIME_DATA_API_DEV_DB_URL -f sql/mat-views/offender-offenses.sql
psql $CRIME_DATA_API_DEV_DB_URL -f sql/mat-views/victim-offenses.sql

# Aggregate views.
psql $CRIME_DATA_API_DEV_DB_URL -f sql/mat-views/aggregate-views.sql