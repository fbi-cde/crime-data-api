DROP TABLE IF EXISTS agency_name_edits;
CREATE TABLE agency_name_edits (
ori character(9),
agency_type_name text,
edited_flag text,
agency_name text,
pub_agency_name text,
icpsr_name text
);

\COPY agency_name_edits FROM 'agency_name_edits.csv' DELIMITER ',' HEADER CSV;

UPDATE cde_agencies
SET agency_name = agency_name_edits.agency_name
FROM agency_name_edits
WHERE agency_name_edits.ori = cde_agencies.ori
AND cde_agencies.agency_name <> agency_name_edits.agency_name;

UPDATE agency_offenses_view
SET pub_agency_name = agency_name_edits.agency_name
FROM agency_name_edits
WHERE agency_name_edits.ori = agency_offenses_view.ori
AND agency_offenses_view.pub_agency_name <> agency_name_edits.agency_name;

UPDATE agency_participation
SET agency_name = agency_name_edits.agency_name
FROM agency_name_edits
WHERE agency_participation.agency_ori = agency_name_edits.ori
AND agency_participation.agency_name <> agency_name_edits.agency_name;

UPDATE ht_agency
SET agency_name = agency_name_edits.agency_name
FROM agency_name_edits
WHERE ht_agency.ori = agency_name_edits.ori
AND ht_agency.agency_name <> agency_name_edits.agency_name;

DROP TABLE agency_name_edits;
