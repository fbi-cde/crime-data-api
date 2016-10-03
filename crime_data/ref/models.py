from django.db import models

# Create your models here.
class RefAgency(models.Model):
    agency_id = models.BigIntegerField(primary_key=True)
    ori = models.CharField(unique=True, max_length=9)
    legacy_ori = models.CharField(max_length=9)
    ucr_agency_name = models.CharField(max_length=100, blank=True, null=True)
    ncic_agency_name = models.CharField(max_length=100, blank=True, null=True)
    pub_agency_name = models.CharField(max_length=100, blank=True, null=True)
    agency_type = models.ForeignKey('RefAgencyType', models.DO_NOTHING)
    special_mailing_group = models.CharField(max_length=1, blank=True, null=True)
    special_mailing_address = models.CharField(max_length=1, blank=True, null=True)
    tribe = models.ForeignKey('RefTribe', models.DO_NOTHING, blank=True, null=True)
    city = models.ForeignKey('RefCity', models.DO_NOTHING, blank=True, null=True)
    state = models.ForeignKey('RefState', models.DO_NOTHING)
    campus = models.ForeignKey('RefUniversityCampus', models.DO_NOTHING, blank=True, null=True)
    agency_status = models.CharField(max_length=1)
    judicial_dist_code = models.CharField(max_length=4, blank=True, null=True)
    submitting_agency = models.ForeignKey('RefSubmittingAgency', models.DO_NOTHING, blank=True, null=True)
    fid_code = models.CharField(max_length=2, blank=True, null=True)
    department = models.ForeignKey('RefDepartment', models.DO_NOTHING, blank=True, null=True)
    added_date = models.DateTimeField(blank=True, null=True)
    change_timestamp = models.DateTimeField(blank=True, null=True)
    change_user = models.CharField(max_length=100, blank=True, null=True)
    legacy_notify_agency = models.CharField(max_length=1, blank=True, null=True)
    dormant_year = models.SmallIntegerField(blank=True, null=True)
    population_family = models.ForeignKey('RefPopulationFamily', models.DO_NOTHING)
    field_office = models.ForeignKey('RefFieldOffice', models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_agency'


class RefAgencyCounty(models.Model):
    agency = models.ForeignKey(RefAgency, models.DO_NOTHING)
    county = models.ForeignKey('RefCounty', models.DO_NOTHING)
    metro_div = models.ForeignKey('RefMetroDivision', models.DO_NOTHING)
    core_city_flag = models.CharField(max_length=1, blank=True, null=True)
    data_year = models.SmallIntegerField()
    population = models.BigIntegerField(blank=True, null=True)
    census = models.BigIntegerField(blank=True, null=True)
    legacy_county_code = models.CharField(max_length=20, blank=True, null=True)
    legacy_msa_code = models.CharField(max_length=20, blank=True, null=True)
    source_flag = models.CharField(max_length=1, blank=True, null=True)
    change_timestamp = models.DateTimeField(blank=True, null=True)
    change_user = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_agency_county'
        unique_together = (('agency', 'county', 'metro_div', 'data_year'),)


class RefAgencyCoveredBy(models.Model):
    agency = models.ForeignKey(RefAgency, models.DO_NOTHING, related_name='+')
    data_year = models.SmallIntegerField()
    covered_by_agency = models.ForeignKey(RefAgency, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'ref_agency_covered_by'
        unique_together = (('agency', 'data_year'),)


class RefAgencyDataContent(models.Model):
    agency = models.ForeignKey(RefAgency, models.DO_NOTHING)
    data_year = models.SmallIntegerField()
    reporting_type = models.CharField(max_length=1, blank=True, null=True)
    nibrs_ct_flag = models.CharField(max_length=1, blank=True, null=True)
    nibrs_hc_flag = models.CharField(max_length=1, blank=True, null=True)
    nibrs_leoka_flag = models.CharField(max_length=1, blank=True, null=True)
    nibrs_arson_flag = models.CharField(max_length=1, blank=True, null=True)
    summary_rape_def = models.CharField(max_length=1, blank=True, null=True)
    nibrs_ht_flag = models.CharField(max_length=1, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_agency_data_content'
        unique_together = (('agency', 'data_year'),)


class RefAgencyPoc(models.Model):
    poc = models.ForeignKey('RefPoc', models.DO_NOTHING)
    agency_id = models.BigIntegerField()
    primary_poc_flag = models.CharField(max_length=1, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_agency_poc'
        unique_together = (('agency_id', 'poc'),)


class RefAgencyType(models.Model):
    agency_type_id = models.SmallIntegerField(primary_key=True)
    agency_type_name = models.CharField(max_length=100, blank=True, null=True)
    default_pop_family = models.ForeignKey('RefPopulationFamily', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'ref_agency_type'


class RefCampusPopulation(models.Model):
    campus = models.ForeignKey('RefUniversityCampus', models.DO_NOTHING)
    data_year = models.SmallIntegerField()
    population = models.BigIntegerField(blank=True, null=True)
    source_flag = models.CharField(max_length=1)
    census = models.BigIntegerField(blank=True, null=True)
    change_timestamp = models.DateTimeField(blank=True, null=True)
    change_user = models.CharField(max_length=100, blank=True, null=True)
    reporting_population = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_campus_population'
        unique_together = (('campus', 'data_year'),)


class RefCity(models.Model):
    city_id = models.BigIntegerField(primary_key=True)
    state = models.ForeignKey('RefState', models.DO_NOTHING)
    city_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_city'
        unique_together = (('city_name', 'state'),)


class RefContinent(models.Model):
    continent_id = models.SmallIntegerField(primary_key=True)
    continent_desc = models.CharField(max_length=50, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_continent'


class RefCountry(models.Model):
    country_id = models.SmallIntegerField(primary_key=True)
    continent = models.ForeignKey(RefContinent, models.DO_NOTHING)
    country_desc = models.CharField(max_length=50, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_country'


class RefCounty(models.Model):
    county_id = models.BigIntegerField(primary_key=True)
    state = models.ForeignKey('RefState', models.DO_NOTHING)
    county_name = models.CharField(max_length=100, blank=True, null=True)
    county_ansi_code = models.CharField(max_length=5, blank=True, null=True)
    county_fips_code = models.CharField(max_length=5, blank=True, null=True)
    legacy_county_code = models.CharField(max_length=5, blank=True, null=True)
    comments = models.CharField(max_length=1000, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_county'


class RefCountyPopulation(models.Model):
    county = models.ForeignKey(RefCounty, models.DO_NOTHING)
    data_year = models.SmallIntegerField()
    population = models.BigIntegerField(blank=True, null=True)
    source_flag = models.CharField(max_length=1)
    change_timestamp = models.DateTimeField(blank=True, null=True)
    change_user = models.CharField(max_length=100, blank=True, null=True)
    reporting_population = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_county_population'
        unique_together = (('county', 'data_year'),)


class RefDepartment(models.Model):
    department_id = models.SmallIntegerField(primary_key=True)
    department_name = models.CharField(max_length=100)
    active_flag = models.CharField(max_length=1)
    sort_order = models.SmallIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_department'


class RefDivision(models.Model):
    division_id = models.SmallIntegerField(primary_key=True)
    region = models.ForeignKey('RefRegion', models.DO_NOTHING)
    division_code = models.CharField(max_length=2, blank=True, null=True)
    division_name = models.CharField(max_length=100, blank=True, null=True)
    division_desc = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_division'


class RefFieldOffice(models.Model):
    field_office_id = models.BigIntegerField(primary_key=True)
    field_office_code = models.CharField(max_length=10, blank=True, null=True)
    field_office_name = models.CharField(max_length=100, blank=True, null=True)
    field_office_alpha_code = models.CharField(max_length=2, blank=True, null=True)
    field_office_numeric_code = models.CharField(max_length=10, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_field_office'


class RefGlobalLocation(models.Model):
    global_location_id = models.BigIntegerField(primary_key=True)
    country = models.ForeignKey(RefCountry, models.DO_NOTHING)
    global_location_desc = models.CharField(max_length=50, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_global_location'


class RefMetroDivPopulation(models.Model):
    metro_div = models.ForeignKey('RefMetroDivision', models.DO_NOTHING)
    data_year = models.SmallIntegerField()
    population = models.BigIntegerField(blank=True, null=True)
    source_flag = models.CharField(max_length=1)
    census = models.BigIntegerField(blank=True, null=True)
    change_timestamp = models.DateTimeField(blank=True, null=True)
    change_user = models.CharField(max_length=100, blank=True, null=True)
    reporting_population = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_metro_div_population'
        unique_together = (('metro_div', 'data_year'),)


class RefMetroDivision(models.Model):
    metro_div_id = models.BigIntegerField(primary_key=True)
    msa = models.ForeignKey('RefMsa', models.DO_NOTHING)
    metro_div_name = models.CharField(max_length=100, blank=True, null=True)
    msa_flag = models.CharField(max_length=1, blank=True, null=True)
    metro_div_omb_code = models.CharField(max_length=5, blank=True, null=True)
    legacy_msa_code = models.CharField(max_length=5, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_metro_division'


class RefMsa(models.Model):
    msa_id = models.BigIntegerField(primary_key=True)
    msa_name = models.CharField(max_length=100, blank=True, null=True)
    msa_omb_code = models.CharField(max_length=5, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_msa'
        unique_together = (('msa_name', 'msa_omb_code'),)


class RefParentPopulationGroup(models.Model):
    parent_pop_group_id = models.BigIntegerField(primary_key=True)
    parent_pop_group_code = models.CharField(max_length=2, blank=True, null=True)
    parent_pop_group_desc = models.CharField(max_length=100, blank=True, null=True)
    publication_name = models.CharField(max_length=100, blank=True, null=True)
    population_family = models.ForeignKey('RefPopulationFamily', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'ref_parent_population_group'


class RefPoc(models.Model):
    poc_id = models.BigIntegerField(primary_key=True)
    poc_name = models.CharField(max_length=200, blank=True, null=True)
    poc_title = models.CharField(max_length=200, blank=True, null=True)
    poc_email = models.CharField(max_length=200, blank=True, null=True)
    poc_phone1 = models.CharField(max_length=50, blank=True, null=True)
    poc_phone2 = models.CharField(max_length=50, blank=True, null=True)
    mailing_address_1 = models.CharField(max_length=150, blank=True, null=True)
    mailing_address_2 = models.CharField(max_length=150, blank=True, null=True)
    mailing_address_3 = models.CharField(max_length=150, blank=True, null=True)
    mailing_address_4 = models.CharField(max_length=150, blank=True, null=True)
    state = models.ForeignKey('RefState', models.DO_NOTHING, blank=True, null=True)
    zip_code = models.CharField(max_length=10, blank=True, null=True)
    city_name = models.CharField(max_length=100, blank=True, null=True)
    poc_fax1 = models.CharField(max_length=20, blank=True, null=True)
    poc_fax2 = models.CharField(max_length=20, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_poc'


class RefPocRole(models.Model):
    poc_role_id = models.SmallIntegerField(primary_key=True)
    poc_role_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_poc_role'


class RefPocRoleAssign(models.Model):
    poc = models.ForeignKey(RefPoc, models.DO_NOTHING)
    poc_role = models.ForeignKey(RefPocRole, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'ref_poc_role_assign'
        unique_together = (('poc', 'poc_role'),)


class RefPopulationFamily(models.Model):
    population_family_id = models.SmallIntegerField(primary_key=True)
    population_family_name = models.CharField(max_length=100, blank=True, null=True)
    population_family_desc = models.CharField(max_length=200, blank=True, null=True)
    sort_order = models.SmallIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_population_family'


class RefPopulationGroup(models.Model):
    population_group_id = models.BigIntegerField(primary_key=True)
    population_group_code = models.CharField(max_length=2, blank=True, null=True)
    population_group_desc = models.CharField(max_length=150, blank=True, null=True)
    parent_pop_group = models.ForeignKey(RefParentPopulationGroup, models.DO_NOTHING)
    publication_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_population_group'


class RefRace(models.Model):
    race_id = models.SmallIntegerField(primary_key=True)
    race_code = models.CharField(unique=True, max_length=2)
    race_desc = models.CharField(max_length=100)
    sort_order = models.SmallIntegerField(blank=True, null=True)
    start_year = models.SmallIntegerField(blank=True, null=True)
    end_year = models.SmallIntegerField(blank=True, null=True)
    notes = models.CharField(max_length=1000, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_race'


class RefRegion(models.Model):
    region_id = models.SmallIntegerField(primary_key=True)
    region_code = models.CharField(max_length=2, blank=True, null=True)
    region_name = models.CharField(max_length=100, blank=True, null=True)
    region_desc = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_region'


class RefState(models.Model):
    state_id = models.SmallIntegerField(primary_key=True)
    division = models.ForeignKey(RefDivision, models.DO_NOTHING)
    state_name = models.CharField(max_length=100, blank=True, null=True)
    state_code = models.CharField(max_length=2, blank=True, null=True)
    state_abbr = models.CharField(max_length=2, blank=True, null=True)
    state_postal_abbr = models.CharField(max_length=2, blank=True, null=True)
    state_fips_code = models.CharField(max_length=2, blank=True, null=True)
    state_pub_freq_months = models.SmallIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_state'


class RefSubmittingAgency(models.Model):
    agency_id = models.BigIntegerField(primary_key=True)
    sai = models.CharField(max_length=9, blank=True, null=True)
    agency_name = models.CharField(max_length=150, blank=True, null=True)
    state = models.ForeignKey(RefState, models.DO_NOTHING, blank=True, null=True)
    notify_agency = models.CharField(max_length=1, blank=True, null=True)
    agency_email = models.CharField(max_length=200, blank=True, null=True)
    agency_website = models.CharField(max_length=2000, blank=True, null=True)
    comments = models.CharField(max_length=2000, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_submitting_agency'


class RefTribe(models.Model):
    tribe_id = models.BigIntegerField(primary_key=True)
    tribe_name = models.CharField(unique=True, max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_tribe'


class RefTribePopulation(models.Model):
    tribe = models.ForeignKey(RefTribe, models.DO_NOTHING)
    data_year = models.SmallIntegerField()
    population = models.BigIntegerField(blank=True, null=True)
    source_flag = models.CharField(max_length=1)
    census = models.BigIntegerField(blank=True, null=True)
    change_timestamp = models.DateTimeField(blank=True, null=True)
    change_user = models.CharField(max_length=100, blank=True, null=True)
    reporting_population = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_tribe_population'
        unique_together = (('tribe', 'data_year'),)


class RefUniversity(models.Model):
    university_id = models.BigIntegerField(primary_key=True)
    university_abbr = models.CharField(max_length=20, blank=True, null=True)
    university_name = models.CharField(unique=True, max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_university'


class RefUniversityCampus(models.Model):
    campus_id = models.BigIntegerField(primary_key=True)
    university = models.ForeignKey(RefUniversity, models.DO_NOTHING)
    campus_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ref_university_campus'

class OffenseClassification(models.Model):
    classification_id = models.SmallIntegerField(primary_key=True)
    classification_name = models.CharField(max_length=50, blank=True, null=True)
    class_sort_order = models.SmallIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'offense_classification'

class CrimeType(models.Model):
    crime_type_id = models.SmallIntegerField(primary_key=True)
    crime_type_name = models.CharField(max_length=50, blank=True, null=True)
    crime_type_sort_order = models.SmallIntegerField(blank=True, null=True)
    crime_flag = models.CharField(max_length=1, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'crime_type'