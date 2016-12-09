CREATE FUNCTION count_estimate(query text) RETURNS INTEGER AS
$func$
DECLARE
    rec   record;
    ROWS  INTEGER;
BEGIN
    FOR rec IN EXECUTE 'EXPLAIN ' || query LOOP
        ROWS := SUBSTRING(rec."QUERY PLAN" FROM ' rows=([[:digit:]]+)');
        EXIT WHEN ROWS IS NOT NULL;
    END LOOP;
 
    RETURN ROWS;
END
$func$ LANGUAGE plpgsql;