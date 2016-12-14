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
