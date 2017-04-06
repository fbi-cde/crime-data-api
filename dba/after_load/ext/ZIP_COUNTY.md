# Zip-County Mappings

These are obtained from the [HUD USPS crosswalk site](https://www.huduser.gov/portal/datasets/usps_crosswalk.html) (county zip crosswalk). Once you have downloaded a file, run through the following steps here in `pgsql`:

First we need to load the CSV:

``` sql
create temporary table hud_zips
(
zip char(5),
fips char(5),
t1 float,
t2 float,
t3 float,
t4 float
);

```
Then we load the CSV into the temp table

``` sql
\COPY hud_zips FROM 'zip_county_122016.csv' DELIMITER ',' CSV HEADER;

```

Now it's time to load the cde_zip_counties table:

``` sql
drop table if exists cde_zip_counties;
CREATE TABLE cde_zip_counties
(
zip char(5) NOT NULL,
fips char(5) NOT NULL,
county_id bigint,
PRIMARY KEY(zip, fips)
);

```

And now to populate it:

```
INSERT INTO cde_zip_counties(zip, fips, county_id)
SELECT h.zip, h.fips, q.county_id
FROM hud_zips h,
(SELECT rc.county_id,
        LPAD(rs.state_fips_code, 2, '0') || LPAD(rc.county_fips_code, 3, '0') AS county_fips
        from ref_county rc
        JOIN ref_state rs ON rs.state_id=rc.county_id) q
WHERE q.county_fips = h.fips;

ALTER TABLE ONLY cde_zip_counties
ADD CONSTRAINT cde_zip_counties_fk FOREIGN KEY (county_id) REFERENCES ref_county(county_id);

DROP TABLE hud_zips;
```

And there you have it. Once this is done, you should be able to do this

``` python
from crime_data.common.newmodels import CdeAgency

CdeAgency.find_by_zip('20912')
```
