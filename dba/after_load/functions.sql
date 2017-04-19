DROP FUNCTION IF EXISTS count_estimate(query text);
CREATE FUNCTION count_estimate(query text) RETURNS BIGINT AS
$func$
DECLARE
    rec   record;
    ROWS  BIGINT;
BEGIN
    FOR rec IN EXECUTE 'EXPLAIN ' || query LOOP
        ROWS := SUBSTRING(rec."QUERY PLAN" FROM ' rows=([[:digit:]]+)');
        EXIT WHEN ROWS IS NOT NULL;
    END LOOP;
 
    RETURN ROWS;
END
$func$ LANGUAGE plpgsql;

DROP function IF EXISTS create_partition_and_insert() CASCADE;
CREATE OR REPLACE FUNCTION create_partition_and_insert() RETURNS trigger AS
  $BODY$
    DECLARE
      partition_date TEXT;
      partition TEXT;
    BEGIN
      partition_date := to_char(NEW.incident_date,'YYYY');
      partition := TG_RELNAME || '_' || partition_date;
      IF NOT EXISTS(SELECT relname FROM pg_class WHERE relname=partition) THEN
        RAISE NOTICE 'A partition has been created %',partition;
        EXECUTE 'CREATE TABLE ' || partition || ' (check (year = ''' || NEW.year || ''')) INHERITS (' || TG_RELNAME || ');';
      END IF;
      EXECUTE 'INSERT INTO ' || partition || ' SELECT(' || TG_RELNAME || ' ' || quote_literal(NEW) || ').* RETURNING incident_id;';
      RETURN NULL;
    END;
  $BODY$
LANGUAGE plpgsql VOLATILE
COST 100;



DROP function IF EXISTS create_state_partition_and_insert() CASCADE;
CREATE OR REPLACE FUNCTION create_state_partition_and_insert() RETURNS trigger AS
  $BODY$
    DECLARE
      partition_state TEXT;
      partition TEXT;
    BEGIN
      partition_state := NEW.state_postal_abbr;
      partition := TG_RELNAME || '_' || partition_state;
      IF NOT EXISTS(SELECT relname FROM pg_class WHERE relname=partition) THEN
        RAISE NOTICE 'A partition has been created %', partition;
        EXECUTE 'CREATE TABLE ' || partition || ' (check (state_postal_abbr = ''' || NEW.state_postal_abbr || ''')) INHERITS (' || TG_RELNAME || ');';
        EXECUTE 'CREATE UNIQUE INDEX ' || partition || '_idx ON ' || partition || '(agency_id, date)';
      END IF;
      EXECUTE 'INSERT INTO ' || partition || ' SELECT(' || TG_RELNAME || ' ' || quote_literal(NEW) || ').* RETURNING agency_id;';
      RETURN NULL;
    END;
  $BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

CREATE TABLE reta_annual_offense_agency_summary (
  agency_id integer,
  date date DEFAULT NOW()
);

CREATE TRIGGER agency_sum_partition_insert_trigger
BEFORE INSERT ON reta_annual_offense_agency_summary
FOR EACH ROW EXECUTE PROCEDURE create_state_partition_and_insert();