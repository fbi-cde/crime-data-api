from django.db import models
from ref.models import RefAgency

# Create your models here.
class HcBiasMotivation(models.Model):
    offense = models.ForeignKey('HcOffense', models.DO_NOTHING)
    bias = models.ForeignKey('nibrs.NibrsBiasList', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'hc_bias_motivation'
        unique_together = (('offense', 'bias'),)


class HcIncident(models.Model):
    incident_id = models.BigIntegerField(primary_key=True)
    agency = models.ForeignKey('ref.RefAgency', models.DO_NOTHING)
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
    offender_race = models.ForeignKey('ref.RefRace', models.DO_NOTHING, blank=True, null=True)
    offender_ethnicity = models.ForeignKey('nibrs.NibrsEthnicity', models.DO_NOTHING, blank=True, null=True)
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
    offense_type = models.ForeignKey('nibrs.NibrsOffenseType', models.DO_NOTHING, blank=True, null=True)
    victim_count = models.SmallIntegerField(blank=True, null=True)
    location = models.ForeignKey('nibrs.NibrsLocationType', models.DO_NOTHING, blank=True, null=True)
    nibrs_offense_id = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'hc_offense'


class HcQuarter(models.Model):
    agency = models.ForeignKey('ref.RefAgency', models.DO_NOTHING)
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
    victim_type = models.ForeignKey('nibrs.NibrsVictimType', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'hc_victim'
        unique_together = (('offense', 'victim_type'),)