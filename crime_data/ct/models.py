from django.db import models
from ref.models import RefAgency
from nibrs.models import NibrsAge, NibrsEthnicity, NibrsWeaponType

# Create your models here.
class CtArrestee(models.Model):
    arrestee_id = models.BigIntegerField(primary_key=True)
    incident = models.ForeignKey('CtIncident', models.DO_NOTHING)
    age = models.SmallIntegerField(blank=True, null=True)
    sex_code = models.CharField(max_length=1, blank=True, null=True)
    ethnicity = models.ForeignKey('nibrs.NibrsEthnicity', models.DO_NOTHING, blank=True, null=True)
    race = models.ForeignKey('ref.RefRace', models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ct_arrestee'


class CtIncident(models.Model):
    incident_id = models.BigIntegerField(primary_key=True)
    agency = models.ForeignKey('ref.RefAgency', models.DO_NOTHING)
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
    agency = models.ForeignKey('ref.RefAgency', models.DO_NOTHING)
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
    ethnicity = models.ForeignKey('nibrs.NibrsEthnicity', models.DO_NOTHING, blank=True, null=True)
    race = models.ForeignKey('ref.RefRace', models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ct_offender'


class CtOffense(models.Model):
    offense_id = models.BigIntegerField(primary_key=True)
    incident = models.ForeignKey(CtIncident, models.DO_NOTHING)
    offense_type = models.ForeignKey('nibrs.NibrsOffenseType', models.DO_NOTHING)
    location = models.ForeignKey('nibrs.NibrsLocationType', models.DO_NOTHING)
    ct_offense_flag = models.CharField(max_length=1, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'ct_offense'


class CtProperty(models.Model):
    property_id = models.BigIntegerField(primary_key=True)
    prop_desc = models.ForeignKey('nibrs.NibrsPropDescType', models.DO_NOTHING)
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
    victim_type = models.ForeignKey('nibrs.NibrsVictimType', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'ct_victim'
        unique_together = (('incident', 'victim_type'),)


class CtWeapon(models.Model):
    incident = models.ForeignKey(CtIncident, models.DO_NOTHING)
    weapon = models.ForeignKey('nibrs.NibrsWeaponType', models.DO_NOTHING)
    ct_weapon_id = models.BigIntegerField(primary_key=True)

    class Meta:
        managed = False
        db_table = 'ct_weapon'