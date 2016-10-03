from django.db import models
from ref.models import RefAgency

# Create your models here.
class HtMonth(models.Model):
    ht_month_id = models.BigIntegerField(primary_key=True)
    agency = models.ForeignKey('ref.RefAgency', models.DO_NOTHING)
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
    offense_subcat = models.ForeignKey('reta.RetaOffenseSubcat', models.DO_NOTHING)
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