from django.db import models
from ref.models import RefAgency

# Create your models here.
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
    race = models.ForeignKey('ref.RefRace', models.DO_NOTHING)
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
    agency = models.ForeignKey('ref.RefAgency', models.DO_NOTHING)
    arrest_num = models.CharField(max_length=15, blank=True, null=True)
    arrest_date = models.DateTimeField(blank=True, null=True)
    arrest_seq_num = models.SmallIntegerField(blank=True, null=True)
    city = models.CharField(max_length=4, blank=True, null=True)
    arrest_type_id = models.SmallIntegerField(blank=True, null=True)
    offense_type_id = models.BigIntegerField(blank=True, null=True)
    age = models.ForeignKey(NibrsAge, models.DO_NOTHING, blank=True, null=True)
    sex_code = models.CharField(max_length=1, blank=True, null=True)
    race = models.ForeignKey('ref.RefRace', models.DO_NOTHING, blank=True, null=True)
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
    agency = models.ForeignKey('ref.RefAgency', models.DO_NOTHING)
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
    agency = models.ForeignKey('ref.RefAgency', models.DO_NOTHING)
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
    race = models.ForeignKey('ref.RefRace', models.DO_NOTHING, blank=True, null=True)
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
    race = models.ForeignKey('ref.RefRace', models.DO_NOTHING, blank=True, null=True)
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