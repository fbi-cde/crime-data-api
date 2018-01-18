-- This should clear out a bunch of records
DELETE FROM nibrs_incident WHERE EXTRACT(year from incident_date) > 2014;

DELETE FROM

DELETE FROM nibrs_victim_offense
WHERE victim_id NOT IN (select victim_id FROM nibrs_victim);

DELETE FROM nibrs_victim_offender_rel
WHERE victim_id NOT IN (select victim_id FROM nibrs_victim);

DELETE FROM nibrs_weapon
WHERE offense_id NOT IN (select offense_id FROM nibrs_offense);
