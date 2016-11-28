-- Generates an overview of columns in a schema with an example value
-- along with various metadata.
--
-- To save results to text, run from command line:
-- psql -c "SELECT * FROM schema_overview('my_schema')" mydb > overview.txt

DROP TYPE IF EXISTS column_overview CASCADE;


CREATE TYPE column_overview AS (TABLE_NAME VARCHAR, COLUMN_NAME VARCHAR,
  data_type VARCHAR, max_length INTEGER, example_value VARCHAR,
  column_default VARCHAR, tuples REAL, table_comment VARCHAR,
  column_comment VARCHAR);


DROP FUNCTION IF EXISTS schema_overview(SCHEMA_NAME VARCHAR);


CREATE FUNCTION schema_overview(SCHEMA_NAME VARCHAR DEFAULT 'public') RETURNS
SETOF column_overview AS $$
  DECLARE col_oview column_overview%ROWTYPE;

  BEGIN
  FOR col_oview IN
    SELECT c.table_name, c.column_name,
           c.data_type, c.character_maximum_length,
           '', c.column_default, pc.reltuples,
           ptd.description, pcd.description
    FROM   information_schema.columns c
    JOIN   pg_class pc ON (c.table_name = pc.relname)
    JOIN   pg_namespace pn ON (pc.relnamespace = pn.oid
      AND c.table_schema = pn.nspname)
    LEFT OUTER JOIN   pg_description ptd ON (pc.oid = ptd.objoid
      AND ptd.objsubid = 0)
    LEFT OUTER JOIN   pg_description pcd ON (pc.oid = pcd.objoid
      AND c.ordinal_position = pcd.objsubid)
    WHERE  c.table_schema = schema_name
    ORDER BY c.table_name, c.ordinal_position
  LOOP
    EXECUTE 'SELECT ' || col_oview.column_name ||
      ' FROM ' || schema_name || '.' || col_oview.table_name ||
      ' WHERE ' || col_oview.column_name || ' IS NOT NULL ' ||
      ' AND TRIM(BOTH '' '' FROM CAST(' || col_oview.column_name ||
      ' AS VARCHAR)) != '''' LIMIT 1'
    INTO col_oview.example_value;
    RETURN NEXT col_oview;
  END LOOP;
  RETURN;
  END;
$$ LANGUAGE 'plpgsql';
