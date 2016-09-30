from __future__ import unicode_literals

from django.db import models

# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey has `on_delete` set to the desired behavior.
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.

class ArsonMonth(models.Model):
    arson_month_id = models.BigIntegerField(primary_key=True)
    agency = models.ForeignKey('RefAgency', models.DO_NOTHING)
    data_year = models.SmallIntegerField()
    month_num = models.SmallIntegerField()
    data_home = models.CharField(max_length=1)
    source_flag = models.CharField(max_length=1)
    reported_flag = models.CharField(max_length=1, blank=True, null=True)
    ddocname = models.CharField(max_length=100, blank=True, null=True)
    month_included_in = models.SmallIntegerField(blank=True, null=True)
    report_date = models.DateTimeField(blank=True, null=True)
    prepared_date = models.DateTimeField(blank=True, null=True)
    orig_format = models.CharField(max_length=1, blank=True, null=True)
    update_flag = models.CharField(max_length=1, blank=True, null=True)
    did = models.BigIntegerField(blank=True, null=True)
    ff_line_number = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'arson_month'
        unique_together = (('agency', 'data_year', 'month_num', 'data_home'),)


class ArsonMonthBySubcat(models.Model):
    arson_month = models.ForeignKey(ArsonMonth, models.DO_NOTHING)
    subcategory = models.ForeignKey('ArsonSubcategory', models.DO_NOTHING)
    reported_count = models.IntegerField(blank=True, null=True)
    reported_status = models.SmallIntegerField(blank=True, null=True)
    unfounded_count = models.IntegerField(blank=True, null=True)
    unfounded_status = models.SmallIntegerField(blank=True, null=True)
    actual_count = models.IntegerField(blank=True, null=True)
    actual_status = models.SmallIntegerField(blank=True, null=True)
    cleared_count = models.IntegerField(blank=True, null=True)
    cleared_status = models.SmallIntegerField(blank=True, null=True)
    juvenile_cleared_count = models.IntegerField(blank=True, null=True)
    juvenile_cleared_status = models.SmallIntegerField(blank=True, null=True)
    uninhabited_count = models.IntegerField(blank=True, null=True)
    uninhabited_status = models.SmallIntegerField(blank=True, null=True)
    est_damage_value = models.BigIntegerField(blank=True, null=True)
    est_damage_value_status = models.SmallIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'arson_month_by_subcat'
        unique_together = (('arson_month', 'subcategory'),)


