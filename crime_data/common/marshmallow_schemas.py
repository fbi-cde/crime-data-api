# coding: utf-8

import os

from flask_marshmallow import Marshmallow
from marshmallow import Schema, fields

from . import models

ma = Marshmallow()


# Schemas for request parsing
class ArgumentsSchema(Schema):
    page = fields.Integer(missing=1)
    per_page = fields.Integer(missing=10)
    fields = fields.String()
    if os.getenv('VCAP_APPLICATION'):
        api_key = fields.String(
            required=True,
            error_messages={'required': 'Get API key from Catherine'})


class IncidentArgsSchema(ArgumentsSchema):
    incident_hour = fields.Integer()
    crime_against = fields.String()
    offense_code = fields.String()
    offense_name = fields.String()
    offense_category_name = fields.String()
    method_entry_code = fields.String()
    location_code = fields.String()
    location_name = fields.String()


class IncidentCountArgsSchema(ArgumentsSchema):
    by = fields.String(missing='data_year')

# Schemas for data serialization
'''
    tables = [models.RetaMonth, CdeRefAgency, models.RefState, models.RetaMonthOffenseSubcat,
              models.RetaOffenseSubcat]

'''


class RefStateSchema(ma.ModelSchema):
    class Meta:
        model = models.RefState
        exclude = ('state_id', )


class RefAgencySchema(ma.ModelSchema):
    class Meta:
        model = models.RefAgency

    state = ma.Nested(RefStateSchema)


class RetaMonthSchema(ma.ModelSchema):
    class Meta:
        model = models.RetaMonth
        exclude = ('reta_month_id', )

    agency = ma.Nested(RefAgencySchema)


class RefRaceSchema(ma.ModelSchema):
    class Meta:
        model = models.RefRace
        exclude = ('race_id', 'arrestees', 'offenders', 'victims', )


class NibrsLocationTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsLocationType
        exclude = ('offenses', 'location_id')


class NibrsOffenseTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsOffenseType
        exclude = ('arrestees', 'offenses', 'offense_type_id', )


class NibrsOffenseSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsOffense
        exclude = ('incident', 'offense_id', )

    offense_type = ma.Nested(NibrsOffenseTypeSchema)
    location = ma.Nested(NibrsLocationTypeSchema)


class NibrsClearedExceptSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsClearedExcept
        exclude = ('cleared_except_id', )


class NibrsPropertySchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsProperty
        exclude = ('incident', 'property_id', )


class NibrsAgeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsAge
        exclude = ('age_id', 'arrestees', 'offenders', 'victims', )


class NibrsEthnicitySchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsEthnicity
        exclude = ('ethnicity_id', 'arrestees', 'offenders', 'victims', )


class NibrsVictimTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsVictimType
        exclude = ('victim_type_id', 'victims', )


class NibrsVictimSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsVictim
        exclude = ('victim_id', 'victim_seq_num', )

    ethnicity = ma.Nested(NibrsEthnicitySchema)
    race = ma.Nested(RefRaceSchema)
    victim_type = ma.Nested(NibrsVictimTypeSchema)
    age = ma.Nested(NibrsAgeSchema)


class NibrsArresteeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsArrestee
        exclude = ('arrestee_id',
                   'arrestee_seq_num',
                   'incident',
                   'offense_type', )

    ethnicity = ma.Nested(NibrsEthnicitySchema)
    race = ma.Nested(RefRaceSchema)
    age = ma.Nested(NibrsAgeSchema)


class NibrsOffenderSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsOffender
        exclude = ('offender_id', 'incident', 'offender_seq_num', )

    ethnicity = ma.Nested(NibrsEthnicitySchema)
    race = ma.Nested(RefRaceSchema)
    age = ma.Nested(NibrsAgeSchema)


class NibrsIncidentSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsIncident
        exclude = ('data_home',
                   'ddocname',
                   'nibrs_month',
                   'orig_format',
                   'incident_id', )

    offenses = ma.Nested(NibrsOffenseSchema, many=True)
    agency = ma.Nested(RefAgencySchema)
    cleared_except = ma.Nested(NibrsClearedExceptSchema)
    property = ma.Nested(NibrsPropertySchema, many=True)
    victims = ma.Nested(NibrsVictimSchema, many=True)
    arrestees = ma.Nested(NibrsArresteeSchema, many=True)
    offenders = ma.Nested(NibrsOffenderSchema, many=True)


