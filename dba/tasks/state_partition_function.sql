DROP function IF EXISTS create_state_partition_and_insert() CASCADE;
CREATE OR REPLACE FUNCTION create_state_partition_and_insert() RETURNS trigger AS
$BODY$
DECLARE
partition_state TEXT;
partition TEXT;
BEGIN
partition_state := lower(NEW.state_postal_abbr);
partition := TG_RELNAME || '_' || partition_state;
IF NOT EXISTS(SELECT relname FROM pg_class WHERE relname=lower(partition)) THEN
RAISE NOTICE 'A partition has been created %', partition;
EXECUTE 'CREATE TABLE IF NOT EXISTS ' || partition || ' (check (lower(state_postal_abbr) = lower(''' || NEW.state_postal_abbr || '''))) INHERITS (' || TG_RELNAME || ');';
END IF;
EXECUTE 'INSERT INTO ' || partition || ' SELECT(' || TG_RELNAME || ' ' || quote_literal(NEW) || ').* RETURNING agency_id;';
RETURN NULL;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
