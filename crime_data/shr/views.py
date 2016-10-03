from django.shortcuts import render

# Create your views here.
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
#         db_table = 'shr_victim'