"""
class ArsonMonth(db.Model):
    __tablename__ = 'arson_month'
    __table_args__ = (
        UniqueConstraint('agency_id', 'data_year', 'month_num', 'data_home'), )

    arson_month_id = db.Column(db.BigInteger, primary_key=True)
    data_year = db.Column(db.SmallInteger, nullable=False)
    month_num = db.Column(db.SmallInteger, nullable=False)
    data_home = db.Column(db.String(1), nullable=False)
    source_flag = db.Column(db.String(1), nullable=False)
    reported_flag = db.Column(db.String(1))
    ddocname = db.Column(db.String(100))
    month_included_in = db.Column(db.SmallInteger)
    report_date = db.Column(db.DateTime(True))
    prepared_date = db.Column(db.DateTime(True))
    orig_format = db.Column(db.String(1))
    update_flag = db.Column(db.String(1))
    did = db.Column(db.BigInteger)
    ff_line_number = db.Column(db.BigInteger)
    agency_id = db.Column(db.Integer,
                          db.ForeignKey('ref_agency.agency_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)

    agency = db.relationship('RefAgency')


class ArsonMonthBySubcat(db.Model):
    __tablename__ = 'arson_month_by_subcat'
    __table_args__ = (
        db.UniqueConstraint('arson_month_id', 'subcategory_id'), )

    id = db.Column(db.Integer,
                   primary_key=True,
                   server_default=text(
                       "nextval('arson_month_by_subcat_id_seq'::regclass)"))
    reported_count = db.Column(db.Integer)
    reported_status = db.Column(db.SmallInteger)
    unfounded_count = db.Column(db.Integer)
    unfounded_status = db.Column(db.SmallInteger)
    actual_count = db.Column(db.Integer)
    actual_status = db.Column(db.SmallInteger)
    cleared_count = db.Column(db.Integer)
    cleared_status = db.Column(db.SmallInteger)
    juvenile_cleared_count = db.Column(db.Integer)
    juvenile_cleared_status = db.Column(db.SmallInteger)
    uninhabited_count = db.Column(db.Integer)
    uninhabited_status = db.Column(db.SmallInteger)
    est_damage_value = db.Column(db.BigInteger)
    est_damage_value_status = db.Column(db.SmallInteger)
    arson_month_id = db.Column(db.Integer,
                               db.ForeignKey('arson_month.arson_month_id',
                                             deferrable=True,
                                             initially='DEFERRED'),
                               nullable=False,
                               index=True)
    subcategory_id = db.Column(db.Integer,
                               db.ForeignKey(
                                   'arson_subcategory.subcategory_id',
                                   deferrable=True,
                                   initially='DEFERRED'),
                               nullable=False,
                               index=True)

    arson_month = db.relationship('ArsonMonth')
    subcategory = db.relationship('ArsonSubcategory')


class ArsonSubcategory(db.Model):
    __tablename__ = 'arson_subcategory'

    subcategory_id = db.Column(db.BigInteger, primary_key=True)
    subcategory_name = db.Column(db.String(100))
    subcategory_code = db.Column(db.String(20), unique=True)
    subcat_xml_path = db.Column(db.String(4000))
    subclass_id = db.Column(db.Integer,
                            db.ForeignKey(
                                'arson_subclassification.subclass_id',
                                deferrable=True,
                                initially='DEFERRED'),
                            nullable=False,
                            index=True)

    subclass = db.relationship('ArsonSubclassification')


class ArsonSubclassification(db.Model):
    __tablename__ = 'arson_subclassification'

    subclass_id = db.Column(db.SmallInteger, primary_key=True)
    subclass_name = db.Column(db.String(100))
    subclass_code = db.Column(db.String(20), unique=True)
    subclass_xml_path = db.Column(db.String(4000))


class AsrAgeRange(db.Model):
    __tablename__ = 'asr_age_range'

    age_range_id = db.Column(db.BigInteger, primary_key=True)
    age_range_name = db.Column(db.String(20))
    age_range_code = db.Column(db.String(20), unique=True)
    juvenile_flag = db.Column(db.String(1), nullable=False)
    ff_sort_order = db.Column(db.String(3))
    age_sex = db.Column(db.String(1))
    xml_code = db.Column(db.String(2001))


class AsrAgeSexSubcat(db.Model):
    __tablename__ = 'asr_age_sex_subcat'
    __table_args__ = (UniqueConstraint('asr_month_id', 'offense_subcat_id',
                                       'age_range_id'), )

    id = db.Column(
        db.Integer,
        primary_key=True,
        server_default=text("nextval('asr_age_sex_subcat_id_seq'::regclass)"))
    arrest_count = db.Column(db.Integer)
    arrest_status = db.Column(db.SmallInteger)
    active_flag = db.Column(db.String(1))
    prepared_date = db.Column(db.DateTime(True))
    report_date = db.Column(db.DateTime(True))
    ff_line_number = db.Column(db.BigInteger)
    age_range_id = db.Column(db.Integer,
                             db.ForeignKey('asr_age_range.age_range_id',
                                           deferrable=True,
                                           initially='DEFERRED'),
                             nullable=False,
                             index=True)
    asr_month_id = db.Column(db.Integer,
                             db.ForeignKey('asr_month.asr_month_id',
                                           deferrable=True,
                                           initially='DEFERRED'),
                             nullable=False,
                             index=True)
    offense_subcat_id = db.Column(db.Integer,
                                  db.ForeignKey(
                                      'asr_offense_subcat.offense_subcat_id',
                                      deferrable=True,
                                      initially='DEFERRED'),
                                  nullable=False,
                                  index=True)

    age_range = db.relationship('AsrAgeRange')
    asr_month = db.relationship('AsrMonth')
    offense_subcat = db.relationship('AsrOffenseSubcat')


class AsrEthnicity(db.Model):
    __tablename__ = 'asr_ethnicity'

    ethnicity_id = db.Column(db.BigInteger, primary_key=True)
    ethnicity_name = db.Column(db.String(100))
    ethnicity_code = db.Column(db.String(20), unique=True)
    ff_sort_order = db.Column(db.String(3))


class AsrEthnicityOffense(db.Model):
    __tablename__ = 'asr_ethnicity_offense'
    __table_args__ = (db.UniqueConstraint('asr_month_id', 'offense_subcat_id',
                                          'ethnicity_id', 'juvenile_flag'), )

    id = db.Column(db.Integer,
                   primary_key=True,
                   server_default=text(
                       "nextval('asr_ethnicity_offense_id_seq'::regclass)"))
    juvenile_flag = db.Column(db.String(1), nullable=False)
    arrest_count = db.Column(db.Integer)
    arrest_status = db.Column(db.SmallInteger)
    prepared_date = db.Column(db.DateTime(True))
    report_date = db.Column(db.DateTime(True))
    ff_line_number = db.Column(db.BigInteger)
    asr_month_id = db.Column(db.Integer,
                             db.ForeignKey('asr_month.asr_month_id',
                                           deferrable=True,
                                           initially='DEFERRED'),
                             nullable=False,
                             index=True)
    ethnicity_id = db.Column(db.Integer,
                             db.ForeignKey('asr_ethnicity.ethnicity_id',
                                           deferrable=True,
                                           initially='DEFERRED'),
                             nullable=False,
                             index=True)
    offense_subcat_id = db.Column(db.Integer,
                                  db.ForeignKey(
                                      'asr_offense_subcat.offense_subcat_id',
                                      deferrable=True,
                                      initially='DEFERRED'),
                                  nullable=False,
                                  index=True)

    asr_month = db.relationship('AsrMonth')
    ethnicity = db.relationship('AsrEthnicity')
    offense_subcat = db.relationship('AsrOffenseSubcat')


class AsrMonth(db.Model):
    __tablename__ = 'asr_month'
    __table_args__ = (db.UniqueConstraint('agency_id', 'data_year',
                                          'month_num', 'data_home'), )

    asr_month_id = db.Column(db.BigInteger, primary_key=True)
    data_year = db.Column(db.SmallInteger, nullable=False)
    month_num = db.Column(db.SmallInteger, nullable=False)
    source_flag = db.Column(db.String(1), nullable=False)
    reported_flag = db.Column(db.String(1))
    orig_format = db.Column(db.String(1))
    update_flag = db.Column(db.String(1))
    ff_line_number = db.Column(db.BigInteger)
    ddocname = db.Column(db.String(100))
    did = db.Column(db.BigInteger)
    data_home = db.Column(db.String(1), nullable=False)
    agency_id = db.Column(db.Integer,
                          db.ForeignKey('ref_agency.agency_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)

    agency = db.relationship('RefAgency')


class AsrJuvenileDisposition(AsrMonth):
    __tablename__ = 'asr_juvenile_disposition'

    asr_month_id = db.Column(db.Integer,
                             db.ForeignKey('asr_month.asr_month_id',
                                           deferrable=True,
                                           initially='DEFERRED'),
                             primary_key=True)
    report_date = db.Column(db.DateTime(True))
    prepared_date = db.Column(db.DateTime(True))
    handled_within_dept = db.Column(db.Integer)
    juvenile_court = db.Column(db.Integer)
    welfare_agency = db.Column(db.Integer)
    other_police = db.Column(db.Integer)
    adult_court = db.Column(db.Integer)
    ff_line_number = db.Column(db.BigInteger)


class AsrOffense(db.Model):
    __tablename__ = 'asr_offense'

    offense_id = db.Column(db.BigInteger, primary_key=True)
    offense_name = db.Column(db.String(100))
    offense_code = db.Column(db.String(20), unique=True)
    total_flag = db.Column(db.String(1))
    offense_cat_id = db.Column(db.Integer,
                               db.ForeignKey(
                                   'asr_offense_category.offense_cat_id',
                                   deferrable=True,
                                   initially='DEFERRED'),
                               nullable=False,
                               index=True)

    offense_cat = db.relationship('AsrOffenseCategory')


class AsrOffenseCategory(db.Model):
    __tablename__ = 'asr_offense_category'

    offense_cat_id = db.Column(db.BigInteger, primary_key=True)
    offense_cat_name = db.Column(db.String(100))
    offense_cat_code = db.Column(db.String(20), unique=True)


class AsrOffenseSubcat(db.Model):
    __tablename__ = 'asr_offense_subcat'

    offense_subcat_id = db.Column(db.BigInteger, primary_key=True)
    offense_subcat_name = db.Column(db.String(100))
    offense_subcat_code = db.Column(db.String(20), unique=True)
    srs_offense_code = db.Column(db.String(3))
    master_offense_code = db.Column(db.SmallInteger)
    total_flag = db.Column(db.String(1))
    adult_juv_flag = db.Column(db.String(1))
    offense_id = db.Column(db.Integer,
                           db.ForeignKey('asr_offense.offense_id',
                                         deferrable=True,
                                         initially='DEFERRED'),
                           nullable=False,
                           index=True)

    offense = db.relationship('AsrOffense')


class AsrRaceOffenseSubcat(db.Model):
    __tablename__ = 'asr_race_offense_subcat'
    __table_args__ = (db.UniqueConstraint('asr_month_id', 'offense_subcat_id',
                                          'race_id', 'juvenile_flag'), )

    id = db.Column(db.Integer,
                   primary_key=True,
                   server_default=text(
                       "nextval('asr_race_offense_subcat_id_seq'::regclass)"))
    juvenile_flag = db.Column(db.String(1), nullable=False)
    arrest_count = db.Column(db.Integer)
    arrest_status = db.Column(db.SmallInteger)
    active_flag = db.Column(db.String(1))
    prepared_date = db.Column(db.DateTime(True))
    report_date = db.Column(db.DateTime(True))
    ff_line_number = db.Column(db.BigInteger)
    asr_month_id = db.Column(db.Integer,
                             db.ForeignKey('asr_month.asr_month_id',
                                           deferrable=True,
                                           initially='DEFERRED'),
                             nullable=False,
                             index=True)
    offense_subcat_id = db.Column(db.Integer,
                                  db.ForeignKey(
                                      'asr_offense_subcat.offense_subcat_id',
                                      deferrable=True,
                                      initially='DEFERRED'),
                                  nullable=False,
                                  index=True)
    race_id = db.Column(db.Integer,
                        db.ForeignKey('ref_race.race_id',
                                      deferrable=True,
                                      initially='DEFERRED'),
                        nullable=False,
                        index=True)

    asr_month = db.relationship('AsrMonth')
    offense_subcat = db.relationship('AsrOffenseSubcat')
    race = db.relationship('RefRace')


class CrimeType(db.Model):
    __tablename__ = 'crime_type'

    crime_type_id = db.Column(db.SmallInteger, primary_key=True)
    crime_type_name = db.Column(db.String(50))
    crime_type_sort_order = db.Column(db.SmallInteger)
    crime_flag = db.Column(db.String(1))


class CtArrestee(db.Model):
    __tablename__ = 'ct_arrestee'

    arrestee_id = db.Column(db.BigInteger, primary_key=True)
    age = db.Column(db.SmallInteger)
    sex_code = db.Column(db.String(1))
    ethnicity_id = db.Column(db.Integer,
                             db.ForeignKey('nibrs_ethnicity.ethnicity_id',
                                           deferrable=True,
                                           initially='DEFERRED'),
                             index=True)
    incident_id = db.Column(db.Integer,
                            db.ForeignKey('ct_incident.incident_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)
    race_id = db.Column(db.Integer,
                        db.ForeignKey('ref_race.race_id',
                                      deferrable=True,
                                      initially='DEFERRED'),
                        index=True)

    ethnicity = db.relationship('NibrsEthnicity')
    incident = db.relationship('CtIncident')
    race = db.relationship('RefRace')


class CtIncident(db.Model):
    __tablename__ = 'ct_incident'

    incident_id = db.Column(db.BigInteger, primary_key=True)
    data_year = db.Column(db.SmallInteger, nullable=False)
    incident_number = db.Column(db.String(15))
    incident_date = db.Column(db.DateTime(True))
    source_flag = db.Column(db.String(1), nullable=False)
    ddocname = db.Column(db.String(100))
    report_date = db.Column(db.DateTime(True))
    prepared_date = db.Column(db.DateTime(True))
    report_date_flag = db.Column(db.String(1))
    incident_hour = db.Column(db.SmallInteger)
    cleared_except_flag = db.Column(db.String(1))
    update_flag = db.Column(db.String(1))
    ff_line_number = db.Column(db.BigInteger)
    data_home = db.Column(db.String(1), nullable=False)
    orig_format = db.Column(db.String(1))
    unknown_offender = db.Column(db.String(1))
    did = db.Column(db.BigInteger)
    nibrs_incident_id = db.Column(db.BigInteger)
    agency_id = db.Column(db.Integer,
                          db.ForeignKey('ref_agency.agency_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)
    ct_month_id = db.Column(db.Integer,
                            db.ForeignKey('ct_month.ct_month_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)

    agency = db.relationship('RefAgency')
    ct_month = db.relationship('CtMonth')


class CtMonth(db.Model):
    __tablename__ = 'ct_month'

    ct_month_id = db.Column(db.BigInteger, primary_key=True)
    month_num = db.Column(db.SmallInteger, nullable=False)
    data_year = db.Column(db.SmallInteger, nullable=False)
    reported_status = db.Column(db.String(1))
    reported_count = db.Column(db.Integer)
    update_flag = db.Column(db.String(1))
    ff_line_number = db.Column(db.BigInteger)
    ddocname = db.Column(db.String(100))
    did = db.Column(db.BigInteger)
    data_home = db.Column(db.String(1), nullable=False)
    orig_format = db.Column(db.String(1))
    agency_id = db.Column(db.Integer,
                          db.ForeignKey('ref_agency.agency_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)

    agency = db.relationship('RefAgency')


class CtOffender(db.Model):
    __tablename__ = 'ct_offender'

    offender_id = db.Column(db.BigInteger, primary_key=True)
    age = db.Column(db.SmallInteger)
    sex_code = db.Column(db.String(1))
    ethnicity_id = db.Column(db.Integer,
                             db.ForeignKey('nibrs_ethnicity.ethnicity_id',
                                           deferrable=True,
                                           initially='DEFERRED'),
                             index=True)
    incident_id = db.Column(db.Integer,
                            db.ForeignKey('ct_incident.incident_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)
    race_id = db.Column(db.Integer,
                        db.ForeignKey('ref_race.race_id',
                                      deferrable=True,
                                      initially='DEFERRED'),
                        index=True)

    ethnicity = db.relationship('NibrsEthnicity')
    incident = db.relationship('CtIncident')
    race = db.relationship('RefRace')


class CtOffense(db.Model):
    __tablename__ = 'ct_offense'

    offense_id = db.Column(db.BigInteger, primary_key=True)
    ct_offense_flag = db.Column(db.String(1))
    incident_id = db.Column(db.Integer,
                            db.ForeignKey('ct_incident.incident_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)
    location_id = db.Column(db.Integer,
                            db.ForeignKey('nibrs_location_type.location_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)
    offense_type_id = db.Column(db.Integer,
                                db.ForeignKey(
                                    'nibrs_offense_type.offense_type_id',
                                    deferrable=True,
                                    initially='DEFERRED'),
                                nullable=False,
                                index=True)

    incident = db.relationship('CtIncident')
    location = db.relationship('NibrsLocationType')
    offense_type = db.relationship('NibrsOffenseType')


class CtProperty(db.Model):
    __tablename__ = 'ct_property'

    property_id = db.Column(db.BigInteger, primary_key=True)
    stolen_value = db.Column(db.BigInteger)
    recovered_flag = db.Column(db.String(1))
    date_recovered = db.Column(db.DateTime(True))
    recovered_value = db.Column(db.BigInteger)
    incident_id = db.Column(db.Integer,
                            db.ForeignKey('ct_incident.incident_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)
    prop_desc_id = db.Column(db.Integer,
                             db.ForeignKey('nibrs_prop_desc_type.prop_desc_id',
                                           deferrable=True,
                                           initially='DEFERRED'),
                             nullable=False,
                             index=True)

    incident = db.relationship('CtIncident')
    prop_desc = db.relationship('NibrsPropDescType')


class CtVictim(db.Model):
    __tablename__ = 'ct_victim'
    __table_args__ = (UniqueConstraint('incident_id', 'victim_type_id'), )

    id = db.Column(
        db.Integer,
        primary_key=True,
        server_default=text("nextval('ct_victim_id_seq'::regclass)"))
    incident_id = db.Column(db.Integer,
                            db.ForeignKey('ct_incident.incident_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)
    victim_type_id = db.Column(db.Integer,
                               db.ForeignKey(
                                   'nibrs_victim_type.victim_type_id',
                                   deferrable=True,
                                   initially='DEFERRED'),
                               nullable=False,
                               index=True)

    incident = db.relationship('CtIncident')
    victim_type = db.relationship('NibrsVictimType')


class CtWeapon(db.Model):
    __tablename__ = 'ct_weapon'

    ct_weapon_id = db.Column(db.BigInteger, primary_key=True)
    incident_id = db.Column(db.Integer,
                            db.ForeignKey('ct_incident.incident_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)
    weapon_id = db.Column(db.Integer,
                          db.ForeignKey('nibrs_weapon_type.weapon_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)

    incident = db.relationship('CtIncident')
    weapon = db.relationship('NibrsWeaponType')


class HcBiasMotivation(db.Model):
    __tablename__ = 'hc_bias_motivation'
    __table_args__ = (UniqueConstraint('offense_id', 'bias_id'), )

    id = db.Column(
        db.Integer,
        primary_key=True,
        server_default=text("nextval('hc_bias_motivation_id_seq'::regclass)"))
    bias_id = db.Column(db.Integer,
                        db.ForeignKey('nibrs_bias_list.bias_id',
                                      deferrable=True,
                                      initially='DEFERRED'),
                        nullable=False,
                        index=True)
    offense_id = db.Column(db.Integer,
                           db.ForeignKey('hc_offense.offense_id',
                                         deferrable=True,
                                         initially='DEFERRED'),
                           nullable=False,
                           index=True)

    bias = db.relationship('NibrsBiasList')
    offense = db.relationship('HcOffense')


class HcIncident(db.Model):
    __tablename__ = 'hc_incident'

    incident_id = db.Column(db.BigInteger, primary_key=True)
    incident_no = db.Column(db.String(20))
    incident_date = db.Column(db.DateTime(True))
    data_home = db.Column(db.String(1))
    source_flag = db.Column(db.String(1))
    ddocname = db.Column(db.String(100))
    report_date = db.Column(db.DateTime(True))
    prepared_date = db.Column(db.DateTime(True))
    victim_count = db.Column(db.SmallInteger)
    adult_victim_count = db.Column(db.SmallInteger)
    incident_status = db.Column(db.SmallInteger)
    juvenile_victim_count = db.Column(db.SmallInteger)
    offender_count = db.Column(db.SmallInteger)
    adult_offender_count = db.Column(db.SmallInteger)
    juvenile_offender_count = db.Column(db.SmallInteger)
    update_flag = db.Column(db.String(1))
    ff_line_number = db.Column(db.BigInteger)
    orig_format = db.Column(db.String(1))
    did = db.Column(db.BigInteger)
    nibrs_incident_id = db.Column(db.BigInteger)
    agency_id = db.Column(db.Integer,
                          db.ForeignKey('ref_agency.agency_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)
    hc_quarter_id = db.Column(db.Integer,
                              db.ForeignKey('hc_quarter.hc_quarter_id',
                                            deferrable=True,
                                            initially='DEFERRED'),
                              nullable=False,
                              index=True)
    offender_ethnicity_id = db.Column(
        db.Integer,
        db.ForeignKey('nibrs_ethnicity.ethnicity_id',
                      deferrable=True,
                      initially='DEFERRED'),
        index=True)
    offender_race_id = db.Column(db.Integer,
                                 db.ForeignKey('ref_race.race_id',
                                               deferrable=True,
                                               initially='DEFERRED'),
                                 index=True)

    agency = db.relationship('RefAgency')
    hc_quarter = db.relationship('HcQuarter')
    offender_ethnicity = db.relationship('NibrsEthnicity')
    offender_race = db.relationship('RefRace')


class HcOffense(db.Model):
    __tablename__ = 'hc_offense'

    offense_id = db.Column(db.BigInteger, primary_key=True)
    victim_count = db.Column(db.SmallInteger)
    nibrs_offense_id = db.Column(db.BigInteger)
    incident_id = db.Column(db.Integer,
                            db.ForeignKey('hc_incident.incident_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)
    location_id = db.Column(db.Integer,
                            db.ForeignKey('nibrs_location_type.location_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            index=True)
    offense_type_id = db.Column(
        db.Integer,
        db.ForeignKey('nibrs_offense_type.offense_type_id',
                      deferrable=True,
                      initially='DEFERRED'),
        index=True)

    incident = db.relationship('HcIncident')
    location = db.relationship('NibrsLocationType')
    offense_type = db.relationship('NibrsOffenseType')


class HcQuarter(db.Model):
    __tablename__ = 'hc_quarter'
    __table_args__ = (UniqueConstraint('agency_id', 'quarter_num', 'data_year',
                                       'data_home'), )

    quarter_num = db.Column(db.SmallInteger, nullable=False)
    data_year = db.Column(db.SmallInteger, nullable=False)
    reported_status = db.Column(db.String(1))
    reported_count = db.Column(db.BigInteger)
    hc_quarter_id = db.Column(db.BigInteger, primary_key=True)
    update_flag = db.Column(db.String(1))
    orig_format = db.Column(db.String(1))
    ff_line_number = db.Column(db.BigInteger)
    ddocname = db.Column(db.String(100))
    did = db.Column(db.BigInteger)
    data_home = db.Column(db.String(1), nullable=False)
    agency_id = db.Column(db.Integer,
                          db.ForeignKey('ref_agency.agency_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)

    agency = db.relationship('RefAgency')


class HcVictim(db.Model):
    __tablename__ = 'hc_victim'
    __table_args__ = (UniqueConstraint('offense_id', 'victim_type_id'), )

    id = db.Column(
        db.Integer,
        primary_key=True,
        server_default=text("nextval('hc_victim_id_seq'::regclass)"))
    offense_id = db.Column(db.Integer,
                           db.ForeignKey('hc_offense.offense_id',
                                         deferrable=True,
                                         initially='DEFERRED'),
                           nullable=False,
                           index=True)
    victim_type_id = db.Column(db.Integer,
                               db.ForeignKey(
                                   'nibrs_victim_type.victim_type_id',
                                   deferrable=True,
                                   initially='DEFERRED'),
                               nullable=False,
                               index=True)

    offense = db.relationship('HcOffense')
    victim_type = db.relationship('NibrsVictimType')


class HtMonth(db.Model):
    __tablename__ = 'ht_month'
    __table_args__ = (
        UniqueConstraint('agency_id', 'data_year', 'month_num', 'data_home'), )

    ht_month_id = db.Column(db.BigInteger, primary_key=True)
    data_year = db.Column(db.SmallInteger, nullable=False)
    month_num = db.Column(db.SmallInteger, nullable=False)
    data_home = db.Column(db.String(1), nullable=False)
    source_flag = db.Column(db.String(1), nullable=False)
    ddocname = db.Column(db.String(100))
    report_date = db.Column(db.DateTime(True))
    prepared_date = db.Column(db.DateTime(True))
    prepared_by_user = db.Column(db.String(100))
    prepared_by_email = db.Column(db.String(200))
    orig_format = db.Column(db.String(1), nullable=False)
    total_reported_count = db.Column(db.Integer)
    total_unfounded_count = db.Column(db.Integer)
    total_actual_count = db.Column(db.Integer)
    total_cleared_count = db.Column(db.Integer)
    total_juvenile_cleared_count = db.Column(db.Integer)
    update_flag = db.Column(db.String(1))
    reported_flag = db.Column(db.String(1))
    did = db.Column(db.BigInteger)
    ff_line_number = db.Column(db.BigInteger)
    agency_id = db.Column(db.Integer,
                          db.ForeignKey('ref_agency.agency_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)

    agency = db.relationship('RefAgency')


class HtMonthOffenseSubcat(db.Model):
    __tablename__ = 'ht_month_offense_subcat'
    __table_args__ = (UniqueConstraint('offense_subcat_id', 'ht_month_id'), )

    id = db.Column(db.Integer,
                   primary_key=True,
                   server_default=text(
                       "nextval('ht_month_offense_subcat_id_seq'::regclass)"))
    reported_count = db.Column(db.Integer)
    reported_status = db.Column(db.SmallInteger)
    unfounded_count = db.Column(db.Integer)
    unfounded_status = db.Column(db.SmallInteger)
    actual_count = db.Column(db.Integer)
    actual_status = db.Column(db.SmallInteger)
    cleared_count = db.Column(db.Integer)
    cleared_status = db.Column(db.SmallInteger)
    juvenile_cleared_count = db.Column(db.Integer)
    juvenile_cleared_status = db.Column(db.SmallInteger)
    ht_month_id = db.Column(db.Integer,
                            db.ForeignKey('ht_month.ht_month_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)
    offense_subcat_id = db.Column(db.Integer,
                                  db.ForeignKey(
                                      'reta_offense_subcat.offense_subcat_id',
                                      deferrable=True,
                                      initially='DEFERRED'),
                                  nullable=False,
                                  index=True)

    ht_month = db.relationship('HtMonth')
    offense_subcat = db.relationship('RetaOffenseSubcat')


class NibrsActivityType(db.Model):
    __tablename__ = 'nibrs_activity_type'

    activity_type_id = db.Column(db.SmallInteger, primary_key=True)
    activity_type_code = db.Column(db.String(2))
    activity_type_name = db.Column(db.String(100))


class NibrsAge(db.Model):
    __tablename__ = 'nibrs_age'

    age_id = db.Column(db.SmallInteger, primary_key=True)
    age_code = db.Column(db.String(2))
    age_name = db.Column(db.String(100))


class NibrsArrestType(db.Model):
    __tablename__ = 'nibrs_arrest_type'

    arrest_type_id = db.Column(db.SmallInteger, primary_key=True)
    arrest_type_code = db.Column(db.String(1))
    arrest_type_name = db.Column(db.String(100))


class NibrsArrestee(db.Model):
    __tablename__ = 'nibrs_arrestee'

    arrestee_id = db.Column(db.BigInteger, primary_key=True)
    arrestee_seq_num = db.Column(db.BigInteger)
    arrest_num = db.Column(db.String(12))
    arrest_date = db.Column(db.DateTime(True))
    multiple_indicator = db.Column(db.String(1))
    age_num = db.Column(db.SmallInteger)
    sex_code = db.Column(db.String(1))
    resident_code = db.Column(db.String(1))
    under_18_disposition_code = db.Column(db.String(1))
    clearance_ind = db.Column(db.String(1))
    ff_line_number = db.Column(db.BigInteger)
    age_range_low_num = db.Column(db.SmallInteger)
    age_range_high_num = db.Column(db.SmallInteger)
    age_id = db.Column(db.Integer,
                       db.ForeignKey('nibrs_age.age_id',
                                     deferrable=True,
                                     initially='DEFERRED'),
                       nullable=False,
                       index=True)
    arrest_type_id = db.Column(
        db.Integer,
        db.ForeignKey('nibrs_arrest_type.arrest_type_id',
                      deferrable=True,
                      initially='DEFERRED'),
        index=True)
    ethnicity_id = db.Column(db.Integer,
                             db.ForeignKey('nibrs_ethnicity.ethnicity_id',
                                           deferrable=True,
                                           initially='DEFERRED'),
                             index=True)
    incident_id = db.Column(db.Integer,
                            db.ForeignKey('nibrs_incident.incident_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)
    offense_type_id = db.Column(db.Integer,
                                db.ForeignKey(
                                    'nibrs_offense_type.offense_type_id',
                                    deferrable=True,
                                    initially='DEFERRED'),
                                nullable=False,
                                index=True)
    race_id = db.Column(db.Integer,
                        db.ForeignKey('ref_race.race_id',
                                      deferrable=True,
                                      initially='DEFERRED'),
                        nullable=False,
                        index=True)

    age = db.relationship('NibrsAge', backref='arrestees')
    arrest_type = db.relationship('NibrsArrestType', backref='arrestees')
    ethnicity = db.relationship('NibrsEthnicity', backref='arrestees')
    incident = db.relationship('NibrsIncident', backref='arrestees')
    offense_type = db.relationship('NibrsOffenseType', backref='arrestees')
    race = db.relationship('RefRace', backref='arrestees')


class NibrsArresteeWeapon(db.Model):
    __tablename__ = 'nibrs_arrestee_weapon'

    nibrs_arrestee_weapon_id = db.Column(db.BigInteger, primary_key=True)
    arrestee_id = db.Column(db.Integer,
                            db.ForeignKey('nibrs_arrestee.arrestee_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)
    weapon_id = db.Column(db.Integer,
                          db.ForeignKey('nibrs_weapon_type.weapon_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)

    arrestee = db.relationship('NibrsArrestee')
    weapon = db.relationship('NibrsWeaponType')


class NibrsAssignmentType(db.Model):
    __tablename__ = 'nibrs_assignment_type'

    assignment_type_id = db.Column(db.SmallInteger, primary_key=True)
    assignment_type_code = db.Column(db.String(1))
    assignment_type_name = db.Column(db.String(100))


class NibrsBiasList(db.Model):
    __tablename__ = 'nibrs_bias_list'

    bias_id = db.Column(db.SmallInteger, primary_key=True)
    bias_code = db.Column(db.String(2))
    bias_name = db.Column(db.String(100))


class NibrsBiasMotivation(db.Model):
    __tablename__ = 'nibrs_bias_motivation'
    __table_args__ = (UniqueConstraint('bias_id', 'offense_id'), )

    id = db.Column(db.Integer,
                   primary_key=True,
                   server_default=text(
                       "nextval('nibrs_bias_motivation_id_seq'::regclass)"))
    bias_id = db.Column(db.Integer,
                        db.ForeignKey('nibrs_bias_list.bias_id',
                                      deferrable=True,
                                      initially='DEFERRED'),
                        nullable=False,
                        index=True)
    offense_id = db.Column(db.Integer,
                           db.ForeignKey('nibrs_offense.offense_id',
                                         deferrable=True,
                                         initially='DEFERRED'),
                           nullable=False,
                           index=True)

    bias = db.relationship('NibrsBiasList')
    offense = db.relationship('NibrsOffense')


class NibrsCircumstance(db.Model):
    __tablename__ = 'nibrs_circumstances'

    circumstances_id = db.Column(db.SmallInteger, primary_key=True)
    circumstances_type = db.Column(db.String(1))
    circumstances_code = db.Column(db.SmallInteger)
    circumstances_name = db.Column(db.String(100))


class NibrsClearedExcept(db.Model):
    __tablename__ = 'nibrs_cleared_except'

    cleared_except_id = db.Column(db.SmallInteger, primary_key=True)
    cleared_except_code = db.Column(db.String(1))
    cleared_except_name = db.Column(db.String(100))


class NibrsCriminalAct(db.Model):
    __tablename__ = 'nibrs_criminal_act'
    __table_args__ = (UniqueConstraint('criminal_act_id', 'offense_id'), )

    id = db.Column(
        db.Integer,
        primary_key=True,
        server_default=text("nextval('nibrs_criminal_act_id_seq'::regclass)"))
    criminal_act_id = db.Column(db.Integer,
                                db.ForeignKey(
                                    'nibrs_criminal_act_type.criminal_act_id',
                                    deferrable=True,
                                    initially='DEFERRED'),
                                nullable=False,
                                index=True)
    offense_id = db.Column(db.Integer,
                           db.ForeignKey('nibrs_offense.offense_id',
                                         deferrable=True,
                                         initially='DEFERRED'),
                           nullable=False,
                           index=True)

    criminal_act = db.relationship('NibrsCriminalActType')
    offense = db.relationship('NibrsOffense')


class NibrsCriminalActType(db.Model):
    __tablename__ = 'nibrs_criminal_act_type'

    criminal_act_id = db.Column(db.SmallInteger, primary_key=True)
    criminal_act_code = db.Column(db.String(1))
    criminal_act_name = db.Column(db.String(100))


class NibrsDrugMeasureType(db.Model):
    __tablename__ = 'nibrs_drug_measure_type'

    drug_measure_type_id = db.Column(db.SmallInteger, primary_key=True)
    drug_measure_code = db.Column(db.String(2))
    drug_measure_name = db.Column(db.String(100))


class NibrsEd(db.Model):
    __tablename__ = 'nibrs_eds'

    id = db.Column(
        db.Integer,
        primary_key=True,
        server_default=text("nextval('nibrs_eds_id_seq'::regclass)"))
    ddocname = db.Column(db.String(100))
    data_year = db.Column(db.SmallInteger)
    month_num = db.Column(db.SmallInteger)
    relative_rec_num = db.Column(db.Integer)
    segment_action_type = db.Column(db.String(1))
    ori = db.Column(db.String(9))
    incident_num = db.Column(db.String(12))
    level = db.Column(db.String(1))
    offense_code = db.Column(db.String(3))
    person_seq_num = db.Column(db.String(3))
    type_prop_loss = db.Column(db.String(1))
    data_element_num = db.Column(db.String(3))
    error_num = db.Column(db.SmallInteger)
    data_field = db.Column(db.String(12))
    error_msg = db.Column(db.String(79))
    submission_ser_num = db.Column(db.Integer)


class NibrsEthnicity(db.Model):
    __tablename__ = 'nibrs_ethnicity'

    ethnicity_id = db.Column(db.SmallInteger, primary_key=True)
    ethnicity_code = db.Column(db.String(1))
    ethnicity_name = db.Column(db.String(100))
    hc_flag = db.Column(db.String(1))


class NibrsGrpbArrest(db.Model):
    __tablename__ = 'nibrs_grpb_arrest'

    grpb_arrest_id = db.Column(db.BigInteger, primary_key=True)
    arrest_num = db.Column(db.String(15))
    arrest_date = db.Column(db.DateTime(True))
    arrest_seq_num = db.Column(db.SmallInteger)
    city = db.Column(db.String(4))
    arrest_type_id = db.Column(db.SmallInteger)
    offense_type_id = db.Column(db.BigInteger)
    sex_code = db.Column(db.String(1))
    resident_code = db.Column(db.String(1))
    under_18_disposition_code = db.Column(db.String(1))
    age_num = db.Column(db.SmallInteger)
    arrest_year = db.Column(db.SmallInteger)
    ff_line_number = db.Column(db.BigInteger)
    data_home = db.Column(db.String(1))
    ddocname = db.Column(db.String(100))
    did = db.Column(db.BigInteger)
    age_range_low_num = db.Column(db.SmallInteger)
    age_range_high_num = db.Column(db.SmallInteger)
    age_id = db.Column(db.Integer,
                       db.ForeignKey('nibrs_age.age_id',
                                     deferrable=True,
                                     initially='DEFERRED'),
                       index=True)
    agency_id = db.Column(db.Integer,
                          db.ForeignKey('ref_agency.agency_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)
    ethnicity_id = db.Column(db.Integer,
                             db.ForeignKey('nibrs_ethnicity.ethnicity_id',
                                           deferrable=True,
                                           initially='DEFERRED'),
                             index=True)
    nibrs_month_id = db.Column(db.Integer,
                               db.ForeignKey('nibrs_month.nibrs_month_id',
                                             deferrable=True,
                                             initially='DEFERRED'),
                               nullable=False,
                               index=True)
    race_id = db.Column(db.Integer,
                        db.ForeignKey('ref_race.race_id',
                                      deferrable=True,
                                      initially='DEFERRED'),
                        index=True)

    age = db.relationship('NibrsAge')
    agency = db.relationship('RefAgency')
    ethnicity = db.relationship('NibrsEthnicity')
    nibrs_month = db.relationship('NibrsMonth')
    race = db.relationship('RefRace')


class NibrsGrpbArrestWeapon(db.Model):
    __tablename__ = 'nibrs_grpb_arrest_weapon'

    nibrs_grpb_arrest_weapon_id = db.Column(db.BigInteger, primary_key=True)
    grpb_arrest_id = db.Column(db.Integer,
                               db.ForeignKey(
                                   'nibrs_grpb_arrest.grpb_arrest_id',
                                   deferrable=True,
                                   initially='DEFERRED'),
                               nullable=False,
                               index=True)
    weapon_id = db.Column(db.Integer,
                          db.ForeignKey('nibrs_weapon_type.weapon_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)

    grpb_arrest = db.relationship('NibrsGrpbArrest')
    weapon = db.relationship('NibrsWeaponType')


class NibrsIncident(db.Model):
    __tablename__ = 'nibrs_incident'

    incident_id = db.Column(db.BigInteger, primary_key=True)
    incident_number = db.Column(db.String(15))
    cargo_theft_flag = db.Column(db.String(1))
    submission_date = db.Column(db.DateTime(True))
    incident_date = db.Column(db.DateTime(True))
    report_date_flag = db.Column(db.String(1))
    incident_hour = db.Column(db.SmallInteger)
    cleared_except_date = db.Column(db.DateTime(True))
    incident_status = db.Column(db.SmallInteger)
    data_home = db.Column(db.String(1))
    ddocname = db.Column(db.String(100))
    orig_format = db.Column(db.String(1))
    ff_line_number = db.Column(db.BigInteger)
    did = db.Column(db.BigInteger)
    agency_id = db.Column(db.Integer,
                          db.ForeignKey('ref_agency.agency_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)
    cleared_except_id = db.Column(db.Integer,
                                  db.ForeignKey(
                                      'nibrs_cleared_except.cleared_except_id',
                                      deferrable=True,
                                      initially='DEFERRED'),
                                  nullable=False,
                                  index=True)
    nibrs_month_id = db.Column(db.Integer,
                               db.ForeignKey('nibrs_month.nibrs_month_id',
                                             deferrable=True,
                                             initially='DEFERRED'),
                               nullable=False,
                               index=True)

    agency = db.relationship('RefAgency')
    cleared_except = db.relationship('NibrsClearedExcept')
    nibrs_month = db.relationship('NibrsMonth')


class NibrsInjury(db.Model):
    __tablename__ = 'nibrs_injury'

    injury_id = db.Column(db.SmallInteger, primary_key=True)
    injury_code = db.Column(db.String(1))
    injury_name = db.Column(db.String(100))


class NibrsJustifiableForce(db.Model):
    __tablename__ = 'nibrs_justifiable_force'

    justifiable_force_id = db.Column(db.SmallInteger, primary_key=True)
    justifiable_force_code = db.Column(db.String(1))
    justifiable_force_name = db.Column(db.String(100))


class NibrsLocationType(db.Model):
    __tablename__ = 'nibrs_location_type'

    location_id = db.Column(db.BigInteger, primary_key=True)
    location_code = db.Column(db.String(2))
    location_name = db.Column(db.String(100))


class NibrsMonth(db.Model):
    __tablename__ = 'nibrs_month'
    __table_args__ = (
        UniqueConstraint('agency_id', 'month_num', 'data_year', 'data_home'), )

    nibrs_month_id = db.Column(db.BigInteger, primary_key=True)
    month_num = db.Column(db.SmallInteger, nullable=False)
    data_year = db.Column(db.SmallInteger, nullable=False)
    reported_status = db.Column(db.String(1))
    report_date = db.Column(db.DateTime(True))
    prepared_date = db.Column(db.DateTime(True))
    update_flag = db.Column(db.String(1), nullable=False)
    orig_format = db.Column(db.String(1), nullable=False)
    ff_line_number = db.Column(db.BigInteger)
    data_home = db.Column(db.String(1))
    ddocname = db.Column(db.String(50))
    did = db.Column(db.BigInteger)
    agency_id = db.Column(db.Integer,
                          db.ForeignKey('ref_agency.agency_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)

    agency = db.relationship('RefAgency')


class NibrsOffender(db.Model):
    __tablename__ = 'nibrs_offender'

    offender_id = db.Column(db.BigInteger, primary_key=True)
    offender_seq_num = db.Column(db.SmallInteger)
    age_num = db.Column(db.SmallInteger)
    sex_code = db.Column(db.String(1))
    ff_line_number = db.Column(db.BigInteger)
    age_range_low_num = db.Column(db.SmallInteger)
    age_range_high_num = db.Column(db.SmallInteger)
    age_id = db.Column(db.Integer,
                       db.ForeignKey('nibrs_age.age_id',
                                     deferrable=True,
                                     initially='DEFERRED'),
                       index=True)
    ethnicity_id = db.Column(db.Integer,
                             db.ForeignKey('nibrs_ethnicity.ethnicity_id',
                                           deferrable=True,
                                           initially='DEFERRED'),
                             index=True)
    incident_id = db.Column(db.Integer,
                            db.ForeignKey('nibrs_incident.incident_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)
    race_id = db.Column(db.Integer,
                        db.ForeignKey('ref_race.race_id',
                                      deferrable=True,
                                      initially='DEFERRED'),
                        index=True)

    age = db.relationship('NibrsAge', backref='offenders')
    ethnicity = db.relationship('NibrsEthnicity', backref='offenders')
    incident = db.relationship('NibrsIncident', backref='offenders')
    race = db.relationship('RefRace', backref='offenders')


class NibrsOffense(db.Model):
    __tablename__ = 'nibrs_offense'

    offense_id = db.Column(db.BigInteger, primary_key=True)
    attempt_complete_flag = db.Column(db.String(1))
    num_premises_entered = db.Column(db.SmallInteger)
    method_entry_code = db.Column(db.String(1))
    ff_line_number = db.Column(db.BigInteger)
    incident_id = db.Column(db.Integer,
                            db.ForeignKey('nibrs_incident.incident_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)
    location_id = db.Column(db.Integer,
                            db.ForeignKey('nibrs_location_type.location_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)
    offense_type_id = db.Column(db.Integer,
                                db.ForeignKey(
                                    'nibrs_offense_type.offense_type_id',
                                    deferrable=True,
                                    initially='DEFERRED'),
                                nullable=False,
                                index=True)

    incident = db.relationship('NibrsIncident', backref='offenses')
    location = db.relationship('NibrsLocationType', backref='offenses')
    offense_type = db.relationship('NibrsOffenseType', backref='offenses')


class NibrsOffenseType(db.Model):
    __tablename__ = 'nibrs_offense_type'

    offense_type_id = db.Column(db.BigInteger, primary_key=True)
    offense_code = db.Column(db.String(5))
    offense_name = db.Column(db.String(100))
    crime_against = db.Column(db.String(100))
    ct_flag = db.Column(db.String(1))
    hc_flag = db.Column(db.String(1))
    hc_code = db.Column(db.String(5))
    offense_category_name = db.Column(db.String(100))


class NibrsPropDescType(db.Model):
    __tablename__ = 'nibrs_prop_desc_type'

    prop_desc_id = db.Column(db.SmallInteger, primary_key=True)
    prop_desc_code = db.Column(db.String(2))
    prop_desc_name = db.Column(db.String(100))


class NibrsPropLossType(db.Model):
    __tablename__ = 'nibrs_prop_loss_type'

    prop_loss_id = db.Column(db.SmallInteger, primary_key=True)
    prop_loss_name = db.Column(db.String(100))


class NibrsProperty(db.Model):
    __tablename__ = 'nibrs_property'

    property_id = db.Column(db.BigInteger, primary_key=True)
    stolen_count = db.Column(db.SmallInteger)
    recovered_count = db.Column(db.SmallInteger)
    ff_line_number = db.Column(db.BigInteger)
    incident_id = db.Column(db.Integer,
                            db.ForeignKey('nibrs_incident.incident_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)
    prop_loss_id = db.Column(db.Integer,
                             db.ForeignKey('nibrs_prop_loss_type.prop_loss_id',
                                           deferrable=True,
                                           initially='DEFERRED'),
                             nullable=False,
                             index=True)

    incident = db.relationship('NibrsIncident', backref='property')
    prop_loss = db.relationship('NibrsPropLossType', backref='property')


class NibrsPropertyDesc(db.Model):
    __tablename__ = 'nibrs_property_desc'

    property_value = db.Column(db.BigInteger)
    date_recovered = db.Column(db.DateTime(True))
    nibrs_prop_desc_id = db.Column(db.BigInteger, primary_key=True)
    prop_desc_id = db.Column(db.Integer,
                             db.ForeignKey('nibrs_prop_desc_type.prop_desc_id',
                                           deferrable=True,
                                           initially='DEFERRED'),
                             nullable=False,
                             index=True)
    property_id = db.Column(db.Integer,
                            db.ForeignKey('nibrs_property.property_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)

    prop_desc = db.relationship('NibrsPropDescType')
    property = db.relationship('NibrsProperty')


class NibrsRelationship(db.Model):
    __tablename__ = 'nibrs_relationship'

    relationship_id = db.Column(db.SmallInteger, primary_key=True)
    relationship_code = db.Column(db.String(2))
    relationship_name = db.Column(db.String(100))


class NibrsSumMonthTemp(db.Model):
    __tablename__ = 'nibrs_sum_month_temp'

    id = db.Column(db.Integer,
                   primary_key=True,
                   server_default=text(
                       "nextval('nibrs_sum_month_temp_id_seq'::regclass)"))
    nibrs_month_id = db.Column(db.BigInteger)
    agency_id = db.Column(db.BigInteger)
    month_num = db.Column(db.SmallInteger)
    data_year = db.Column(db.SmallInteger)
    reported_status = db.Column(db.String(1))
    report_date = db.Column(db.DateTime(True))
    prepared_date = db.Column(db.DateTime(True))
    orig_format = db.Column(db.String(1))
    ff_line_number = db.Column(db.BigInteger)
    data_home = db.Column(db.String(1))
    ddocname = db.Column(db.String(50))
    did = db.Column(db.BigInteger)
    nibrs_ct_flag = db.Column(db.String(1))
    nibrs_hc_flag = db.Column(db.String(1))
    nibrs_leoka_flag = db.Column(db.String(1))
    nibrs_arson_flag = db.Column(db.String(1))
    nibrs_ht_flag = db.Column(db.String(1))


class NibrsSuspectUsing(db.Model):
    __tablename__ = 'nibrs_suspect_using'
    __table_args__ = (UniqueConstraint('suspect_using_id', 'offense_id'), )

    id = db.Column(
        db.Integer,
        primary_key=True,
        server_default=text("nextval('nibrs_suspect_using_id_seq'::regclass)"))
    offense_id = db.Column(db.Integer,
                           db.ForeignKey('nibrs_offense.offense_id',
                                         deferrable=True,
                                         initially='DEFERRED'),
                           nullable=False,
                           index=True)
    suspect_using_id = db.Column(db.Integer,
                                 db.ForeignKey(
                                     'nibrs_using_list.suspect_using_id',
                                     deferrable=True,
                                     initially='DEFERRED'),
                                 nullable=False,
                                 index=True)

    offense = db.relationship('NibrsOffense')
    suspect_using = db.relationship('NibrsUsingList')


class NibrsSuspectedDrug(db.Model):
    __tablename__ = 'nibrs_suspected_drug'

    est_drug_qty = db.Column(Float(53))
    nibrs_suspected_drug_id = db.Column(db.BigInteger, primary_key=True)
    drug_measure_type_id = db.Column(
        db.Integer,
        db.ForeignKey('nibrs_drug_measure_type.drug_measure_type_id',
                      deferrable=True,
                      initially='DEFERRED'),
        index=True)
    property_id = db.Column(db.Integer,
                            db.ForeignKey('nibrs_property.property_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)
    suspected_drug_type_id = db.Column(
        db.Integer,
        db.ForeignKey('nibrs_suspected_drug_type.suspected_drug_type_id',
                      deferrable=True,
                      initially='DEFERRED'),
        nullable=False,
        index=True)

    drug_measure_type = db.relationship('NibrsDrugMeasureType')
    property = db.relationship('NibrsProperty')
    suspected_drug_type = db.relationship('NibrsSuspectedDrugType')


class NibrsSuspectedDrugType(db.Model):
    __tablename__ = 'nibrs_suspected_drug_type'

    suspected_drug_type_id = db.Column(db.SmallInteger, primary_key=True)
    suspected_drug_code = db.Column(db.String(1))
    suspected_drug_name = db.Column(db.String(100))


class NibrsUsingList(db.Model):
    __tablename__ = 'nibrs_using_list'

    suspect_using_id = db.Column(db.SmallInteger, primary_key=True)
    suspect_using_code = db.Column(db.String(1))
    suspect_using_name = db.Column(db.String(100))


class NibrsVictim(db.Model):
    __tablename__ = 'nibrs_victim'

    victim_id = db.Column(db.BigInteger, primary_key=True)
    victim_seq_num = db.Column(db.SmallInteger)
    outside_agency_id = db.Column(db.BigInteger)
    age_num = db.Column(db.SmallInteger)
    sex_code = db.Column(db.String(1))
    resident_status_code = db.Column(db.String(1))
    agency_data_year = db.Column(db.SmallInteger)
    ff_line_number = db.Column(db.BigInteger)
    age_range_low_num = db.Column(db.SmallInteger)
    age_range_high_num = db.Column(db.SmallInteger)
    activity_type_id = db.Column(
        db.Integer,
        db.ForeignKey('nibrs_activity_type.activity_type_id',
                      deferrable=True,
                      initially='DEFERRED'),
        index=True)
    age_id = db.Column(db.Integer,
                       db.ForeignKey('nibrs_age.age_id',
                                     deferrable=True,
                                     initially='DEFERRED'),
                       index=True)
    assignment_type_id = db.Column(
        db.Integer,
        db.ForeignKey('nibrs_assignment_type.assignment_type_id',
                      deferrable=True,
                      initially='DEFERRED'),
        index=True)
    ethnicity_id = db.Column(db.Integer,
                             db.ForeignKey('nibrs_ethnicity.ethnicity_id',
                                           deferrable=True,
                                           initially='DEFERRED'),
                             index=True)
    incident_id = db.Column(db.Integer,
                            db.ForeignKey('nibrs_incident.incident_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)
    race_id = db.Column(db.Integer,
                        db.ForeignKey('ref_race.race_id',
                                      deferrable=True,
                                      initially='DEFERRED'),
                        index=True)
    victim_type_id = db.Column(db.Integer,
                               db.ForeignKey(
                                   'nibrs_victim_type.victim_type_id',
                                   deferrable=True,
                                   initially='DEFERRED'),
                               nullable=False,
                               index=True)

    activity_type = db.relationship('NibrsActivityType', backref='victims')
    age = db.relationship('NibrsAge', backref='victims')
    assignment_type = db.relationship('NibrsAssignmentType', backref='victims')
    ethnicity = db.relationship('NibrsEthnicity', backref='victims')
    incident = db.relationship('NibrsIncident', backref='victims')
    race = db.relationship('RefRace', backref='victims')
    victim_type = db.relationship('NibrsVictimType', backref='victims')


class NibrsVictimCircumstance(db.Model):
    __tablename__ = 'nibrs_victim_circumstances'
    __table_args__ = (UniqueConstraint('victim_id', 'circumstances_id'), )

    id = db.Column(
        db.Integer,
        primary_key=True,
        server_default=text(
            "nextval('nibrs_victim_circumstances_id_seq'::regclass)"))
    circumstances_id = db.Column(db.Integer,
                                 db.ForeignKey(
                                     'nibrs_circumstances.circumstances_id',
                                     deferrable=True,
                                     initially='DEFERRED'),
                                 nullable=False,
                                 index=True)
    justifiable_force_id = db.Column(
        db.Integer,
        db.ForeignKey('nibrs_justifiable_force.justifiable_force_id',
                      deferrable=True,
                      initially='DEFERRED'),
        index=True)
    victim_id = db.Column(db.Integer,
                          db.ForeignKey('nibrs_victim.victim_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)

    circumstances = db.relationship('NibrsCircumstance')
    justifiable_force = db.relationship('NibrsJustifiableForce')
    victim = db.relationship('NibrsVictim')


class NibrsVictimInjury(db.Model):
    __tablename__ = 'nibrs_victim_injury'
    __table_args__ = (UniqueConstraint('victim_id', 'injury_id'), )

    id = db.Column(
        db.Integer,
        primary_key=True,
        server_default=text("nextval('nibrs_victim_injury_id_seq'::regclass)"))
    injury_id = db.Column(db.Integer,
                          db.ForeignKey('nibrs_injury.injury_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)
    victim_id = db.Column(db.Integer,
                          db.ForeignKey('nibrs_victim.victim_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)

    injury = db.relationship('NibrsInjury')
    victim = db.relationship('NibrsVictim')


class NibrsVictimOffenderRel(db.Model):
    __tablename__ = 'nibrs_victim_offender_rel'

    nibrs_victim_offender_id = db.Column(db.BigInteger, primary_key=True)
    offender_id = db.Column(db.Integer,
                            db.ForeignKey('nibrs_offender.offender_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)
    relationship_id = db.Column(db.Integer,
                                db.ForeignKey(
                                    'nibrs_relationship.relationship_id',
                                    deferrable=True,
                                    initially='DEFERRED'),
                                nullable=False,
                                index=True)
    victim_id = db.Column(db.Integer,
                          db.ForeignKey('nibrs_victim.victim_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)

    offender = db.relationship('NibrsOffender')
    relationship_ = db.relationship('NibrsRelationship')
    victim = db.relationship('NibrsVictim')


class NibrsVictimOffense(db.Model):
    __tablename__ = 'nibrs_victim_offense'
    __table_args__ = (UniqueConstraint('victim_id', 'offense_id'), )

    id = db.Column(db.Integer,
                   primary_key=True,
                   server_default=text(
                       "nextval('nibrs_victim_offense_id_seq'::regclass)"))
    offense_id = db.Column(db.Integer,
                           db.ForeignKey('nibrs_offense.offense_id',
                                         deferrable=True,
                                         initially='DEFERRED'),
                           nullable=False,
                           index=True)
    victim_id = db.Column(db.Integer,
                          db.ForeignKey('nibrs_victim.victim_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)

    offense = db.relationship('NibrsOffense')
    victim = db.relationship('NibrsVictim')


class NibrsVictimType(db.Model):
    __tablename__ = 'nibrs_victim_type'

    victim_type_id = db.Column(db.SmallInteger, primary_key=True)
    victim_type_code = db.Column(db.String(1))
    victim_type_name = db.Column(db.String(100))


class NibrsWeapon(db.Model):
    __tablename__ = 'nibrs_weapon'

    nibrs_weapon_id = db.Column(db.BigInteger, primary_key=True)
    offense_id = db.Column(db.Integer,
                           db.ForeignKey('nibrs_offense.offense_id',
                                         deferrable=True,
                                         initially='DEFERRED'),
                           nullable=False,
                           index=True)
    weapon_id = db.Column(db.Integer,
                          db.ForeignKey('nibrs_weapon_type.weapon_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)

    offense = db.relationship('NibrsOffense')
    weapon = db.relationship('NibrsWeaponType')


class NibrsWeaponType(db.Model):
    __tablename__ = 'nibrs_weapon_type'

    weapon_id = db.Column(db.SmallInteger, primary_key=True)
    weapon_code = db.Column(db.String(3))
    weapon_name = db.Column(db.String(100))
    shr_flag = db.Column(db.String(1))


class OffenseClassification(db.Model):
    __tablename__ = 'offense_classification'

    classification_id = db.Column(db.SmallInteger, primary_key=True)
    classification_name = db.Column(db.String(50))
    class_sort_order = db.Column(db.SmallInteger)


class RefAgency(db.Model):
    __tablename__ = 'ref_agency'

    agency_id = db.Column(db.BigInteger, primary_key=True)
    ori = db.Column(db.String(9), nullable=False, unique=True)
    legacy_ori = db.Column(db.String(9), nullable=False)
    ucr_agency_name = db.Column(db.String(100))
    ncic_agency_name = db.Column(db.String(100))
    pub_agency_name = db.Column(db.String(100))
    special_mailing_group = db.Column(db.String(1))
    special_mailing_address = db.Column(db.String(1))
    agency_status = db.Column(db.String(1), nullable=False)
    judicial_dist_code = db.Column(db.String(4))
    fid_code = db.Column(db.String(2))
    added_date = db.Column(db.DateTime(True))
    change_timestamp = db.Column(db.DateTime(True))
    change_user = db.Column(db.String(100))
    legacy_notify_agency = db.Column(db.String(1))
    dormant_year = db.Column(db.SmallInteger)
    agency_type_id = db.Column(db.Integer,
                               db.ForeignKey('ref_agency_type.agency_type_id',
                                             deferrable=True,
                                             initially='DEFERRED'),
                               nullable=False,
                               index=True)
    campus_id = db.Column(db.Integer,
                          db.ForeignKey('ref_university_campus.campus_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          index=True)
    city_id = db.Column(db.Integer,
                        db.ForeignKey('ref_city.city_id',
                                      deferrable=True,
                                      initially='DEFERRED'),
                        index=True)
    department_id = db.Column(db.Integer,
                              db.ForeignKey('ref_department.department_id',
                                            deferrable=True,
                                            initially='DEFERRED'),
                              index=True)
    field_office_id = db.Column(
        db.Integer,
        db.ForeignKey('ref_field_office.field_office_id',
                      deferrable=True,
                      initially='DEFERRED'),
        index=True)
    population_family_id = db.Column(
        db.Integer,
        db.ForeignKey('ref_population_family.population_family_id',
                      deferrable=True,
                      initially='DEFERRED'),
        nullable=False,
        index=True)
    state_id = db.Column(db.Integer,
                         db.ForeignKey('ref_state.state_id',
                                       deferrable=True,
                                       initially='DEFERRED'),
                         nullable=False,
                         index=True)
    submitting_agency_id = db.Column(
        db.Integer,
        db.ForeignKey('ref_submitting_agency.agency_id',
                      deferrable=True,
                      initially='DEFERRED'),
        index=True)
    tribe_id = db.Column(db.Integer,
                         db.ForeignKey('ref_tribe.tribe_id',
                                       deferrable=True,
                                       initially='DEFERRED'),
                         index=True)

    agency_type = db.relationship('RefAgencyType')
    campus = db.relationship('RefUniversityCampu')
    city = db.relationship('RefCity')
    department = db.relationship('RefDepartment')
    field_office = db.relationship('RefFieldOffice')
    population_family = db.relationship('RefPopulationFamily')
    state = db.relationship('RefState')
    submitting_agency = db.relationship('RefSubmittingAgency')
    tribe = db.relationship('RefTribe')


class RefAgencyCounty(db.Model):
    __tablename__ = 'ref_agency_county'
    __table_args__ = (UniqueConstraint('agency_id', 'county_id',
                                       'metro_div_id', 'data_year'), )

    id = db.Column(
        db.Integer,
        primary_key=True,
        server_default=text("nextval('ref_agency_county_id_seq'::regclass)"))
    core_city_flag = db.Column(db.String(1))
    data_year = db.Column(db.SmallInteger, nullable=False)
    population = db.Column(db.BigInteger)
    census = db.Column(db.BigInteger)
    legacy_county_code = db.Column(db.String(20))
    legacy_msa_code = db.Column(db.String(20))
    source_flag = db.Column(db.String(1))
    change_timestamp = db.Column(db.DateTime(True))
    change_user = db.Column(db.String(100))
    agency_id = db.Column(db.Integer,
                          db.ForeignKey('ref_agency.agency_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)
    county_id = db.Column(db.Integer,
                          db.ForeignKey('ref_county.county_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)
    metro_div_id = db.Column(db.Integer,
                             db.ForeignKey('ref_metro_division.metro_div_id',
                                           deferrable=True,
                                           initially='DEFERRED'),
                             nullable=False,
                             index=True)

    agency = db.relationship('RefAgency')
    county = db.relationship('RefCounty')
    metro_div = db.relationship('RefMetroDivision')


class RefAgencyCoveredBy(db.Model):
    __tablename__ = 'ref_agency_covered_by'
    __table_args__ = (UniqueConstraint('agency_id', 'data_year'), )

    id = db.Column(db.Integer,
                   primary_key=True,
                   server_default=text(
                       "nextval('ref_agency_covered_by_id_seq'::regclass)"))
    data_year = db.Column(db.SmallInteger, nullable=False)
    agency_id = db.Column(db.Integer,
                          db.ForeignKey('ref_agency.agency_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)
    covered_by_agency_id = db.Column(db.Integer,
                                     db.ForeignKey('ref_agency.agency_id',
                                                   deferrable=True,
                                                   initially='DEFERRED'),
                                     nullable=False,
                                     index=True)

    agency = db.relationship(
        'RefAgency',
        primaryjoin='RefAgencyCoveredBy.agency_id == RefAgency.agency_id')
    covered_by_agency = db.relationship(
        'RefAgency',
        primaryjoin='RefAgencyCoveredBy.covered_by_agency_id == RefAgency.agency_id')


class RefAgencyDataContent(db.Model):
    __tablename__ = 'ref_agency_data_content'
    __table_args__ = (UniqueConstraint('agency_id', 'data_year'), )

    id = db.Column(db.Integer,
                   primary_key=True,
                   server_default=text(
                       "nextval('ref_agency_data_content_id_seq'::regclass)"))
    data_year = db.Column(db.SmallInteger, nullable=False)
    reporting_type = db.Column(db.String(1))
    nibrs_ct_flag = db.Column(db.String(1))
    nibrs_hc_flag = db.Column(db.String(1))
    nibrs_leoka_flag = db.Column(db.String(1))
    nibrs_arson_flag = db.Column(db.String(1))
    summary_rape_def = db.Column(db.String(1))
    nibrs_ht_flag = db.Column(db.String(1))
    agency_id = db.Column(db.Integer,
                          db.ForeignKey('ref_agency.agency_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)

    agency = db.relationship('RefAgency')


class RefAgencyPoc(db.Model):
    __tablename__ = 'ref_agency_poc'
    __table_args__ = (UniqueConstraint('agency_id', 'poc_id'), )

    id = db.Column(
        db.Integer,
        primary_key=True,
        server_default=text("nextval('ref_agency_poc_id_seq'::regclass)"))
    agency_id = db.Column(db.BigInteger, nullable=False)
    primary_poc_flag = db.Column(db.String(1))
    poc_id = db.Column(db.Integer,
                       db.ForeignKey('ref_poc.poc_id',
                                     deferrable=True,
                                     initially='DEFERRED'),
                       nullable=False,
                       index=True)

    poc = db.relationship('RefPoc')


class RefAgencyType(db.Model):
    __tablename__ = 'ref_agency_type'

    agency_type_id = db.Column(db.SmallInteger, primary_key=True)
    agency_type_name = db.Column(db.String(100))
    default_pop_family_id = db.Column(
        db.Integer,
        db.ForeignKey('ref_population_family.population_family_id',
                      deferrable=True,
                      initially='DEFERRED'),
        nullable=False,
        index=True)

    default_pop_family = db.relationship('RefPopulationFamily')


class RefCampusPopulation(db.Model):
    __tablename__ = 'ref_campus_population'
    __table_args__ = (UniqueConstraint('campus_id', 'data_year'), )

    id = db.Column(db.Integer,
                   primary_key=True,
                   server_default=text(
                       "nextval('ref_campus_population_id_seq'::regclass)"))
    data_year = db.Column(db.SmallInteger, nullable=False)
    population = db.Column(db.BigInteger)
    source_flag = db.Column(db.String(1), nullable=False)
    census = db.Column(db.BigInteger)
    change_timestamp = db.Column(db.DateTime(True))
    change_user = db.Column(db.String(100))
    reporting_population = db.Column(db.BigInteger)
    campus_id = db.Column(db.Integer,
                          db.ForeignKey('ref_university_campus.campus_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)

    campus = db.relationship('RefUniversityCampu')


class RefCity(db.Model):
    __tablename__ = 'ref_city'
    __table_args__ = (UniqueConstraint('city_name', 'state_id'), )

    city_id = db.Column(db.BigInteger, primary_key=True)
    city_name = db.Column(db.String(100))
    state_id = db.Column(db.Integer,
                         db.ForeignKey('ref_state.state_id',
                                       deferrable=True,
                                       initially='DEFERRED'),
                         nullable=False,
                         index=True)

    state = db.relationship('RefState')


class RefContinent(db.Model):
    __tablename__ = 'ref_continent'

    continent_id = db.Column(db.SmallInteger, primary_key=True)
    continent_desc = db.Column(db.String(50))


class RefCountry(db.Model):
    __tablename__ = 'ref_country'

    country_id = db.Column(db.SmallInteger, primary_key=True)
    country_desc = db.Column(db.String(50))
    continent_id = db.Column(db.Integer,
                             db.ForeignKey('ref_continent.continent_id',
                                           deferrable=True,
                                           initially='DEFERRED'),
                             nullable=False,
                             index=True)

    continent = db.relationship('RefContinent')


class RefCounty(db.Model):
    __tablename__ = 'ref_county'

    county_id = db.Column(db.BigInteger, primary_key=True)
    county_name = db.Column(db.String(100))
    county_ansi_code = db.Column(db.String(5))
    county_fips_code = db.Column(db.String(5))
    legacy_county_code = db.Column(db.String(5))
    comments = db.Column(db.String(1000))
    state_id = db.Column(db.Integer,
                         db.ForeignKey('ref_state.state_id',
                                       deferrable=True,
                                       initially='DEFERRED'),
                         nullable=False,
                         index=True)

    state = db.relationship('RefState')


class RefCountyPopulation(db.Model):
    __tablename__ = 'ref_county_population'
    __table_args__ = (UniqueConstraint('county_id', 'data_year'), )

    id = db.Column(db.Integer,
                   primary_key=True,
                   server_default=text(
                       "nextval('ref_county_population_id_seq'::regclass)"))
    data_year = db.Column(db.SmallInteger, nullable=False)
    population = db.Column(db.BigInteger)
    source_flag = db.Column(db.String(1), nullable=False)
    change_timestamp = db.Column(db.DateTime(True))
    change_user = db.Column(db.String(100))
    reporting_population = db.Column(db.BigInteger)
    county_id = db.Column(db.Integer,
                          db.ForeignKey('ref_county.county_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)

    county = db.relationship('RefCounty')


class RefDepartment(db.Model):
    __tablename__ = 'ref_department'

    department_id = db.Column(db.SmallInteger, primary_key=True)
    department_name = db.Column(db.String(100), nullable=False)
    active_flag = db.Column(db.String(1), nullable=False)
    sort_order = db.Column(db.SmallInteger)


class RefDivision(db.Model):
    __tablename__ = 'ref_division'

    division_id = db.Column(db.SmallInteger, primary_key=True)
    division_code = db.Column(db.String(2))
    division_name = db.Column(db.String(100))
    division_desc = db.Column(db.String(100))
    region_id = db.Column(db.Integer,
                          db.ForeignKey('ref_region.region_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)

    region = db.relationship('RefRegion')


class RefFieldOffice(db.Model):
    __tablename__ = 'ref_field_office'

    field_office_id = db.Column(db.BigInteger, primary_key=True)
    field_office_code = db.Column(db.String(10))
    field_office_name = db.Column(db.String(100))
    field_office_alpha_code = db.Column(db.String(2))
    field_office_numeric_code = db.Column(db.String(10))


class RefGlobalLocation(db.Model):
    __tablename__ = 'ref_global_location'

    global_location_id = db.Column(db.BigInteger, primary_key=True)
    global_location_desc = db.Column(db.String(50))
    country_id = db.Column(db.Integer,
                           db.ForeignKey('ref_country.country_id',
                                         deferrable=True,
                                         initially='DEFERRED'),
                           nullable=False,
                           index=True)

    country = db.relationship('RefCountry')


class RefMetroDivPopulation(db.Model):
    __tablename__ = 'ref_metro_div_population'
    __table_args__ = (UniqueConstraint('metro_div_id', 'data_year'), )

    id = db.Column(db.Integer,
                   primary_key=True,
                   server_default=text(
                       "nextval('ref_metro_div_population_id_seq'::regclass)"))
    data_year = db.Column(db.SmallInteger, nullable=False)
    population = db.Column(db.BigInteger)
    source_flag = db.Column(db.String(1), nullable=False)
    census = db.Column(db.BigInteger)
    change_timestamp = db.Column(db.DateTime(True))
    change_user = db.Column(db.String(100))
    reporting_population = db.Column(db.BigInteger)
    metro_div_id = db.Column(db.Integer,
                             db.ForeignKey('ref_metro_division.metro_div_id',
                                           deferrable=True,
                                           initially='DEFERRED'),
                             nullable=False,
                             index=True)

    metro_div = db.relationship('RefMetroDivision')


class RefMetroDivision(db.Model):
    __tablename__ = 'ref_metro_division'

    metro_div_id = db.Column(db.BigInteger, primary_key=True)
    metro_div_name = db.Column(db.String(100))
    msa_flag = db.Column(db.String(1))
    metro_div_omb_code = db.Column(db.String(5))
    legacy_msa_code = db.Column(db.String(5))
    msa_id = db.Column(db.Integer,
                       db.ForeignKey('ref_msa.msa_id',
                                     deferrable=True,
                                     initially='DEFERRED'),
                       nullable=False,
                       index=True)

    msa = db.relationship('RefMsa')


class RefMsa(db.Model):
    __tablename__ = 'ref_msa'
    __table_args__ = (UniqueConstraint('msa_name', 'msa_omb_code'), )

    msa_id = db.Column(db.BigInteger, primary_key=True)
    msa_name = db.Column(db.String(100))
    msa_omb_code = db.Column(db.String(5))


class RefParentPopulationGroup(db.Model):
    __tablename__ = 'ref_parent_population_group'

    parent_pop_group_id = db.Column(db.BigInteger, primary_key=True)
    parent_pop_group_code = db.Column(db.String(2))
    parent_pop_group_desc = db.Column(db.String(100))
    publication_name = db.Column(db.String(100))
    population_family_id = db.Column(
        db.Integer,
        db.ForeignKey('ref_population_family.population_family_id',
                      deferrable=True,
                      initially='DEFERRED'),
        nullable=False,
        index=True)

    population_family = db.relationship('RefPopulationFamily')


class RefPoc(db.Model):
    __tablename__ = 'ref_poc'

    poc_id = db.Column(db.BigInteger, primary_key=True)
    poc_name = db.Column(db.String(200))
    poc_title = db.Column(db.String(200))
    poc_email = db.Column(db.String(200))
    poc_phone1 = db.Column(db.String(50))
    poc_phone2 = db.Column(db.String(50))
    mailing_address_1 = db.Column(db.String(150))
    mailing_address_2 = db.Column(db.String(150))
    mailing_address_3 = db.Column(db.String(150))
    mailing_address_4 = db.Column(db.String(150))
    zip_code = db.Column(db.String(10))
    city_name = db.Column(db.String(100))
    poc_fax1 = db.Column(db.String(20))
    poc_fax2 = db.Column(db.String(20))
    state_id = db.Column(db.Integer,
                         db.ForeignKey('ref_state.state_id',
                                       deferrable=True,
                                       initially='DEFERRED'),
                         index=True)

    state = db.relationship('RefState')


class RefPocRole(db.Model):
    __tablename__ = 'ref_poc_role'

    poc_role_id = db.Column(db.SmallInteger, primary_key=True)
    poc_role_name = db.Column(db.String(100))


class RefPocRoleAssign(db.Model):
    __tablename__ = 'ref_poc_role_assign'
    __table_args__ = (UniqueConstraint('poc_id', 'poc_role_id'), )

    id = db.Column(
        db.Integer,
        primary_key=True,
        server_default=text("nextval('ref_poc_role_assign_id_seq'::regclass)"))
    poc_id = db.Column(db.Integer,
                       db.ForeignKey('ref_poc.poc_id',
                                     deferrable=True,
                                     initially='DEFERRED'),
                       nullable=False,
                       index=True)
    poc_role_id = db.Column(db.Integer,
                            db.ForeignKey('ref_poc_role.poc_role_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)

    poc = db.relationship('RefPoc')
    poc_role = db.relationship('RefPocRole')


class RefPopulationFamily(db.Model):
    __tablename__ = 'ref_population_family'

    population_family_id = db.Column(db.SmallInteger, primary_key=True)
    population_family_name = db.Column(db.String(100))
    population_family_desc = db.Column(db.String(200))
    sort_order = db.Column(db.SmallInteger)


class RefPopulationGroup(db.Model):
    __tablename__ = 'ref_population_group'

    population_group_id = db.Column(db.BigInteger, primary_key=True)
    population_group_code = db.Column(db.String(2))
    population_group_desc = db.Column(db.String(150))
    publication_name = db.Column(db.String(100))
    parent_pop_group_id = db.Column(
        db.Integer,
        db.ForeignKey('ref_parent_population_group.parent_pop_group_id',
                      deferrable=True,
                      initially='DEFERRED'),
        nullable=False,
        index=True)

    parent_pop_group = db.relationship('RefParentPopulationGroup')


class RefRace(db.Model):
    __tablename__ = 'ref_race'

    race_id = db.Column(db.SmallInteger, primary_key=True)
    race_code = db.Column(db.String(2), nullable=False, unique=True)
    race_desc = db.Column(db.String(100), nullable=False)
    sort_order = db.Column(db.SmallInteger)
    start_year = db.Column(db.SmallInteger)
    end_year = db.Column(db.SmallInteger)
    notes = db.Column(db.String(1000))


class RefRegion(db.Model):
    __tablename__ = 'ref_region'

    region_id = db.Column(db.SmallInteger, primary_key=True)
    region_code = db.Column(db.String(2))
    region_name = db.Column(db.String(100))
    region_desc = db.Column(db.String(100))


class RefState(db.Model):
    __tablename__ = 'ref_state'

    state_id = db.Column(db.SmallInteger, primary_key=True)
    state_name = db.Column(db.String(100))
    state_code = db.Column(db.String(2))
    state_abbr = db.Column(db.String(2))
    state_postal_abbr = db.Column(db.String(2))
    state_fips_code = db.Column(db.String(2))
    state_pub_freq_months = db.Column(db.SmallInteger)
    division_id = db.Column(db.Integer,
                            db.ForeignKey('ref_division.division_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)

    division = db.relationship('RefDivision')


class RefSubmittingAgency(db.Model):
    __tablename__ = 'ref_submitting_agency'

    agency_id = db.Column(db.BigInteger, primary_key=True)
    sai = db.Column(db.String(9))
    agency_name = db.Column(db.String(150))
    notify_agency = db.Column(db.String(1))
    agency_email = db.Column(db.String(200))
    agency_website = db.Column(db.String(2000))
    comments = db.Column(db.String(2000))
    state_id = db.Column(db.Integer,
                         db.ForeignKey('ref_state.state_id',
                                       deferrable=True,
                                       initially='DEFERRED'),
                         index=True)

    state = db.relationship('RefState')


class RefTribe(db.Model):
    __tablename__ = 'ref_tribe'

    tribe_id = db.Column(db.BigInteger, primary_key=True)
    tribe_name = db.Column(db.String(100), unique=True)


class RefTribePopulation(db.Model):
    __tablename__ = 'ref_tribe_population'
    __table_args__ = (UniqueConstraint('tribe_id', 'data_year'), )

    id = db.Column(db.Integer,
                   primary_key=True,
                   server_default=text(
                       "nextval('ref_tribe_population_id_seq'::regclass)"))
    data_year = db.Column(db.SmallInteger, nullable=False)
    population = db.Column(db.BigInteger)
    source_flag = db.Column(db.String(1), nullable=False)
    census = db.Column(db.BigInteger)
    change_timestamp = db.Column(db.DateTime(True))
    change_user = db.Column(db.String(100))
    reporting_population = db.Column(db.BigInteger)
    tribe_id = db.Column(db.Integer,
                         db.ForeignKey('ref_tribe.tribe_id',
                                       deferrable=True,
                                       initially='DEFERRED'),
                         nullable=False,
                         index=True)

    tribe = db.relationship('RefTribe')


class RefUniversity(db.Model):
    __tablename__ = 'ref_university'

    university_id = db.Column(db.BigInteger, primary_key=True)
    university_abbr = db.Column(db.String(20))
    university_name = db.Column(db.String(100), unique=True)


class RefUniversityCampu(db.Model):
    __tablename__ = 'ref_university_campus'

    campus_id = db.Column(db.BigInteger, primary_key=True)
    campus_name = db.Column(db.String(100))
    university_id = db.Column(db.Integer,
                              db.ForeignKey('ref_university.university_id',
                                            deferrable=True,
                                            initially='DEFERRED'),
                              nullable=False,
                              index=True)

    university = db.relationship('RefUniversity')


class RetaMonth(db.Model):
    __tablename__ = 'reta_month'
    __table_args__ = (UniqueConstraint('agency_id', 'data_year', 'month_num',
                                       'data_home', 'source_flag'), )

    reta_month_id = db.Column(db.BigInteger, primary_key=True)
    data_year = db.Column(db.SmallInteger, nullable=False)
    month_num = db.Column(db.SmallInteger, nullable=False)
    data_home = db.Column(db.String(1), nullable=False)
    source_flag = db.Column(db.String(1), nullable=False)
    reported_flag = db.Column(db.String(1), nullable=False)
    ddocname = db.Column(db.String(100))
    month_included_in = db.Column(db.SmallInteger)
    report_date = db.Column(db.DateTime(True))
    prepared_date = db.Column(db.DateTime(True))
    prepared_by_user = db.Column(db.String(100))
    prepared_by_email = db.Column(db.String(200))
    orig_format = db.Column(db.String(1), nullable=False)
    total_reported_count = db.Column(db.Integer)
    total_unfounded_count = db.Column(db.Integer)
    total_actual_count = db.Column(db.Integer)
    total_cleared_count = db.Column(db.Integer)
    total_juvenile_cleared_count = db.Column(db.Integer)
    leoka_felony = db.Column(db.SmallInteger)
    leoka_accident = db.Column(db.SmallInteger)
    leoka_assault = db.Column(db.Integer)
    leoka_status = db.Column(db.SmallInteger)
    update_flag = db.Column(db.String(1))
    did = db.Column(db.BigInteger)
    ff_line_number = db.Column(db.BigInteger)
    agency_id = db.Column(db.Integer,
                          db.ForeignKey('ref_agency.agency_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)

    agency = db.relationship('RefAgency')


class RetaMonthOffenseSubcat(db.Model):
    __tablename__ = 'reta_month_offense_subcat'
    __table_args__ = (UniqueConstraint('offense_subcat_id', 'reta_month_id'), )

    id = db.Column(
        db.Integer,
        primary_key=True,
        server_default=text(
            "nextval('reta_month_offense_subcat_id_seq'::regclass)"))
    reported_count = db.Column(db.Integer)
    reported_status = db.Column(db.SmallInteger)
    unfounded_count = db.Column(db.Integer)
    unfounded_status = db.Column(db.SmallInteger)
    actual_count = db.Column(db.Integer)
    actual_status = db.Column(db.SmallInteger)
    cleared_count = db.Column(db.Integer)
    cleared_status = db.Column(db.SmallInteger)
    juvenile_cleared_count = db.Column(db.Integer)
    juvenile_cleared_status = db.Column(db.SmallInteger)
    offense_subcat_id = db.Column(db.Integer,
                                  db.ForeignKey(
                                      'reta_offense_subcat.offense_subcat_id',
                                      deferrable=True,
                                      initially='DEFERRED'),
                                  nullable=False,
                                  index=True)
    reta_month_id = db.Column(db.Integer,
                              db.ForeignKey('reta_month.reta_month_id',
                                            deferrable=True,
                                            initially='DEFERRED'),
                              nullable=False,
                              index=True)

    offense_subcat = db.relationship('RetaOffenseSubcat')
    reta_month = db.relationship('RetaMonth')


class RetaOffense(db.Model):
    __tablename__ = 'reta_offense'

    offense_id = db.Column(db.BigInteger, primary_key=True)
    offense_name = db.Column(db.String(100), nullable=False)
    offense_code = db.Column(db.String(20), nullable=False, unique=True)
    offense_xml_path = db.Column(db.String(1000))
    offense_sort_order = db.Column(db.BigInteger)
    classification_id = db.Column(
        db.Integer,
        db.ForeignKey('offense_classification.classification_id',
                      deferrable=True,
                      initially='DEFERRED'),
        index=True)
    offense_category_id = db.Column(
        db.Integer,
        db.ForeignKey('reta_offense_category.offense_category_id',
                      deferrable=True,
                      initially='DEFERRED'),
        nullable=False,
        index=True)

    classification = db.relationship('OffenseClassification')
    offense_category = db.relationship('RetaOffenseCategory')


class RetaOffenseCategory(db.Model):
    __tablename__ = 'reta_offense_category'

    offense_category_id = db.Column(db.SmallInteger, primary_key=True)
    offense_category_name = db.Column(db.String(50))
    offense_category_sort_order = db.Column(db.SmallInteger, nullable=False)
    crime_type_id = db.Column(db.Integer,
                              db.ForeignKey('crime_type.crime_type_id',
                                            deferrable=True,
                                            initially='DEFERRED'),
                              nullable=False,
                              index=True)

    crime_type = db.relationship('CrimeType')


class RetaOffenseSubcat(db.Model):
    __tablename__ = 'reta_offense_subcat'

    offense_subcat_id = db.Column(db.BigInteger, primary_key=True)
    offense_subcat_name = db.Column(db.String(100), nullable=False)
    offense_subcat_code = db.Column(db.String(20), nullable=False, unique=True)
    offense_subcat_xml_path = db.Column(db.String(1000))
    offense_subcat_sort_order = db.Column(db.BigInteger)
    part = db.Column(db.String(1))
    crime_index_flag = db.Column(db.String(1))
    offense_id = db.Column(db.Integer,
                           db.ForeignKey('reta_offense.offense_id',
                                         deferrable=True,
                                         initially='DEFERRED'),
                           nullable=False,
                           index=True)

    offense = db.relationship('RetaOffense')


class ShrCircumstance(db.Model):
    __tablename__ = 'shr_circumstances'

    circumstances_id = db.Column(db.SmallInteger, primary_key=True)
    circumstances_code = db.Column(db.String(2), nullable=False)
    sub_code = db.Column(db.String(1))
    circumstances_name = db.Column(db.String(100), nullable=False)
    sub_name = db.Column(db.String(100))
    current_flag = db.Column(db.String(1))


class ShrIncident(db.Model):
    __tablename__ = 'shr_incident'
    __table_args__ = (
        UniqueConstraint('shr_month_id', 'incident_num', 'data_home'), )

    incident_id = db.Column(db.BigInteger, primary_key=True)
    homicide_code = db.Column(db.String(1))
    incident_num = db.Column(db.String(3))
    incident_status = db.Column(db.SmallInteger)
    update_flag = db.Column(db.String(1))
    data_home = db.Column(db.String(1))
    prepared_date = db.Column(db.DateTime(True))
    report_date = db.Column(db.DateTime(True))
    ddocname = db.Column(db.String(100))
    ff_line_number = db.Column(db.BigInteger)
    orig_format = db.Column(db.String(1))
    did = db.Column(db.BigInteger)
    nibrs_incident_id = db.Column(db.BigInteger)
    shr_month_id = db.Column(db.Integer,
                             db.ForeignKey('shr_month.shr_month_id',
                                           deferrable=True,
                                           initially='DEFERRED'),
                             nullable=False,
                             index=True)
    situation_id = db.Column(db.Integer,
                             db.ForeignKey('shr_situation.situation_id',
                                           deferrable=True,
                                           initially='DEFERRED'),
                             nullable=False,
                             index=True)

    shr_month = db.relationship('ShrMonth')
    situation = db.relationship('ShrSituation')


class ShrMonth(db.Model):
    __tablename__ = 'shr_month'
    __table_args__ = (
        UniqueConstraint('agency_id', 'data_year', 'month_num', 'data_home'), )

    shr_month_id = db.Column(db.BigInteger, primary_key=True)
    data_year = db.Column(db.SmallInteger, nullable=False)
    month_num = db.Column(db.SmallInteger, nullable=False)
    data_home = db.Column(db.String(1), nullable=False)
    source_flag = db.Column(db.String(1))
    reported_flag = db.Column(db.String(1))
    orig_format = db.Column(db.String(1))
    update_flag = db.Column(db.String(1))
    ff_line_number = db.Column(db.BigInteger)
    ddocname = db.Column(db.String(100))
    did = db.Column(db.BigInteger)
    agency_id = db.Column(db.Integer,
                          db.ForeignKey('ref_agency.agency_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)

    agency = db.relationship('RefAgency')


class ShrOffender(db.Model):
    __tablename__ = 'shr_offender'

    offender_id = db.Column(db.BigInteger, primary_key=True)
    offender_num = db.Column(db.String(20))
    age_num = db.Column(db.SmallInteger)
    sex_code = db.Column(db.String(1))
    nibrs_offense_id = db.Column(db.BigInteger)
    nibrs_offender_id = db.Column(db.BigInteger)
    age_id = db.Column(db.Integer,
                       db.ForeignKey('nibrs_age.age_id',
                                     deferrable=True,
                                     initially='DEFERRED'),
                       index=True)
    ethnicity_id = db.Column(db.Integer,
                             db.ForeignKey('nibrs_ethnicity.ethnicity_id',
                                           deferrable=True,
                                           initially='DEFERRED'),
                             index=True)
    race_id = db.Column(db.Integer,
                        db.ForeignKey('ref_race.race_id',
                                      deferrable=True,
                                      initially='DEFERRED'),
                        index=True)

    age = db.relationship('NibrsAge')
    ethnicity = db.relationship('NibrsEthnicity')
    race = db.relationship('RefRace')


class ShrOffense(db.Model):
    __tablename__ = 'shr_offense'

    offense_id = db.Column(db.BigInteger, primary_key=True)
    nibrs_offense_id = db.Column(db.BigInteger)
    circumstances_id = db.Column(
        db.Integer,
        db.ForeignKey('shr_circumstances.circumstances_id',
                      deferrable=True,
                      initially='DEFERRED'),
        index=True)
    incident_id = db.Column(db.Integer,
                            db.ForeignKey('shr_incident.incident_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)
    offender_id = db.Column(db.Integer,
                            db.ForeignKey('shr_offender.offender_id',
                                          deferrable=True,
                                          initially='DEFERRED'),
                            nullable=False,
                            index=True)
    relationship_id = db.Column(
        db.Integer,
        db.ForeignKey('shr_relationship.relationship_id',
                      deferrable=True,
                      initially='DEFERRED'),
        index=True)
    victim_id = db.Column(db.Integer,
                          db.ForeignKey('shr_victim.victim_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)
    weapon_id = db.Column(db.Integer,
                          db.ForeignKey('nibrs_weapon_type.weapon_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          index=True)

    circumstances = db.relationship('ShrCircumstance')
    incident = db.relationship('ShrIncident')
    offender = db.relationship('ShrOffender')
    relationship_ = db.relationship('ShrRelationship')
    victim = db.relationship('ShrVictim')
    weapon = db.relationship('NibrsWeaponType')


class ShrRelationship(db.Model):
    __tablename__ = 'shr_relationship'

    relationship_id = db.Column(db.SmallInteger, primary_key=True)
    relationship_code = db.Column(db.String(2))
    relationship_name = db.Column(db.String(100))


class ShrSituation(db.Model):
    __tablename__ = 'shr_situation'

    situation_id = db.Column(db.SmallInteger, primary_key=True)
    situation_code = db.Column(db.String(1))
    situation_name = db.Column(db.String(100))


class ShrVictim(db.Model):
    __tablename__ = 'shr_victim'

    victim_id = db.Column(db.BigInteger, primary_key=True)
    victim_num = db.Column(db.String(20))
    age_num = db.Column(db.SmallInteger)
    sex_code = db.Column(db.String(1))
    nibrs_victim_id = db.Column(db.BigInteger)
    nibrs_offense_id = db.Column(db.BigInteger)
    age_id = db.Column(db.Integer,
                       db.ForeignKey('nibrs_age.age_id',
                                     deferrable=True,
                                     initially='DEFERRED'),
                       index=True)
    ethnicity_id = db.Column(db.Integer,
                             db.ForeignKey('nibrs_ethnicity.ethnicity_id',
                                           deferrable=True,
                                           initially='DEFERRED'),
                             index=True)
    race_id = db.Column(db.Integer,
                        db.ForeignKey('ref_race.race_id',
                                      deferrable=True,
                                      initially='DEFERRED'),
                        index=True)

    age = db.relationship('NibrsAge')
    ethnicity = db.relationship('NibrsEthnicity')
    race = db.relationship('RefRace')


class SuppLarcenyType(db.Model):
    __tablename__ = 'supp_larceny_type'

    larceny_type_id = db.Column(db.BigInteger, primary_key=True)
    larceny_type_name = db.Column(db.String(100), nullable=False)
    larceny_type_code = db.Column(db.String(20), nullable=False)
    larceny_xml_name = db.Column(db.String(100))


class SuppMonth(db.Model):
    __tablename__ = 'supp_month'
    __table_args__ = (
        UniqueConstraint('agency_id', 'data_year', 'month_num', 'data_home'), )

    supp_month_id = db.Column(db.BigInteger, primary_key=True)
    data_year = db.Column(db.SmallInteger, nullable=False)
    month_num = db.Column(db.SmallInteger, nullable=False)
    data_home = db.Column(db.String(1), nullable=False)
    source_flag = db.Column(db.String(1))
    reported_flag = db.Column(db.String(1), nullable=False)
    report_date = db.Column(db.DateTime(True))
    prepared_date = db.Column(db.DateTime(True))
    ddocname = db.Column(db.String(100))
    orig_format = db.Column(db.String(1), nullable=False)
    mv_stolen_local_rec_local = db.Column(db.BigInteger)
    mv_stolen_local_rec_other = db.Column(db.BigInteger)
    mv_tot_local_stolen_rec = db.Column(db.BigInteger)
    mv_stolen_other_rec_local = db.Column(db.BigInteger)
    mv_stolen_status = db.Column(db.SmallInteger)
    update_flag = db.Column(db.String(1))
    did = db.Column(db.BigInteger)
    ff_line_number = db.Column(db.BigInteger)
    agency_id = db.Column(db.Integer,
                          db.ForeignKey('ref_agency.agency_id',
                                        deferrable=True,
                                        initially='DEFERRED'),
                          nullable=False,
                          index=True)

    agency = db.relationship('RefAgency')


class SuppOffense(db.Model):
    __tablename__ = 'supp_offense'

    offense_id = db.Column(db.BigInteger, primary_key=True)
    offense_name = db.Column(db.String(100), nullable=False)
    offense_code = db.Column(db.String(20), nullable=False)


class SuppOffenseSubcat(db.Model):
    __tablename__ = 'supp_offense_subcat'

    offense_subcat_id = db.Column(db.BigInteger, primary_key=True)
    offense_subcat_name = db.Column(db.String(100), nullable=False)
    offense_subcat_code = db.Column(db.String(20), nullable=False)
    offense_subcat_xml_name = db.Column(db.String(100))
    offense_id = db.Column(db.Integer,
                           db.ForeignKey('supp_offense.offense_id',
                                         deferrable=True,
                                         initially='DEFERRED'),
                           nullable=False,
                           index=True)

    offense = db.relationship('SuppOffense')


class SuppPropByOffenseSubcat(db.Model):
    __tablename__ = 'supp_prop_by_offense_subcat'
    __table_args__ = (UniqueConstraint('supp_month_id', 'offense_subcat_id'), )

    id = db.Column(
        db.Integer,
        primary_key=True,
        server_default=text(
            "nextval('supp_prop_by_offense_subcat_id_seq'::regclass)"))
    actual_count = db.Column(db.Integer)
    actual_status = db.Column(db.SmallInteger)
    stolen_value = db.Column(db.BigInteger)
    stolen_value_status = db.Column(db.SmallInteger)
    offense_subcat_id = db.Column(db.Integer,
                                  db.ForeignKey(
                                      'supp_offense_subcat.offense_subcat_id',
                                      deferrable=True,
                                      initially='DEFERRED'),
                                  nullable=False,
                                  index=True)
    supp_month_id = db.Column(db.Integer,
                              db.ForeignKey('supp_month.supp_month_id',
                                            deferrable=True,
                                            initially='DEFERRED'),
                              nullable=False,
                              index=True)

    offense_subcat = db.relationship('SuppOffenseSubcat')
    supp_month = db.relationship('SuppMonth')


class SuppPropertyByTypeValue(db.Model):
    __tablename__ = 'supp_property_by_type_value'
    __table_args__ = (UniqueConstraint('prop_type_id', 'supp_month_id'), )

    id = db.Column(
        db.Integer,
        primary_key=True,
        server_default=text(
            "nextval('supp_property_by_type_value_id_seq'::regclass)"))
    stolen_value = db.Column(db.BigInteger)
    stolen_value_status = db.Column(db.SmallInteger)
    recovered_value = db.Column(db.BigInteger)
    recovered_value_status = db.Column(db.SmallInteger)
    prop_type_id = db.Column(db.Integer,
                             db.ForeignKey('supp_property_type.prop_type_id',
                                           deferrable=True,
                                           initially='DEFERRED'),
                             nullable=False,
                             index=True)
    supp_month_id = db.Column(db.Integer,
                              db.ForeignKey('supp_month.supp_month_id',
                                            deferrable=True,
                                            initially='DEFERRED'),
                              nullable=False,
                              index=True)

    prop_type = db.relationship('SuppPropertyType')
    supp_month = db.relationship('SuppMonth')


class SuppPropertyType(db.Model):
    __tablename__ = 'supp_property_type'

    prop_type_id = db.Column(db.BigInteger, primary_key=True)
    prop_type_name = db.Column(db.String(100), nullable=False)
    prop_type_code = db.Column(db.String(20), nullable=False)
    prop_type_code_num = db.Column(db.SmallInteger, nullable=False)


class QueryWithAggregates(object):

    OPERATION = func.sum
    seed_label = None
    seed_agg = func.sum

    def _sql_name(self, readable_name):
        return self.COL_NAME_MAP.get(readable_name, readable_name)

    def _col(self, readable_name):
        for tbl in self.tables:
            try:
                result = getattr(tbl, self._sql_name(readable_name))
                return result
            except AttributeError:
                pass  # keep looking
        raise AttributeError()

    def _add_column(self, readable_name, operation=None):
        col = self._col(readable_name)
        if operation:
            col = operation(col)
        self.qry = self.qry.add_columns(label(readable_name, col))

    def _base_query(self):
        tbl = self.tables[0]
        col = getattr(tbl, self.seed_col)
        lbl = self.seed_label or self.seed_col
        labelled = label(lbl, self.seed_agg(col))
        return db.session.query(labelled)

    def _can_aggregate(self, col_name, aggregate):
        col = self._col(col_name)
        types = [c.type.python_type for c in col.prop.columns]
        if types in ([int, ], [float, ], [Decimal, ]):
            return True
        if (types in ([datetime.datetime, ], [datetime.date, ]) and
                aggregate in (func.min, func.max)):
            return True
        return False

    def __init__(self, aggregated=None, grouped=None):
        if grouped in (['none', None]):
            grouped = []
        aggregated = aggregated or []
        self.qry = self._base_query()
        for tbl in self.tables[1:]:
            self.qry = self.qry.join(tbl)
        for col in aggregated:
            if not isinstance(col, str):
                (col, operation) = col
            else:
                operation = self.OPERATION
            if self._can_aggregate(col, operation):
                self._add_column(col, operation)
            else:
                grouped.append(col)
        for col_name in grouped:
            self._add_column(col_name)
            col = self._col(col_name)
            self.qry = self.qry.group_by(col).order_by(col)
        print(self.qry)


class RetaMonthQuery(QueryWithAggregates):

    COL_NAME_MAP = {'year': 'data_year',
                    'state': 'state_abbr',
                    'offense': 'offense_subcat_name'}
    tables = [RetaMonth, RefAgency, RefState, RetaMonthOffenseSubcat,
              RetaOffenseSubcat]
    seed_col = 'total_actual_count'

"""
