psql $CRIME_DATA_API_DB_URL <after_load/create_reta_summary.sql >/dev/null
psql $CRIME_DATA_API_DB_URL <after_load/create_reta_summary_indexes.sql >/dev/null
psql $CRIME_DATA_API_DB_URL <after_load/add_arson_to_reta_summary.sql >/dev/null
