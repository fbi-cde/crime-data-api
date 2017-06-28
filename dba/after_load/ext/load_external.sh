#!/bin/bash

# Run this script after you load the database to purge any sensitive
# data that might be in there as well as create materialized views

if [ -z "$CRIME_DATA_API_DB_URL" ]; then
  echo "Need to set CRIME_DATA_API_DB_URL"
  exit 1
fi


echo "Loading external data into the database on $CRIME_DATA_API_DB_URL"

echo -n "Moving old CT tables..."
psql $CRIME_DATA_API_DB_URL < move_default_ct_tables.sql
echo "DONE"

echo -n "Revised cargo theft data..."
psql $CRIME_DATA_API_DB_URL < cargo_theft.sql
echo "DONE"

echo -n "Human trafficking incidents..."
psql $CRIME_DATA_API_DB_URL < human_traffic.sql
echo "DONE"

echo -n "Human trafficking incidents..."
psql $CRIME_DATA_API_DB_URL < estimated.sql
echo "DONE"

echo -n "Agency data.."
psql $CRIME_DATA_API_DB_URL < agencies.sql
echo "DONE"
