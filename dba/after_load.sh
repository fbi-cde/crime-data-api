#!/bin/bash

# Run this script after you load the database to purge any sensitive
# data that might be in there as well as create materialized views

if [ -z "$CRIME_DATA_API_DB_URL" ]; then
  echo "Need to set CRIME_DATA_API_DB_URL"
  exit 1
fi

echo "Running 'after_load' steps on $CRIME_DATA_API_DB_URL"

echo -n "Scrubbing sensitive fields..."
psql $CRIME_DATA_API_DB_URL < after_load/scrub_private_for_prod.sql >/dev/null
echo "DONE"

echo -n "Loading additional functions..."
psql $CRIME_DATA_API_DB_URL <after_load/functions.sql >/dev/null
echo "DONE"

echo -n "Arson tables..."
psql $CRIME_DATA_API_DB_URL <after_load/create_arson_table.sql
echo "DONE"

echo -n "Create View Count tables from NIBRS..."
after_load/setup-denorm.sh >/dev/null
echo "DONE"

echo -n "Create flat ref_agency_covered_by table..."
psql $CRIME_DATA_API_DB_URL <after_load/flatten-covered-by.sql
echo "DONE"

echo -n "Create participation views..."
psql $CRIME_DATA_API_DB_URL <after_load/participation_table.sql
echo "DONE"

echo -n "Create cde_counties table..."
psql $CRIME_DATA_API_DB_URL <after_load/cde_counties.sql
echo "DONE"

echo -n "Create cde_states table..."
psql $CRIME_DATA_API_DB_URL <after_load/cde_states.sql
echo "DONE"

echo -n "Create reta_agency_summary table..."
psql $CRIME_DATA_API_DB_URL <after_load/create_reta_agency_summary.sql
echo "DONE"

echo -n "Create asr_summary tables..."
psql $CRIME_DATA_API_DB_URL <after_load/asr_summaries.sql
echo "DONE"

echo -n "Building Helper join tables..."
psql $CRIME_DATA_API_DB_URL <after_load/helper_views.sql
echo "DONE"

echo -n "Updating lat long for icpsr coordinates issue 617..."
psql $CRIME_DATA_API_DB_URL <after_load/lat_long_update_617.sql 
echo "DONE" 

#echo -n "Building cached incident representations (may be slow)..."
#psql $CRIME_DATA_API_DB_URL <after_load/cache_representations.sql >/dev/null
#after_load/cache_representation.sh >/dev/null
#echo "DONE"


