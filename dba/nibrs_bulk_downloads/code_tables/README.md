# ABOUT THIS DATA

This download contains a year's worth of incident and arrestee data
for a single state that participates in the National Incident-Based
Reporting System (NIBRS) system. NIBRS is the successor to the Summary
Reporting System (SRS) previously used by the UCR program since the
1930s, and it offers incident-level data with more detailed
information about offenders, victims, relationships between offenders
and victims, and offenses affecting victims. It also removes the the
"hierarchy rule" that meant only a single offense was counted as part
of SRS summary reports.

For detailed information about all the fields provided in NIBRS and
how they are collected and presented, please refer to the [official
NIBRS documentation](https://ucr.fbi.gov/nibrs/nibrs-user-manual).

## The Main Data Tables

The NIBRS data is divided among 43 distinct tables. Of these, 20 are
code lookup tables that can be used to retrieve codes and names used
at various points within NIBRS. These do not change from year to
year. The other tables will vary from each download depending on the
state and year. These tables are:

### nibrs_month

This table represents if a specific agency filed a NIBRS incident report in a specific month or year.

Notes:
* `agency_id` refers to an agency in the `cde_agencies` table
* `reported_status` has the following codes: I - filed an incident report for that month/year; Z - filed a Zero Report; U - did not file

### nibrs_incident

Represents a single incident in NIBRS. Note that since NIBRS requires
all offenders to be acting in concert for all offenses in an incident,
crimes may sometimes be split among multiple incidents. See the NIBRS
reference manual for more detail on what "in concert" means.

Notes:
* `agency_id` refers to an agency in the `cde_agencies` table
* `nibrs_month_id` links this incident to the `nibrs_month` it's associated with
* `cleared_except_id` refers to a type of exceptional clearance in the
  `nibrs_cleared_except` table
* `report_date_flag` indicates if the agency used the report date as
  the `incident_date`


### nibrs_offense

An incident can have up to 10 offense records associated with it. All
offenders are assumed to have acted in concert to commit all
offenses. Offense records reflect distinct types of offenses, not
specific "counts" of offenses charged against offenders.

Notes:
* `incident_id` reference the NIBRS incident this offense is associated with.
* `offense_type_id` references the `nibrs_offense_type` table
* `attempt_complete_flag` values: 'A' - attempted; 'C' - completed
* `location_id` references the type of location where the incident
  occurred. Note that the location_type is determined by use at the
  time of offense so a school being used as a church on a weekend
  could be coded as either depending on its use when the offense
  occurred.
* `num_premises_entered` please read the NIBRS documentation about the
  "Hotel Rule" for crimes in hotels.
* `method_entry_code` values: F - force; N - no force. This element is
  only used for Burglary/Breaking and Entering offenses.

### nibrs_offender

An incident can have up to 99 offender records associated with it.

Notes:
* `offender_seq_num` provides an ordering to list offenders. In cases
  where there is one or more unknown offenders for an incident, there
  will be a record with a offender_seq_num of 0 and NULL for all
  demographic associations.
* `incident_id` references the NIBRS incident this offender is associated with.
* `age_id` refers to the `nibrs_age` table
* `sex_code` values: 'M' - male; 'F' - female; 'U' - unknown
* `race_id` refers to the `ref_race` table
* `ethnicity_id` refers to the `nibrs_ethnicity` table

### nibrs_victim

An incident can have up to 999 victims associated with it.

Notes:
* `incident_id` references the NIBRS incident this offender is
  associated with. This is for convenience to find victims and should
  NOT be use to identify what offenses apply to the victim.
* `victim_type_id` references the `victim_type` table. Note that not
  all victims are people. For instance, a bank robbery would include a
  Bank as a victim and crimes against society usually have a sole
  victim of type Society.
* `age_id` refers to the `nibrs_age` table
* `sex_code` values: 'M' - male; 'F' - female; 'U' - unknown
* `race_id` refers to the `ref_race` table
* `ethnicity_id` refers to the `nibrs_ethnicity` table
* `assignment_type_id` refers to the `nibrs_assignment_type` table if
  the victim was an officer killed or injured in the line of duty.
* `activity_type_id` refers to the `nibrs_activity_type` table if the
  victim was an officer killed or injured in the line of duty.
* `resident_status_code` indicates that the victim had a permanent
  residence in the locality where the incident occurred. Values: N -
  nonresident; R - resident; U - unknown

### nibrs_victim_offense

This table maps victims to offenses and should be used to get all
victims of a specific offense associated with an incident. Do not
simply assume that all offenses associated with an incident apply to
all victims.

Notes:
* `offense_id` references the `nibrs_offense` table
* `victim_id` references the `nibrs_victim` table

### nibrs_victim_offender_rel

Specifies relationships between each victim in an incident and up to
10 offenders, prioritizing more immediate relationships if there are
many offenders. Note that this information is only mandatory for
incidents where one of the offenses is a Crime Against Person or a
robbery.

Notes:
* `offender_id` references the `nibrs_offender` table
* `victim_id` references the `nibrs_victim` table
* `relationship_id` references the `nibrs_relationship` table

### nibrs_weapon

Each NIBRS offense can have up to 3 weapon records associated with
it. If the same weapon is used for multiple offenses in an incident,
there will be a `nibrs_weapon` record for each offense that weapon was
used.

Notes:
* `offense_id` references the `nibrs_offense` table
* `weapon_id` references the `nibrs_weapon_type` table

### nibrs_property

Each incident can have up to 10 property records associated with it,
prioritizing the most valuable property first if there are more than
10 records. The property loss type indicates the context for the
property, and these records can be used for property that was stolen,
seized, counterfeited or destroyed depending on the circumstances.

Notes:
* `incident_id` refers to the `nibrs_incident` associated with this property.
* `prop_loss_id` refers to the `nibrs_prop_loss_type` table

### nibrs_property_desc

This table provides some description about property records in the `nibrs_property` table.

Notes:
* `property_id` refers to the `nibrs_property` table
* `prop_desc_id` refers to the `nibrs_prop_desc_type` table

### nibrs_suspected_drug

This table only applies for specific incidents where one of the
offenses is a Drug/Narcotics violation. Up to three types of suspected
drugs can be recorded for an incident.

Notes:
* `suspected_drug_type_id` references the `nibrs_suspected_drug_type` table
* `property_id` references the `nibrs_property` table
* `drug_measure_type_id` references the `nibrs_drug_measure_type` table

### nibrs_suspect_using

There can be up to 3 `suspect_using` records applied to each offense in an incident.

Notes:
* `offense_id` references the `nibrs_offense` table
* `suspect_using_id` references the `nibrs_using_list` table

### nibrs_victim_injury

NIBRS can record up to 10 injuries for each victim in an incident.

Notes:
* `victim_id` references the `nibrs_victim` table
* `injury_id` references the `nibrs_injury_type` table

### nibrs_criminal_act

There can also be up to 3 types of criminal activity records
associated with a specific offense. Most of the criminal activity type
codes are only applied for specific offenses like Animal Cruelty or
Gambling Equipment Violations. But there are also specific criminal
activity flags for gang and juvenile gang-related crimes that can be
applied to any type of offense.

Notes:
* `offense_id` references the `nibrs_offense` table
* `criminal_act_id` references the `nibrs_criminal_act_type` table

### nibrs_bias_motivation

There can be up to 5 bias motivations recorded for any specific
offense to indicate if the offense was likely motivated by the
offender's bias. Please refer to the NIBRS manual for information
about how and when bias is recorded for offenses or not.

Notes:
* `offense_id` references the `nibrs_offense` table
* `bias_id` references the `nibrs_bias_list` table

### nibrs_arrestee

This table tracks arrests related to specific incidents

Notes:
* `incident_id` references the NIBRS incident this offender is
  associated with. This is for convenience to find victims and should
  NOT be use to identify what offenses apply to the victim.
* `arrest_type_id` references the `nibrs_arrest_type` table
* `offense_type_id` references the `nibrs_offense_type` table
* `age_id` refers to the `nibrs_age` table
* `sex_code` values: 'M' - male; 'F' - female
* `race_id` refers to the `ref_race` table
* `ethnicity_id` refers to the `nibrs_ethnicity` table
* `resident_code` indicates that the arrestee had a permanent
  residence in the locality where the incident occurred. Values: N -
  nonresident; R - resident; U - unknown


### nibrs_arrestee_weapon

Arrestees can have multiple weapons at the time of arrest.

Notes:
* `arrestee_id` references the `nibrs_arrestee` table
* `weapon_id` references the `nibrs_weapon` table

### agency_participation

Provides some precalculated information about agency participation in
the year based on counts from the nibrs_month database. An agency is
considered to be participating if it either reported 12 months of data
or "zero reports" or if it was covered in the year by another agency
that did so.

### cde_agencies

The cde_agencies table gathers information about agencies from several
tables and is provided as a convenience to help simplify some types of
queries.

## Loading into a local database

For your convenience, these NIBRS download archives include two files
each for setting up and loading the data into PostgreSQL or SQLite 3
databases.

To load into postgres, use `createdb` to create a database and then
run the following to setup the basic database structure and load the
common code lookup tables:

```
psql your_db_name < postgres_create.sql
```

You then can run the following command in each of the NIBRS annual zipfiles you have downloaded to load that year's data into your database:

```
psql your_db_name < postgres_load.sql
```

The process to create and load into a SQLite database is somewhat similar. To create and populate the code tables:

```
sqlite3 your_db_name.db < sqlite_create.sql
```

Then to load in data into the database, run the following in each extracted zipfile of data you have downloaded

```
sqlite3 your_db_name.db < sqlite_load.sql
```

## Some Sample Queries

The best way to understand how NIBRS relates is to look at some
example queries. Because the NIBRS database is in fifth-normal form,
it is often necessary to join in multiple tables just to resolve
specific codes for things like race or weapon type. In general, almost
every one of the data tables has a foreign key linking it to a
nibrs_incident which you can use to find all the
offenses/offenders/victims/property related together in an incident
(but you do need to look at other tables to relate victims directly to
offenders or offenses). Let's get started with some examples.

To get all the incidents in West Virginia that happened in 2015, you can run the following query:

``` sql
SELECT ni.*
FROM nibrs_incident ni
JOIN nibrs_month nm ON nm.nibrs_month_id = ni.nibrs_month_id
JOIN cde_agencies c ON c.agency_id = nm.agency_id
WHERE c.state_abbr = 'WV'
AND nm.data_year = 2014;
```

To get all homicide offenses in West Virginia in 2015

``` sql
SELECT o.*
FROM nibrs_offense o
JOIN nibrs_incident ni ON o.incident_id = ni.incident_id
JOIN nibrs_month nm ON nm.nibrs_month_id = ni.nibrs_month_id
JOIN cde_agencies c ON c.agency_id = nm.agency_id
JOIN nibrs_offense_type ot ON ot.offense_type_id = o.offense_type_id
WHERE c.state_abbr = 'WV'
AND nm.data_year = 2014
AND ot.offense_code = '09A';
```

To get information about homicide victims in West Virginia in 2015 you
will need to use the victim_offense table and also join in some of the
lookup tables.

``` sql
SELECT r.race_code, a.age_code, v.age_num, e.ethnicity_code
FROM nibrs_victim v
JOIN nibrs_victim_offense vo ON vo.victim_id = v.victim_id
JOIN nibrs_offense o ON o.offense_id = vo.offense_id
JOIN nibrs_incident ni ON ni.incident_id = v.incident_id
JOIN nibrs_month nm ON nm.nibrs_month_id = ni.nibrs_month_id
JOIN ref_race r ON r.race_id = v.race_id
JOIN nibrs_age a ON a.age_id = v.age_id
JOIN nibrs_ethnicity e ON e.ethnicity_id = v.ethnicity_id
JOIN cde_agencies c ON c.agency_id = nm.agency_id
JOIN nibrs_offense_type ot ON ot.offense_type_id = o.offense_type_id
WHERE c.state_abbr = 'WV'
AND nm.data_year = 2014
AND ot.offense_code = '09A';
```

To see a breakdown of where robberies happened in West Virginia in 2014

``` sql
SELECT location_code, location_name, count(*)
FROM nibrs_offense o
JOIN nibrs_incident ni ON ni.incident_id = o.incident_id
JOIN nibrs_month nm ON nm.nibrs_month_id = ni.nibrs_month_id
JOIN nibrs_offense_type ot ON ot.offense_type_id = o.offense_type_id
JOIN nibrs_location_type l ON l.location_id = o.location_id
JOIN cde_agencies c ON c.agency_id = nm.agency_id
WHERE c.state_abbr = 'WV'
AND nm.data_year = 2014
AND ot.offense_code = '120'
GROUP by location_code, location_name
ORDER by location_code;
```

And so on. There are many ways you can approach NIBRS data, but be
sure to understand how some of the tables relate to each other and the
meanings of certain fields.
