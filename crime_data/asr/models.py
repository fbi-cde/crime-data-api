from django.db import models
from ref.models import RefAgency

# Create your models here.
class AsrAgeRange(models.Model):
    age_range_id = models.BigIntegerField(primary_key=True)
    age_range_name = models.CharField(max_length=20, blank=True, null=True)
    age_range_code = models.CharField(unique=True, max_length=20, blank=True, null=True)
    juvenile_flag = models.CharField(max_length=1)
    ff_sort_order = models.CharField(max_length=3, blank=True, null=True)
    age_sex = models.CharField(max_length=1, blank=True, null=True)
    xml_code = models.CharField(max_length=2001, blank=True, null=True)

    class Meta:
        managed = True
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
        managed = True
        db_table = 'asr_age_sex_subcat'
        unique_together = (('asr_month', 'offense_subcat', 'age_range'),)


class AsrEthnicity(models.Model):
    ethnicity_id = models.BigIntegerField(primary_key=True)
    ethnicity_name = models.CharField(max_length=100, blank=True, null=True)
    ethnicity_code = models.CharField(unique=True, max_length=20, blank=True, null=True)
    ff_sort_order = models.CharField(max_length=3, blank=True, null=True)

    class Meta:
        managed = True
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
        managed = True
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
        managed = True
        db_table = 'asr_juvenile_disposition'


class AsrMonth(models.Model):
    asr_month_id = models.BigIntegerField(primary_key=True)
    agency = models.ForeignKey('ref.RefAgency', models.DO_NOTHING)
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
        managed = True
        db_table = 'asr_month'
        unique_together = (('agency', 'data_year', 'month_num', 'data_home'),)


class AsrOffense(models.Model):
    offense_id = models.BigIntegerField(primary_key=True)
    offense_cat = models.ForeignKey('AsrOffenseCategory', models.DO_NOTHING)
    offense_name = models.CharField(max_length=100, blank=True, null=True)
    offense_code = models.CharField(unique=True, max_length=20, blank=True, null=True)
    total_flag = models.CharField(max_length=1, blank=True, null=True)

    class Meta:
        managed = True
        db_table = 'asr_offense'


class AsrOffenseCategory(models.Model):
    offense_cat_id = models.BigIntegerField(primary_key=True)
    offense_cat_name = models.CharField(max_length=100, blank=True, null=True)
    offense_cat_code = models.CharField(unique=True, max_length=20, blank=True, null=True)

    class Meta:
        managed = True
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
        managed = True
        db_table = 'asr_offense_subcat'


class AsrRaceOffenseSubcat(models.Model):
    asr_month = models.ForeignKey(AsrMonth, models.DO_NOTHING)
    offense_subcat = models.ForeignKey(AsrOffenseSubcat, models.DO_NOTHING)
    race = models.ForeignKey('ref.RefRace', models.DO_NOTHING)
    juvenile_flag = models.CharField(max_length=1)
    arrest_count = models.IntegerField(blank=True, null=True)
    arrest_status = models.SmallIntegerField(blank=True, null=True)
    active_flag = models.CharField(max_length=1, blank=True, null=True)
    prepared_date = models.DateTimeField(blank=True, null=True)
    report_date = models.DateTimeField(blank=True, null=True)
    ff_line_number = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = True
        db_table = 'asr_race_offense_subcat'
        unique_together = (('asr_month', 'offense_subcat', 'race', 'juvenile_flag'),)