class ArsonSubcategory(models.Model):
    subcategory_id = models.BigIntegerField(primary_key=True)
    subcategory_name = models.CharField(max_length=100, blank=True, null=True)
    subcategory_code = models.CharField(unique=True, max_length=20, blank=True, null=True)
    subclass = models.ForeignKey('ArsonSubclassification', models.DO_NOTHING)
    subcat_xml_path = models.CharField(max_length=4000, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'arson_subcategory'


class ArsonSubclassification(models.Model):
    subclass_id = models.SmallIntegerField(primary_key=True)
    subclass_name = models.CharField(max_length=100, blank=True, null=True)
    subclass_code = models.CharField(unique=True, max_length=20, blank=True, null=True)
    subclass_xml_path = models.CharField(max_length=4000, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'arson_subclassification'


class AsrAgeRange(models.Model):
    age_range_id = models.BigIntegerField(primary_key=True)
    age_range_name = models.CharField(max_length=20, blank=True, null=True)
    age_range_code = models.CharField(unique=True, max_length=20, blank=True, null=True)
    juvenile_flag = models.CharField(max_length=1)
    ff_sort_order = models.CharField(max_length=3, blank=True, null=True)
    age_sex = models.CharField(max_length=1, blank=True, null=True)
    xml_code = models.CharField(max_length=2001, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'asr_age_range'


class AsrAgeSexSubcat(models.Model):
    asr_month = models.ForeignKey('AsrMonth', models.DO_NOTHING)
    offense_subcat = models.ForeignKey('AsrOffenseSubcat', models.DO_NOTHING)
    age_range = models.ForeignKey(AsrAgeRange, models.DO_NOTHING)
    arrest_count = models.IntegerField(blank=True, null=True)
    arrest_status = models.SmallIntegerField(blank=True, null=True)
    active_flag = models.CharField(max_length=1, blank=True, null=True)
    prepared_date = models.DateTimeField(blank=True, null=True)
    report_date = models.DateTimeField(blank=True, null=True)
    ff_line_number = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'asr_age_sex_subcat'
        unique_together = (('asr_month', 'offense_subcat', 'age_range'),)


class AsrEthnicity(models.Model):
    ethnicity_id = models.BigIntegerField(primary_key=True)
    ethnicity_name = models.CharField(max_length=100, blank=True, null=True)
    ethnicity_code = models.CharField(unique=True, max_length=20, blank=True, null=True)
    ff_sort_order = models.CharField(max_length=3, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'asr_ethnicity'


class AsrEthnicityOffense(models.Model):
    asr_month = models.ForeignKey('AsrMonth', models.DO_NOTHING)
    offense_subcat = models.ForeignKey('AsrOffenseSubcat', models.DO_NOTHING)
    ethnicity = models.ForeignKey(AsrEthnicity, models.DO_NOTHING)
    juvenile_flag = models.CharField(max_length=1)
    arrest_count = models.IntegerField(blank=True, null=True)
    arrest_status = models.SmallIntegerField(blank=True, null=True)
    prepared_date = models.DateTimeField(blank=True, null=True)
    report_date = models.DateTimeField(blank=True, null=True)
    ff_line_number = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'asr_ethnicity_offense'
        unique_together = (('asr_month', 'offense_subcat', 'ethnicity', 'juvenile_flag'),)


class AsrJuvenileDisposition(models.Model):
    asr_month = models.ForeignKey('AsrMonth', models.DO_NOTHING, primary_key=True)
    report_date = models.DateTimeField(blank=True, null=True)
    prepared_date = models.DateTimeField(blank=True, null=True)
    handled_within_dept = models.IntegerField(blank=True, null=True)
    juvenile_court = models.IntegerField(blank=True, null=True)
    welfare_agency = models.IntegerField(blank=True, null=True)
    other_police = models.IntegerField(blank=True, null=True)
    adult_court = models.IntegerField(blank=True, null=True)
    ff_line_number = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'asr_juvenile_disposition'


class AsrMonth(models.Model):
    asr_month_id = models.BigIntegerField(primary_key=True)
    agency = models.ForeignKey('RefAgency', models.DO_NOTHING)
    data_year = models.SmallIntegerField()
    month_num = models.SmallIntegerField()
    source_flag = models.CharField(max_length=1)
    reported_flag = models.CharField(max_length=1, blank=True, null=True)
    orig_format = models.CharField(max_length=1, blank=True, null=True)
    update_flag = models.CharField(max_length=1, blank=True, null=True)
    ff_line_number = models.BigIntegerField(blank=True, null=True)
    ddocname = models.CharField(max_length=100, blank=True, null=True)
    did = models.BigIntegerField(blank=True, null=True)
    data_home = models.CharField(max_length=1)

    class Meta:
        managed = False
        db_table = 'asr_month'
        unique_together = (('agency', 'data_year', 'month_num', 'data_home'),)


class AsrOffense(models.Model):
    offense_id = models.BigIntegerField(primary_key=True)
    offense_cat = models.ForeignKey('AsrOffenseCategory', models.DO_NOTHING)
    offense_name = models.CharField(max_length=100, blank=True, null=True)
    offense_code = models.CharField(unique=True, max_length=20, blank=True, null=True)
    total_flag = models.CharField(max_length=1, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'asr_offense'


class AsrOffenseCategory(models.Model):
    offense_cat_id = models.BigIntegerField(primary_key=True)
    offense_cat_name = models.CharField(max_length=100, blank=True, null=True)
    offense_cat_code = models.CharField(unique=True, max_length=20, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'asr_offense_category'


class AsrOffenseSubcat(models.Model):
    offense_subcat_id = models.BigIntegerField(primary_key=True)
    offense = models.ForeignKey(AsrOffense, models.DO_NOTHING)
    offense_subcat_name = models.CharField(max_length=100, blank=True, null=True)
    offense_subcat_code = models.CharField(unique=True, max_length=20, blank=True, null=True)
    srs_offense_code = models.CharField(max_length=3, blank=True, null=True)
    master_offense_code = models.SmallIntegerField(blank=True, null=True)
    total_flag = models.CharField(max_length=1, blank=True, null=True)
    adult_juv_flag = models.CharField(max_length=1, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'asr_offense_subcat'


class AsrRaceOffenseSubcat(models.Model):
    asr_month = models.ForeignKey(AsrMonth, models.DO_NOTHING)
    offense_subcat = models.ForeignKey(AsrOffenseSubcat, models.DO_NOTHING)
    race = models.ForeignKey('RefRace', models.DO_NOTHING)
    juvenile_flag = models.CharField(max_length=1)
    arrest_count = models.IntegerField(blank=True, null=True)
    arrest_status = models.SmallIntegerField(blank=True, null=True)
    active_flag = models.CharField(max_length=1, blank=True, null=True)
    prepared_date = models.DateTimeField(blank=True, null=True)
    report_date = models.DateTimeField(blank=True, null=True)
    ff_line_number = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'asr_race_offense_subcat'
        unique_together = (('asr_month', 'offense_subcat', 'race', 'juvenile_flag'),)


class CrimeType(models.Model):
    crime_type_id = models.SmallIntegerField(primary_key=True)
    crime_type_name = models.CharField(max_length=50, blank=True, null=True)
    crime_type_sort_order = models.SmallIntegerField(blank=True, null=True)
    crime_flag = models.CharField(max_length=1, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'crime_type'


class CtArrestee(models.Model):
    arrestee_id = models.BigIntegerField(primary_key=True)
    incident = models.ForeignKey('CtIncident', models.DO_NOTHING)
    age = models.SmallIntegerField(blank=True, null=True)
    sex_code = models.CharField(max_length=1, blank=True, null=True)
    ethnicity = models.ForeignKey('NibrsEthnicity', models.DO_NOTHING, blank=True, null=True)
    race = models.ForeignKey('RefRace', models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ct_arrestee'


class CtIncident(models.Model):
    incident_id = models.BigIntegerField(primary_key=True)
    agency = models.ForeignKey('RefAgency', models.DO_NOTHING)
    data_year = models.SmallIntegerField()
    incident_number = models.CharField(max_length=15, blank=True, null=True)
    incident_date = models.DateTimeField(blank=True, null=True)
    source_flag = models.CharField(max_length=1)
    ddocname = models.CharField(max_length=100, blank=True, null=True)
    report_date = models.DateTimeField(blank=True, null=True)
    prepared_date = models.DateTimeField(blank=True, null=True)
    report_date_flag = models.CharField(max_length=1, blank=True, null=True)
    incident_hour = models.SmallIntegerField(blank=True, null=True)
    cleared_except_flag = models.CharField(max_length=1, blank=True, null=True)
    update_flag = models.CharField(max_length=1, blank=True, null=True)
    ct_month = models.ForeignKey('CtMonth', models.DO_NOTHING)
    ff_line_number = models.BigIntegerField(blank=True, null=True)
    data_home = models.CharField(max_length=1)
    orig_format = models.CharField(max_length=1, blank=True, null=True)
    unknown_offender = models.CharField(max_length=1, blank=True, null=True)
    did = models.BigIntegerField(blank=True, null=True)
    nibrs_incident_id = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ct_incident'


class CtMonth(models.Model):
    ct_month_id = models.BigIntegerField(primary_key=True)
    agency = models.ForeignKey('RefAgency', models.DO_NOTHING)
    month_num = models.SmallIntegerField()
    data_year = models.SmallIntegerField()
    reported_status = models.CharField(max_length=1, blank=True, null=True)
    reported_count = models.IntegerField(blank=True, null=True)
    update_flag = models.CharField(max_length=1, blank=True, null=True)
    ff_line_number = models.BigIntegerField(blank=True, null=True)
    ddocname = models.CharField(max_length=100, blank=True, null=True)
    did = models.BigIntegerField(blank=True, null=True)
    data_home = models.CharField(max_length=1)
    orig_format = models.CharField(max_length=1, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ct_month'


class CtOffender(models.Model):
    offender_id = models.BigIntegerField(primary_key=True)
    incident = models.ForeignKey(CtIncident, models.DO_NOTHING)
    age = models.SmallIntegerField(blank=True, null=True)
    sex_code = models.CharField(max_length=1, blank=True, null=True)
    ethnicity = models.ForeignKey('NibrsEthnicity', models.DO_NOTHING, blank=True, null=True)
    race = models.ForeignKey('RefRace', models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ct_offender'


class CtOffense(models.Model):
    offense_id = models.BigIntegerField(primary_key=True)
    incident = models.ForeignKey(CtIncident, models.DO_NOTHING)
    offense_type = models.ForeignKey('NibrsOffenseType', models.DO_NOTHING)
    location = models.ForeignKey('NibrsLocationType', models.DO_NOTHING)
    ct_offense_flag = models.CharField(max_length=1, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ct_offense'


class CtProperty(models.Model):
    property_id = models.BigIntegerField(primary_key=True)
    prop_desc = models.ForeignKey('NibrsPropDescType', models.DO_NOTHING)
    incident = models.ForeignKey(CtIncident, models.DO_NOTHING)
    stolen_value = models.BigIntegerField(blank=True, null=True)
    recovered_flag = models.CharField(max_length=1, blank=True, null=True)
    date_recovered = models.DateTimeField(blank=True, null=True)
    recovered_value = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ct_property'


class CtVictim(models.Model):
    incident = models.ForeignKey(CtIncident, models.DO_NOTHING)
    victim_type = models.ForeignKey('NibrsVictimType', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'ct_victim'
        unique_together = (('incident', 'victim_type'),)


class CtWeapon(models.Model):
    incident = models.ForeignKey(CtIncident, models.DO_NOTHING)
    weapon = models.ForeignKey('NibrsWeaponType', models.DO_NOTHING)
    ct_weapon_id = models.BigIntegerField(primary_key=True)

    class Meta:
        managed = False
        db_table = 'ct_weapon'


class HcBiasMotivation(models.Model):
    offense = models.ForeignKey('HcOffense', models.DO_NOTHING)
    bias = models.ForeignKey('NibrsBiasList', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'hc_bias_motivation'
        unique_together = (('offense', 'bias'),)


class HcIncident(models.Model):
    incident_id = models.BigIntegerField(primary_key=True)
    agency = models.ForeignKey('RefAgency', models.DO_NOTHING)
    incident_no = models.CharField(max_length=20, blank=True, null=True)
    incident_date = models.DateTimeField(blank=True, null=True)
    data_home = models.CharField(max_length=1, blank=True, null=True)
    source_flag = models.CharField(max_length=1, blank=True, null=True)
    ddocname = models.CharField(max_length=100, blank=True, null=True)
    report_date = models.DateTimeField(blank=True, null=True)
    prepared_date = models.DateTimeField(blank=True, null=True)
    victim_count = models.SmallIntegerField(blank=True, null=True)
    adult_victim_count = models.SmallIntegerField(blank=True, null=True)
    incident_status = models.SmallIntegerField(blank=True, null=True)
    juvenile_victim_count = models.SmallIntegerField(blank=True, null=True)
    offender_count = models.SmallIntegerField(blank=True, null=True)
    adult_offender_count = models.SmallIntegerField(blank=True, null=True)
    juvenile_offender_count = models.SmallIntegerField(blank=True, null=True)
    offender_race = models.ForeignKey('RefRace', models.DO_NOTHING, blank=True, null=True)
    offender_ethnicity = models.ForeignKey('NibrsEthnicity', models.DO_NOTHING, blank=True, null=True)
    update_flag = models.CharField(max_length=1, blank=True, null=True)
    hc_quarter = models.ForeignKey('HcQuarter', models.DO_NOTHING)
    ff_line_number = models.BigIntegerField(blank=True, null=True)
    orig_format = models.CharField(max_length=1, blank=True, null=True)
    did = models.BigIntegerField(blank=True, null=True)
    nibrs_incident_id = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'hc_incident'


class HcOffense(models.Model):
    offense_id = models.BigIntegerField(primary_key=True)
    incident = models.ForeignKey(HcIncident, models.DO_NOTHING)
    offense_type = models.ForeignKey('NibrsOffenseType', models.DO_NOTHING, blank=True, null=True)
    victim_count = models.SmallIntegerField(blank=True, null=True)
    location = models.ForeignKey('NibrsLocationType', models.DO_NOTHING, blank=True, null=True)
    nibrs_offense_id = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'hc_offense'


class HcQuarter(models.Model):
    agency = models.ForeignKey('RefAgency', models.DO_NOTHING)
    quarter_num = models.SmallIntegerField()
    data_year = models.SmallIntegerField()
    reported_status = models.CharField(max_length=1, blank=True, null=True)
    reported_count = models.BigIntegerField(blank=True, null=True)
    hc_quarter_id = models.BigIntegerField(primary_key=True)
    update_flag = models.CharField(max_length=1, blank=True, null=True)
    orig_format = models.CharField(max_length=1, blank=True, null=True)
    ff_line_number = models.BigIntegerField(blank=True, null=True)
    ddocname = models.CharField(max_length=100, blank=True, null=True)
    did = models.BigIntegerField(blank=True, null=True)
    data_home = models.CharField(max_length=1)

    class Meta:
        managed = False
        db_table = 'hc_quarter'
        unique_together = (('agency', 'quarter_num', 'data_year', 'data_home'),)


class HcVictim(models.Model):
    offense = models.ForeignKey(HcOffense, models.DO_NOTHING)
    victim_type = models.ForeignKey('NibrsVictimType', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'hc_victim'
        unique_together = (('offense', 'victim_type'),)


class HtMonth(models.Model):
    ht_month_id = models.BigIntegerField(primary_key=True)
    agency = models.ForeignKey('RefAgency', models.DO_NOTHING)
    data_year = models.SmallIntegerField()
    month_num = models.SmallIntegerField()
    data_home = models.CharField(max_length=1)
    source_flag = models.CharField(max_length=1)
    ddocname = models.CharField(max_length=100, blank=True, null=True)
    report_date = models.DateTimeField(blank=True, null=True)
    prepared_date = models.DateTimeField(blank=True, null=True)
    prepared_by_user = models.CharField(max_length=100, blank=True, null=True)
    prepared_by_email = models.CharField(max_length=200, blank=True, null=True)
    orig_format = models.CharField(max_length=1)
    total_reported_count = models.IntegerField(blank=True, null=True)
    total_unfounded_count = models.IntegerField(blank=True, null=True)
    total_actual_count = models.IntegerField(blank=True, null=True)
    total_cleared_count = models.IntegerField(blank=True, null=True)
    total_juvenile_cleared_count = models.IntegerField(blank=True, null=True)
    update_flag = models.CharField(max_length=1, blank=True, null=True)
    reported_flag = models.CharField(max_length=1, blank=True, null=True)
    did = models.BigIntegerField(blank=True, null=True)
    ff_line_number = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ht_month'
        unique_together = (('agency', 'data_year', 'month_num', 'data_home'),)


class HtMonthOffenseSubcat(models.Model):
    ht_month = models.ForeignKey(HtMonth, models.DO_NOTHING)
    offense_subcat = models.ForeignKey('RetaOffenseSubcat', models.DO_NOTHING)
    reported_count = models.IntegerField(blank=True, null=True)
    reported_status = models.SmallIntegerField(blank=True, null=True)
    unfounded_count = models.IntegerField(blank=True, null=True)
    unfounded_status = models.SmallIntegerField(blank=True, null=True)
    actual_count = models.IntegerField(blank=True, null=True)
    actual_status = models.SmallIntegerField(blank=True, null=True)
    cleared_count = models.IntegerField(blank=True, null=True)
    cleared_status = models.SmallIntegerField(blank=True, null=True)
    juvenile_cleared_count = models.IntegerField(blank=True, null=True)
    juvenile_cleared_status = models.SmallIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ht_month_offense_subcat'
        unique_together = (('offense_subcat', 'ht_month'),)


class NibrsActivityType(models.Model):
    activity_type_id = models.SmallIntegerField(primary_key=True)
    activity_type_code = models.CharField(max_length=2, blank=True, null=True)
    activity_type_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_activity_type'


class NibrsAge(models.Model):
    age_id = models.SmallIntegerField(primary_key=True)
    age_code = models.CharField(max_length=2, blank=True, null=True)
    age_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_age'


class NibrsArrestType(models.Model):
    arrest_type_id = models.SmallIntegerField(primary_key=True)
    arrest_type_code = models.CharField(max_length=1, blank=True, null=True)
    arrest_type_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_arrest_type'


class NibrsArrestee(models.Model):
    arrestee_id = models.BigIntegerField(primary_key=True)
    incident = models.ForeignKey('NibrsIncident', models.DO_NOTHING)
    arrestee_seq_num = models.BigIntegerField(blank=True, null=True)
    arrest_num = models.CharField(max_length=12, blank=True, null=True)
    arrest_date = models.DateTimeField(blank=True, null=True)
    arrest_type = models.ForeignKey(NibrsArrestType, models.DO_NOTHING, blank=True, null=True)
    multiple_indicator = models.CharField(max_length=1, blank=True, null=True)
    offense_type = models.ForeignKey('NibrsOffenseType', models.DO_NOTHING)
    age = models.ForeignKey(NibrsAge, models.DO_NOTHING)
    age_num = models.SmallIntegerField(blank=True, null=True)
    sex_code = models.CharField(max_length=1, blank=True, null=True)
    race = models.ForeignKey('RefRace', models.DO_NOTHING)
    ethnicity = models.ForeignKey('NibrsEthnicity', models.DO_NOTHING, blank=True, null=True)
    resident_code = models.CharField(max_length=1, blank=True, null=True)
    under_18_disposition_code = models.CharField(max_length=1, blank=True, null=True)
    clearance_ind = models.CharField(max_length=1, blank=True, null=True)
    ff_line_number = models.BigIntegerField(blank=True, null=True)
    age_range_low_num = models.SmallIntegerField(blank=True, null=True)
    age_range_high_num = models.SmallIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_arrestee'


class NibrsArresteeWeapon(models.Model):
    arrestee = models.ForeignKey(NibrsArrestee, models.DO_NOTHING)
    weapon = models.ForeignKey('NibrsWeaponType', models.DO_NOTHING)
    nibrs_arrestee_weapon_id = models.BigIntegerField(primary_key=True)

    class Meta:
        managed = False
        db_table = 'nibrs_arrestee_weapon'


class NibrsAssignmentType(models.Model):
    assignment_type_id = models.SmallIntegerField(primary_key=True)
    assignment_type_code = models.CharField(max_length=1, blank=True, null=True)
    assignment_type_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_assignment_type'


class NibrsBiasList(models.Model):
    bias_id = models.SmallIntegerField(primary_key=True)
    bias_code = models.CharField(max_length=2, blank=True, null=True)
    bias_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_bias_list'


class NibrsBiasMotivation(models.Model):
    bias = models.ForeignKey(NibrsBiasList, models.DO_NOTHING)
    offense = models.ForeignKey('NibrsOffense', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'nibrs_bias_motivation'
        unique_together = (('bias', 'offense'),)


class NibrsCircumstances(models.Model):
    circumstances_id = models.SmallIntegerField(primary_key=True)
    circumstances_type = models.CharField(max_length=1, blank=True, null=True)
    circumstances_code = models.SmallIntegerField(blank=True, null=True)
    circumstances_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_circumstances'


class NibrsClearedExcept(models.Model):
    cleared_except_id = models.SmallIntegerField(primary_key=True)
    cleared_except_code = models.CharField(max_length=1, blank=True, null=True)
    cleared_except_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_cleared_except'


class NibrsCriminalAct(models.Model):
    criminal_act = models.ForeignKey('NibrsCriminalActType', models.DO_NOTHING)
    offense = models.ForeignKey('NibrsOffense', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'nibrs_criminal_act'
        unique_together = (('criminal_act', 'offense'),)


class NibrsCriminalActType(models.Model):
    criminal_act_id = models.SmallIntegerField(primary_key=True)
    criminal_act_code = models.CharField(max_length=1, blank=True, null=True)
    criminal_act_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_criminal_act_type'


class NibrsDrugMeasureType(models.Model):
    drug_measure_type_id = models.SmallIntegerField(primary_key=True)
    drug_measure_code = models.CharField(max_length=2, blank=True, null=True)
    drug_measure_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_drug_measure_type'


class NibrsEds(models.Model):
    ddocname = models.CharField(max_length=100, blank=True, null=True)
    data_year = models.SmallIntegerField(blank=True, null=True)
    month_num = models.SmallIntegerField(blank=True, null=True)
    relative_rec_num = models.IntegerField(blank=True, null=True)
    segment_action_type = models.CharField(max_length=1, blank=True, null=True)
    ori = models.CharField(max_length=9, blank=True, null=True)
    incident_num = models.CharField(max_length=12, blank=True, null=True)
    level = models.CharField(max_length=1, blank=True, null=True)
    offense_code = models.CharField(max_length=3, blank=True, null=True)
    person_seq_num = models.CharField(max_length=3, blank=True, null=True)
    type_prop_loss = models.CharField(max_length=1, blank=True, null=True)
    data_element_num = models.CharField(max_length=3, blank=True, null=True)
    error_num = models.SmallIntegerField(blank=True, null=True)
    data_field = models.CharField(max_length=12, blank=True, null=True)
    error_msg = models.CharField(max_length=79, blank=True, null=True)
    submission_ser_num = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_eds'


class NibrsEthnicity(models.Model):
    ethnicity_id = models.SmallIntegerField(primary_key=True)
    ethnicity_code = models.CharField(max_length=1, blank=True, null=True)
    ethnicity_name = models.CharField(max_length=100, blank=True, null=True)
    hc_flag = models.CharField(max_length=1, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_ethnicity'


class NibrsGrpbArrest(models.Model):
    grpb_arrest_id = models.BigIntegerField(primary_key=True)
    agency = models.ForeignKey('RefAgency', models.DO_NOTHING)
    arrest_num = models.CharField(max_length=15, blank=True, null=True)
    arrest_date = models.DateTimeField(blank=True, null=True)
    arrest_seq_num = models.SmallIntegerField(blank=True, null=True)
    city = models.CharField(max_length=4, blank=True, null=True)
    arrest_type_id = models.SmallIntegerField(blank=True, null=True)
    offense_type_id = models.BigIntegerField(blank=True, null=True)
    age = models.ForeignKey(NibrsAge, models.DO_NOTHING, blank=True, null=True)
    sex_code = models.CharField(max_length=1, blank=True, null=True)
    race = models.ForeignKey('RefRace', models.DO_NOTHING, blank=True, null=True)
    ethnicity = models.ForeignKey(NibrsEthnicity, models.DO_NOTHING, blank=True, null=True)
    resident_code = models.CharField(max_length=1, blank=True, null=True)
    under_18_disposition_code = models.CharField(max_length=1, blank=True, null=True)
    age_num = models.SmallIntegerField(blank=True, null=True)
    arrest_year = models.SmallIntegerField(blank=True, null=True)
    ff_line_number = models.BigIntegerField(blank=True, null=True)
    data_home = models.CharField(max_length=1, blank=True, null=True)
    ddocname = models.CharField(max_length=100, blank=True, null=True)
    did = models.BigIntegerField(blank=True, null=True)
    nibrs_month = models.ForeignKey('NibrsMonth', models.DO_NOTHING)
    age_range_low_num = models.SmallIntegerField(blank=True, null=True)
    age_range_high_num = models.SmallIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_grpb_arrest'


class NibrsGrpbArrestWeapon(models.Model):
    grpb_arrest = models.ForeignKey(NibrsGrpbArrest, models.DO_NOTHING)
    weapon = models.ForeignKey('NibrsWeaponType', models.DO_NOTHING)
    nibrs_grpb_arrest_weapon_id = models.BigIntegerField(primary_key=True)

    class Meta:
        managed = False
        db_table = 'nibrs_grpb_arrest_weapon'


class NibrsIncident(models.Model):
    agency = models.ForeignKey('RefAgency', models.DO_NOTHING)
    incident_id = models.BigIntegerField(primary_key=True)
    nibrs_month = models.ForeignKey('NibrsMonth', models.DO_NOTHING)
    incident_number = models.CharField(max_length=15, blank=True, null=True)
    cargo_theft_flag = models.CharField(max_length=1, blank=True, null=True)
    submission_date = models.DateTimeField(blank=True, null=True)
    incident_date = models.DateTimeField(blank=True, null=True)
    report_date_flag = models.CharField(max_length=1, blank=True, null=True)
    incident_hour = models.SmallIntegerField(blank=True, null=True)
    cleared_except = models.ForeignKey(NibrsClearedExcept, models.DO_NOTHING)
    cleared_except_date = models.DateTimeField(blank=True, null=True)
    incident_status = models.SmallIntegerField(blank=True, null=True)
    data_home = models.CharField(max_length=1, blank=True, null=True)
    ddocname = models.CharField(max_length=100, blank=True, null=True)
    orig_format = models.CharField(max_length=1, blank=True, null=True)
    ff_line_number = models.BigIntegerField(blank=True, null=True)
    did = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_incident'


class NibrsInjury(models.Model):
    injury_id = models.SmallIntegerField(primary_key=True)
    injury_code = models.CharField(max_length=1, blank=True, null=True)
    injury_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_injury'


class NibrsJustifiableForce(models.Model):
    justifiable_force_id = models.SmallIntegerField(primary_key=True)
    justifiable_force_code = models.CharField(max_length=1, blank=True, null=True)
    justifiable_force_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_justifiable_force'


class NibrsLocationType(models.Model):
    location_id = models.BigIntegerField(primary_key=True)
    location_code = models.CharField(max_length=2, blank=True, null=True)
    location_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_location_type'


class NibrsMonth(models.Model):
    nibrs_month_id = models.BigIntegerField(primary_key=True)
    agency = models.ForeignKey('RefAgency', models.DO_NOTHING)
    month_num = models.SmallIntegerField()
    data_year = models.SmallIntegerField()
    reported_status = models.CharField(max_length=1, blank=True, null=True)
    report_date = models.DateTimeField(blank=True, null=True)
    prepared_date = models.DateTimeField(blank=True, null=True)
    update_flag = models.CharField(max_length=1)
    orig_format = models.CharField(max_length=1)
    ff_line_number = models.BigIntegerField(blank=True, null=True)
    data_home = models.CharField(max_length=1, blank=True, null=True)
    ddocname = models.CharField(max_length=50, blank=True, null=True)
    did = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_month'
        unique_together = (('agency', 'month_num', 'data_year', 'data_home'),)


class NibrsOffender(models.Model):
    offender_id = models.BigIntegerField(primary_key=True)
    incident = models.ForeignKey(NibrsIncident, models.DO_NOTHING)
    offender_seq_num = models.SmallIntegerField(blank=True, null=True)
    age = models.ForeignKey(NibrsAge, models.DO_NOTHING, blank=True, null=True)
    age_num = models.SmallIntegerField(blank=True, null=True)
    sex_code = models.CharField(max_length=1, blank=True, null=True)
    race = models.ForeignKey('RefRace', models.DO_NOTHING, blank=True, null=True)
    ethnicity = models.ForeignKey(NibrsEthnicity, models.DO_NOTHING, blank=True, null=True)
    ff_line_number = models.BigIntegerField(blank=True, null=True)
    age_range_low_num = models.SmallIntegerField(blank=True, null=True)
    age_range_high_num = models.SmallIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_offender'


class NibrsOffense(models.Model):
    offense_id = models.BigIntegerField(primary_key=True)
    incident = models.ForeignKey(NibrsIncident, models.DO_NOTHING)
    offense_type = models.ForeignKey('NibrsOffenseType', models.DO_NOTHING)
    attempt_complete_flag = models.CharField(max_length=1, blank=True, null=True)
    location = models.ForeignKey(NibrsLocationType, models.DO_NOTHING)
    num_premises_entered = models.SmallIntegerField(blank=True, null=True)
    method_entry_code = models.CharField(max_length=1, blank=True, null=True)
    ff_line_number = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_offense'


class NibrsOffenseType(models.Model):
    offense_type_id = models.BigIntegerField(primary_key=True)
    offense_code = models.CharField(max_length=5, blank=True, null=True)
    offense_name = models.CharField(max_length=100, blank=True, null=True)
    crime_against = models.CharField(max_length=100, blank=True, null=True)
    ct_flag = models.CharField(max_length=1, blank=True, null=True)
    hc_flag = models.CharField(max_length=1, blank=True, null=True)
    hc_code = models.CharField(max_length=5, blank=True, null=True)
    offense_category_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_offense_type'


class NibrsPropDescType(models.Model):
    prop_desc_id = models.SmallIntegerField(primary_key=True)
    prop_desc_code = models.CharField(max_length=2, blank=True, null=True)
    prop_desc_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_prop_desc_type'


class NibrsPropLossType(models.Model):
    prop_loss_id = models.SmallIntegerField(primary_key=True)
    prop_loss_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_prop_loss_type'


class NibrsProperty(models.Model):
    property_id = models.BigIntegerField(primary_key=True)
    incident = models.ForeignKey(NibrsIncident, models.DO_NOTHING)
    prop_loss = models.ForeignKey(NibrsPropLossType, models.DO_NOTHING)
    stolen_count = models.SmallIntegerField(blank=True, null=True)
    recovered_count = models.SmallIntegerField(blank=True, null=True)
    ff_line_number = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_property'


class NibrsPropertyDesc(models.Model):
    property = models.ForeignKey(NibrsProperty, models.DO_NOTHING)
    prop_desc = models.ForeignKey(NibrsPropDescType, models.DO_NOTHING)
    property_value = models.BigIntegerField(blank=True, null=True)
    date_recovered = models.DateTimeField(blank=True, null=True)
    nibrs_prop_desc_id = models.BigIntegerField(primary_key=True)

    class Meta:
        managed = False
        db_table = 'nibrs_property_desc'


class NibrsRelationship(models.Model):
    relationship_id = models.SmallIntegerField(primary_key=True)
    relationship_code = models.CharField(max_length=2, blank=True, null=True)
    relationship_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_relationship'


class NibrsSumMonthTemp(models.Model):
    nibrs_month_id = models.BigIntegerField(blank=True, null=True)
    agency_id = models.BigIntegerField(blank=True, null=True)
    month_num = models.SmallIntegerField(blank=True, null=True)
    data_year = models.SmallIntegerField(blank=True, null=True)
    reported_status = models.CharField(max_length=1, blank=True, null=True)
    report_date = models.DateTimeField(blank=True, null=True)
    prepared_date = models.DateTimeField(blank=True, null=True)
    orig_format = models.CharField(max_length=1, blank=True, null=True)
    ff_line_number = models.BigIntegerField(blank=True, null=True)
    data_home = models.CharField(max_length=1, blank=True, null=True)
    ddocname = models.CharField(max_length=50, blank=True, null=True)
    did = models.BigIntegerField(blank=True, null=True)
    nibrs_ct_flag = models.CharField(max_length=1, blank=True, null=True)
    nibrs_hc_flag = models.CharField(max_length=1, blank=True, null=True)
    nibrs_leoka_flag = models.CharField(max_length=1, blank=True, null=True)
    nibrs_arson_flag = models.CharField(max_length=1, blank=True, null=True)
    nibrs_ht_flag = models.CharField(max_length=1, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_sum_month_temp'


class NibrsSuspectUsing(models.Model):
    suspect_using = models.ForeignKey('NibrsUsingList', models.DO_NOTHING)
    offense = models.ForeignKey(NibrsOffense, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'nibrs_suspect_using'
        unique_together = (('suspect_using', 'offense'),)


class NibrsSuspectedDrug(models.Model):
    suspected_drug_type = models.ForeignKey('NibrsSuspectedDrugType', models.DO_NOTHING)
    property = models.ForeignKey(NibrsProperty, models.DO_NOTHING)
    est_drug_qty = models.FloatField(blank=True, null=True)
    drug_measure_type = models.ForeignKey(NibrsDrugMeasureType, models.DO_NOTHING, blank=True, null=True)
    nibrs_suspected_drug_id = models.BigIntegerField(primary_key=True)

    class Meta:
        managed = False
        db_table = 'nibrs_suspected_drug'


class NibrsSuspectedDrugType(models.Model):
    suspected_drug_type_id = models.SmallIntegerField(primary_key=True)
    suspected_drug_code = models.CharField(max_length=1, blank=True, null=True)
    suspected_drug_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_suspected_drug_type'


class NibrsUsingList(models.Model):
    suspect_using_id = models.SmallIntegerField(primary_key=True)
    suspect_using_code = models.CharField(max_length=1, blank=True, null=True)
    suspect_using_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_using_list'


class NibrsVictim(models.Model):
    victim_id = models.BigIntegerField(primary_key=True)
    incident = models.ForeignKey(NibrsIncident, models.DO_NOTHING)
    victim_seq_num = models.SmallIntegerField(blank=True, null=True)
    victim_type = models.ForeignKey('NibrsVictimType', models.DO_NOTHING)
    assignment_type = models.ForeignKey(NibrsAssignmentType, models.DO_NOTHING, blank=True, null=True)
    activity_type = models.ForeignKey(NibrsActivityType, models.DO_NOTHING, blank=True, null=True)
    outside_agency_id = models.BigIntegerField(blank=True, null=True)
    age = models.ForeignKey(NibrsAge, models.DO_NOTHING, blank=True, null=True)
    age_num = models.SmallIntegerField(blank=True, null=True)
    sex_code = models.CharField(max_length=1, blank=True, null=True)
    race = models.ForeignKey('RefRace', models.DO_NOTHING, blank=True, null=True)
    ethnicity = models.ForeignKey(NibrsEthnicity, models.DO_NOTHING, blank=True, null=True)
    resident_status_code = models.CharField(max_length=1, blank=True, null=True)
    agency_data_year = models.SmallIntegerField(blank=True, null=True)
    ff_line_number = models.BigIntegerField(blank=True, null=True)
    age_range_low_num = models.SmallIntegerField(blank=True, null=True)
    age_range_high_num = models.SmallIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_victim'


class NibrsVictimCircumstances(models.Model):
    victim = models.ForeignKey(NibrsVictim, models.DO_NOTHING)
    circumstances = models.ForeignKey(NibrsCircumstances, models.DO_NOTHING)
    justifiable_force = models.ForeignKey(NibrsJustifiableForce, models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_victim_circumstances'
        unique_together = (('victim', 'circumstances'),)


class NibrsVictimInjury(models.Model):
    victim = models.ForeignKey(NibrsVictim, models.DO_NOTHING)
    injury = models.ForeignKey(NibrsInjury, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'nibrs_victim_injury'
        unique_together = (('victim', 'injury'),)


class NibrsVictimOffenderRel(models.Model):
    victim = models.ForeignKey(NibrsVictim, models.DO_NOTHING)
    offender = models.ForeignKey(NibrsOffender, models.DO_NOTHING)
    relationship = models.ForeignKey(NibrsRelationship, models.DO_NOTHING)
    nibrs_victim_offender_id = models.BigIntegerField(primary_key=True)

    class Meta:
        managed = False
        db_table = 'nibrs_victim_offender_rel'


class NibrsVictimOffense(models.Model):
    victim = models.ForeignKey(NibrsVictim, models.DO_NOTHING)
    offense = models.ForeignKey(NibrsOffense, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'nibrs_victim_offense'
        unique_together = (('victim', 'offense'),)


class NibrsVictimType(models.Model):
    victim_type_id = models.SmallIntegerField(primary_key=True)
    victim_type_code = models.CharField(max_length=1, blank=True, null=True)
    victim_type_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_victim_type'


class NibrsWeapon(models.Model):
    weapon = models.ForeignKey('NibrsWeaponType', models.DO_NOTHING)
    offense = models.ForeignKey(NibrsOffense, models.DO_NOTHING)
    nibrs_weapon_id = models.BigIntegerField(primary_key=True)

    class Meta:
        managed = False
        db_table = 'nibrs_weapon'


class NibrsWeaponType(models.Model):
    weapon_id = models.SmallIntegerField(primary_key=True)
    weapon_code = models.CharField(max_length=3, blank=True, null=True)
    weapon_name = models.CharField(max_length=100, blank=True, null=True)
    shr_flag = models.CharField(max_length=1, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'nibrs_weapon_type'


class OffenseClassification(models.Model):
    classification_id = models.SmallIntegerField(primary_key=True)
    classification_name = models.CharField(max_length=50, blank=True, null=True)
    class_sort_order = models.SmallIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'offense_classification'


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


class RetaMonth(models.Model):
    reta_month_id = models.BigIntegerField(primary_key=True)
    agency = models.ForeignKey(RefAgency, models.DO_NOTHING)
    data_year = models.SmallIntegerField()
    month_num = models.SmallIntegerField()
    data_home = models.CharField(max_length=1)
    source_flag = models.CharField(max_length=1)
    reported_flag = models.CharField(max_length=1)
    ddocname = models.CharField(max_length=100, blank=True, null=True)
    month_included_in = models.SmallIntegerField(blank=True, null=True)
    report_date = models.DateTimeField(blank=True, null=True)
    prepared_date = models.DateTimeField(blank=True, null=True)
    prepared_by_user = models.CharField(max_length=100, blank=True, null=True)
    prepared_by_email = models.CharField(max_length=200, blank=True, null=True)
    orig_format = models.CharField(max_length=1)
    total_reported_count = models.IntegerField(blank=True, null=True)
    total_unfounded_count = models.IntegerField(blank=True, null=True)
    total_actual_count = models.IntegerField(blank=True, null=True)
    total_cleared_count = models.IntegerField(blank=True, null=True)
    total_juvenile_cleared_count = models.IntegerField(blank=True, null=True)
    leoka_felony = models.SmallIntegerField(blank=True, null=True)
    leoka_accident = models.SmallIntegerField(blank=True, null=True)
    leoka_assault = models.IntegerField(blank=True, null=True)
    leoka_status = models.SmallIntegerField(blank=True, null=True)
    update_flag = models.CharField(max_length=1, blank=True, null=True)
    did = models.BigIntegerField(blank=True, null=True)
    ff_line_number = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'reta_month'
        unique_together = (('agency', 'data_year', 'month_num', 'data_home', 'source_flag'),)


class RetaMonthOffenseSubcat(models.Model):
    reta_month = models.ForeignKey(RetaMonth, models.DO_NOTHING)
    offense_subcat = models.ForeignKey('RetaOffenseSubcat', models.DO_NOTHING)
    reported_count = models.IntegerField(blank=True, null=True)
    reported_status = models.SmallIntegerField(blank=True, null=True)
    unfounded_count = models.IntegerField(blank=True, null=True)
    unfounded_status = models.SmallIntegerField(blank=True, null=True)
    actual_count = models.IntegerField(blank=True, null=True)
    actual_status = models.SmallIntegerField(blank=True, null=True)
    cleared_count = models.IntegerField(blank=True, null=True)
    cleared_status = models.SmallIntegerField(blank=True, null=True)
    juvenile_cleared_count = models.IntegerField(blank=True, null=True)
    juvenile_cleared_status = models.SmallIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'reta_month_offense_subcat'
        unique_together = (('offense_subcat', 'reta_month'),)


class RetaOffense(models.Model):
    offense_id = models.BigIntegerField(primary_key=True)
    offense_name = models.CharField(max_length=100)
    offense_code = models.CharField(unique=True, max_length=20)
    offense_xml_path = models.CharField(max_length=1000, blank=True, null=True)
    offense_category = models.ForeignKey('RetaOffenseCategory', models.DO_NOTHING)
    classification = models.ForeignKey(OffenseClassification, models.DO_NOTHING, blank=True, null=True)
    offense_sort_order = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'reta_offense'


class RetaOffenseCategory(models.Model):
    offense_category_id = models.SmallIntegerField(primary_key=True)
    crime_type = models.ForeignKey(CrimeType, models.DO_NOTHING)
    offense_category_name = models.CharField(max_length=50, blank=True, null=True)
    offense_category_sort_order = models.SmallIntegerField()

    class Meta:
        managed = False
        db_table = 'reta_offense_category'


class RetaOffenseSubcat(models.Model):
    offense_subcat_id = models.BigIntegerField(primary_key=True)
    offense = models.ForeignKey(RetaOffense, models.DO_NOTHING)
    offense_subcat_name = models.CharField(max_length=100)
    offense_subcat_code = models.CharField(unique=True, max_length=20)
    offense_subcat_xml_path = models.CharField(max_length=1000, blank=True, null=True)
    offense_subcat_sort_order = models.BigIntegerField(blank=True, null=True)
    part = models.CharField(max_length=1, blank=True, null=True)
    crime_index_flag = models.CharField(max_length=1, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'reta_offense_subcat'


class ShrCircumstances(models.Model):
    circumstances_id = models.SmallIntegerField(primary_key=True)
    circumstances_code = models.CharField(max_length=2)
    sub_code = models.CharField(max_length=1, blank=True, null=True)
    circumstances_name = models.CharField(max_length=100)
    sub_name = models.CharField(max_length=100, blank=True, null=True)
    current_flag = models.CharField(max_length=1, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'shr_circumstances'


class ShrIncident(models.Model):
    incident_id = models.BigIntegerField(primary_key=True)
    shr_month = models.ForeignKey('ShrMonth', models.DO_NOTHING)
    homicide_code = models.CharField(max_length=1, blank=True, null=True)
    situation = models.ForeignKey('ShrSituation', models.DO_NOTHING)
    incident_num = models.CharField(max_length=3, blank=True, null=True)
    incident_status = models.SmallIntegerField(blank=True, null=True)
    update_flag = models.CharField(max_length=1, blank=True, null=True)
    data_home = models.CharField(max_length=1, blank=True, null=True)
    prepared_date = models.DateTimeField(blank=True, null=True)
    report_date = models.DateTimeField(blank=True, null=True)
    ddocname = models.CharField(max_length=100, blank=True, null=True)
    ff_line_number = models.BigIntegerField(blank=True, null=True)
    orig_format = models.CharField(max_length=1, blank=True, null=True)
    did = models.BigIntegerField(blank=True, null=True)
    nibrs_incident_id = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'shr_incident'
        unique_together = (('shr_month', 'incident_num', 'data_home'),)


class ShrMonth(models.Model):
    shr_month_id = models.BigIntegerField(primary_key=True)
    agency = models.ForeignKey(RefAgency, models.DO_NOTHING)
    data_year = models.SmallIntegerField()
    month_num = models.SmallIntegerField()
    data_home = models.CharField(max_length=1)
    source_flag = models.CharField(max_length=1, blank=True, null=True)
    reported_flag = models.CharField(max_length=1, blank=True, null=True)
    orig_format = models.CharField(max_length=1, blank=True, null=True)
    update_flag = models.CharField(max_length=1, blank=True, null=True)
    ff_line_number = models.BigIntegerField(blank=True, null=True)
    ddocname = models.CharField(max_length=100, blank=True, null=True)
    did = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'shr_month'
        unique_together = (('agency', 'data_year', 'month_num', 'data_home'),)


class ShrOffender(models.Model):
    offender_id = models.BigIntegerField(primary_key=True)
    offender_num = models.CharField(max_length=20, blank=True, null=True)
    age = models.ForeignKey(NibrsAge, models.DO_NOTHING, blank=True, null=True)
    age_num = models.SmallIntegerField(blank=True, null=True)
    sex_code = models.CharField(max_length=1, blank=True, null=True)
    race = models.ForeignKey(RefRace, models.DO_NOTHING, blank=True, null=True)
    ethnicity = models.ForeignKey(NibrsEthnicity, models.DO_NOTHING, blank=True, null=True)
    nibrs_offense_id = models.BigIntegerField(blank=True, null=True)
    nibrs_offender_id = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'shr_offender'


class ShrOffense(models.Model):
    offense_id = models.BigIntegerField(primary_key=True)
    incident = models.ForeignKey(ShrIncident, models.DO_NOTHING)
    weapon = models.ForeignKey(NibrsWeaponType, models.DO_NOTHING, blank=True, null=True)
    relationship = models.ForeignKey('ShrRelationship', models.DO_NOTHING, blank=True, null=True)
    circumstances = models.ForeignKey(ShrCircumstances, models.DO_NOTHING, blank=True, null=True)
    victim = models.ForeignKey('ShrVictim', models.DO_NOTHING)
    offender = models.ForeignKey(ShrOffender, models.DO_NOTHING)
    nibrs_offense_id = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'shr_offense'


class ShrRelationship(models.Model):
    relationship_id = models.SmallIntegerField(primary_key=True)
    relationship_code = models.CharField(max_length=2, blank=True, null=True)
    relationship_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'shr_relationship'


class ShrSituation(models.Model):
    situation_id = models.SmallIntegerField(primary_key=True)
    situation_code = models.CharField(max_length=1, blank=True, null=True)
    situation_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'shr_situation'


class ShrVictim(models.Model):
    victim_id = models.BigIntegerField(primary_key=True)
    victim_num = models.CharField(max_length=20, blank=True, null=True)
    age = models.ForeignKey(NibrsAge, models.DO_NOTHING, blank=True, null=True)
    age_num = models.SmallIntegerField(blank=True, null=True)
    sex_code = models.CharField(max_length=1, blank=True, null=True)
    race = models.ForeignKey(RefRace, models.DO_NOTHING, blank=True, null=True)
    ethnicity = models.ForeignKey(NibrsEthnicity, models.DO_NOTHING, blank=True, null=True)
    nibrs_victim_id = models.BigIntegerField(blank=True, null=True)
    nibrs_offense_id = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'shr_victim'


class SuppLarcenyType(models.Model):
    larceny_type_id = models.BigIntegerField(primary_key=True)
    larceny_type_name = models.CharField(max_length=100)
    larceny_type_code = models.CharField(max_length=20)
    larceny_xml_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'supp_larceny_type'


class SuppMonth(models.Model):
    supp_month_id = models.BigIntegerField(primary_key=True)
    agency = models.ForeignKey(RefAgency, models.DO_NOTHING)
    data_year = models.SmallIntegerField()
    month_num = models.SmallIntegerField()
    data_home = models.CharField(max_length=1)
    source_flag = models.CharField(max_length=1, blank=True, null=True)
    reported_flag = models.CharField(max_length=1)
    report_date = models.DateTimeField(blank=True, null=True)
    prepared_date = models.DateTimeField(blank=True, null=True)
    ddocname = models.CharField(max_length=100, blank=True, null=True)
    orig_format = models.CharField(max_length=1)
    mv_stolen_local_rec_local = models.BigIntegerField(blank=True, null=True)
    mv_stolen_local_rec_other = models.BigIntegerField(blank=True, null=True)
    mv_tot_local_stolen_rec = models.BigIntegerField(blank=True, null=True)
    mv_stolen_other_rec_local = models.BigIntegerField(blank=True, null=True)
    mv_stolen_status = models.SmallIntegerField(blank=True, null=True)
    update_flag = models.CharField(max_length=1, blank=True, null=True)
    did = models.BigIntegerField(blank=True, null=True)
    ff_line_number = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'supp_month'
        unique_together = (('agency', 'data_year', 'month_num', 'data_home'),)


class SuppOffense(models.Model):
    offense_id = models.BigIntegerField(primary_key=True)
    offense_name = models.CharField(max_length=100)
    offense_code = models.CharField(max_length=20)

    class Meta:
        managed = False
        db_table = 'supp_offense'


class SuppOffenseSubcat(models.Model):
    offense_subcat_id = models.BigIntegerField(primary_key=True)
    offense = models.ForeignKey(SuppOffense, models.DO_NOTHING)
    offense_subcat_name = models.CharField(max_length=100)
    offense_subcat_code = models.CharField(max_length=20)
    offense_subcat_xml_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'supp_offense_subcat'


class SuppPropByOffenseSubcat(models.Model):
    supp_month = models.ForeignKey(SuppMonth, models.DO_NOTHING)
    offense_subcat = models.ForeignKey(SuppOffenseSubcat, models.DO_NOTHING)
    actual_count = models.IntegerField(blank=True, null=True)
    actual_status = models.SmallIntegerField(blank=True, null=True)
    stolen_value = models.BigIntegerField(blank=True, null=True)
    stolen_value_status = models.SmallIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'supp_prop_by_offense_subcat'
        unique_together = (('supp_month', 'offense_subcat'),)


class SuppPropertyByTypeValue(models.Model):
    supp_month = models.ForeignKey(SuppMonth, models.DO_NOTHING)
    prop_type = models.ForeignKey('SuppPropertyType', models.DO_NOTHING)
    stolen_value = models.BigIntegerField(blank=True, null=True)
    stolen_value_status = models.SmallIntegerField(blank=True, null=True)
    recovered_value = models.BigIntegerField(blank=True, null=True)
    recovered_value_status = models.SmallIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'supp_property_by_type_value'
        unique_together = (('prop_type', 'supp_month'),)


class SuppPropertyType(models.Model):
    prop_type_id = models.BigIntegerField(primary_key=True)
    prop_type_name = models.CharField(max_length=100)
    prop_type_code = models.CharField(max_length=20)
    prop_type_code_num = models.SmallIntegerField()

    class Meta:
        managed = False
        db_table = 'supp_property_type'

# Not Auto-generated - Summary data models

class State(models.Model):
    name = models.CharField(max_length=128, null=True)

class County(models.Model):
    name = models.CharField(max_length=128, null=True)

class OffenseClass(models.Model):
    name = models.CharField(max_length=128, null=True)
    description = models.TextField(blank=True)

class OffenseType(models.Model):
    name = models.CharField(max_length=128, null=True)
    offense_class = models.ForeignKey(OffenseClass)
    description = models.TextField(blank=True)

class CrimeCount(models.Model):
    offense_type = models.ForeignKey(OffenseType, on_delete=models.CASCADE)
    count = models.IntegerField(default=0)

class CrimeStateYearly(models.Model):
    '''''
    Yearly Sums -> State Level.
    '''''
    year  = models.DateField()
    state = models.ForeignKey(State, on_delete=models.CASCADE)
    count = models.ForeignKey(CrimeCount)
    class Meta:
        unique_together = (('year', 'state'))

class CrimeOriYearly(models.Model):
    '''''
    Yearly Sums -> Agency Level (NIBRS, and SRS)
    '''''
    year = models.DateField()
    agency_id = models.ForeignKey(RefAgency, on_delete=models.CASCADE)
    is_nibrs_summary = models.BooleanField(null=False)
    count = models.ForeignKey(CrimeCount)
    class Meta:
        unique_together = (('year', 'agency_id'))

