SET work_mem='4096MB'; -- Go Super Saiyan.

DROP TABLE IF EXISTS flat_covered_by_temp CASCADE;

CREATE TABLE flat_covered_by_temp
(
  data_year smallint NOT NULL,
  agency_id bigint NOT NULL,
  covered_by_agency_id bigint NOT NULL,
  PRIMARY KEY(data_year, agency_id)
);

WITH RECURSIVE flatcover(data_year, agency_id, covered_by_agency_id, root_agency_id) AS (
SELECT data_year, agency_id, 0::bigint AS covered_by_agency_id, agency_id AS root_agency_id
FROM ref_agency_county WHERE ref_agency_county.agency_id NOT IN (select agency_id from ref_agency_covered_by WHERE data_year=ref_agency_county.data_year)
UNION ALL
SELECT u.data_year, u.agency_id, u.covered_by_agency_id, f.root_agency_id
FROM flatcover f
INNER JOIN ref_agency_covered_by u ON f.agency_id=u.covered_by_agency_id AND f.data_year=u.data_year
)
INSERT INTO flat_covered_by_temp(data_year, agency_id, covered_by_agency_id)
SELECT data_year, agency_id, root_agency_id AS covered_by_agency_id FROM flatcover WHERE agency_id <> root_agency_id;

DROP TABLE IF EXISTS ref_agency_covered_by_flat CASCADE;
ALTER TABLE flat_covered_by_temp RENAME TO ref_agency_covered_by_flat;

ALTER TABLE ONLY ref_agency_covered_by_flat
ADD CONSTRAINT flat_covered_by_agency_id_fk FOREIGN KEY (agency_id) REFERENCES cde_agencies(agency_id);

ALTER TABLE ONLY ref_agency_covered_by_flat
ADD CONSTRAINT flat_covered_by_agency_id_covering_fk FOREIGN KEY (covered_by_agency_id) REFERENCES cde_agencies(agency_id);
