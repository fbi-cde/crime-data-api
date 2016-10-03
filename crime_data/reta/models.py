from django.db import models
from ref.models import RefAgency, OffenseClassification, CrimeType

# Create your models here.
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