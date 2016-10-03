from django.db import models
from ref.models import RefAgency


# Create your models here.
class SuppLarcenyType(models.Model):
    larceny_type_id = models.BigIntegerField(primary_key=True)
    larceny_type_name = models.CharField(max_length=100)
    larceny_type_code = models.CharField(max_length=20)
    larceny_xml_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = True
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
        managed = True
        db_table = 'supp_month'
        unique_together = (('agency', 'data_year', 'month_num', 'data_home'),)


class SuppOffense(models.Model):
    offense_id = models.BigIntegerField(primary_key=True)
    offense_name = models.CharField(max_length=100)
    offense_code = models.CharField(max_length=20)

    class Meta:
        managed = True
        db_table = 'supp_offense'


class SuppOffenseSubcat(models.Model):
    offense_subcat_id = models.BigIntegerField(primary_key=True)
    offense = models.ForeignKey(SuppOffense, models.DO_NOTHING)
    offense_subcat_name = models.CharField(max_length=100)
    offense_subcat_code = models.CharField(max_length=20)
    offense_subcat_xml_name = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = True
        db_table = 'supp_offense_subcat'


class SuppPropByOffenseSubcat(models.Model):
    supp_month = models.ForeignKey(SuppMonth, models.DO_NOTHING)
    offense_subcat = models.ForeignKey(SuppOffenseSubcat, models.DO_NOTHING)
    actual_count = models.IntegerField(blank=True, null=True)
    actual_status = models.SmallIntegerField(blank=True, null=True)
    stolen_value = models.BigIntegerField(blank=True, null=True)
    stolen_value_status = models.SmallIntegerField(blank=True, null=True)

    class Meta:
        managed = True
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
        managed = True
        db_table = 'supp_property_by_type_value'
        unique_together = (('prop_type', 'supp_month'),)


class SuppPropertyType(models.Model):
    prop_type_id = models.BigIntegerField(primary_key=True)
    prop_type_name = models.CharField(max_length=100)
    prop_type_code = models.CharField(max_length=20)
    prop_type_code_num = models.SmallIntegerField()

    class Meta:
        managed = True
        db_table = 'supp_property_type'