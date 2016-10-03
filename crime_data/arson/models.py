from django.db import models
from ref.models import RefAgency

# Create your models here.
class ArsonMonth(models.Model):
    arson_month_id = models.BigIntegerField(primary_key=True)
    agency = models.ForeignKey('ref.RefAgency', models.DO_NOTHING)
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
        managed = True
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
        managed = True
        db_table = 'arson_month_by_subcat'
        unique_together = (('arson_month', 'subcategory'),)


class ArsonSubcategory(models.Model):
    subcategory_id = models.BigIntegerField(primary_key=True)
    subcategory_name = models.CharField(max_length=100, blank=True, null=True)
    subcategory_code = models.CharField(unique=True, max_length=20, blank=True, null=True)
    subclass = models.ForeignKey('ArsonSubclassification', models.DO_NOTHING)
    subcat_xml_path = models.CharField(max_length=4000, blank=True, null=True)

    class Meta:
        managed = True
        db_table = 'arson_subcategory'


class ArsonSubclassification(models.Model):
    subclass_id = models.SmallIntegerField(primary_key=True)
    subclass_name = models.CharField(max_length=100, blank=True, null=True)
    subclass_code = models.CharField(unique=True, max_length=20, blank=True, null=True)
    subclass_xml_path = models.CharField(max_length=4000, blank=True, null=True)

    class Meta:
        managed = True
        db_table = 'arson_subclassification'