# coding: utf-8
from sqlalchemy import BigInteger, Boolean, Column, DateTime, Float, ForeignKey, Integer, SmallInteger, String, Text, UniqueConstraint, text
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base


Base = declarative_base()
metadata = Base.metadata

class ArsonMonth(Base):
    __tablename__ = 'arson_month'
    __table_args__ = (
        UniqueConstraint('agency_id', 'data_year', 'month_num', 'data_home'),
    )

    arson_month_id = Column(BigInteger, primary_key=True)
    data_year = Column(SmallInteger, nullable=False)
    month_num = Column(SmallInteger, nullable=False)
    data_home = Column(String(1), nullable=False)
    source_flag = Column(String(1), nullable=False)
    reported_flag = Column(String(1))
    ddocname = Column(String(100))
    month_included_in = Column(SmallInteger)
    report_date = Column(DateTime(True))
    prepared_date = Column(DateTime(True))
    orig_format = Column(String(1))
    update_flag = Column(String(1))
    did = Column(BigInteger)
    ff_line_number = Column(BigInteger)
    agency_id = Column(ForeignKey('ref_agency.agency_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    agency = relationship('RefAgency')


class ArsonMonthBySubcat(Base):
    __tablename__ = 'arson_month_by_subcat'
    __table_args__ = (
        UniqueConstraint('arson_month_id', 'subcategory_id'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('arson_month_by_subcat_id_seq'::regclass)"))
    reported_count = Column(Integer)
    reported_status = Column(SmallInteger)
    unfounded_count = Column(Integer)
    unfounded_status = Column(SmallInteger)
    actual_count = Column(Integer)
    actual_status = Column(SmallInteger)
    cleared_count = Column(Integer)
    cleared_status = Column(SmallInteger)
    juvenile_cleared_count = Column(Integer)
    juvenile_cleared_status = Column(SmallInteger)
    uninhabited_count = Column(Integer)
    uninhabited_status = Column(SmallInteger)
    est_damage_value = Column(BigInteger)
    est_damage_value_status = Column(SmallInteger)
    arson_month_id = Column(ForeignKey('arson_month.arson_month_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    subcategory_id = Column(ForeignKey('arson_subcategory.subcategory_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    arson_month = relationship('ArsonMonth')
    subcategory = relationship('ArsonSubcategory')


class ArsonSubcategory(Base):
    __tablename__ = 'arson_subcategory'

    subcategory_id = Column(BigInteger, primary_key=True)
    subcategory_name = Column(String(100))
    subcategory_code = Column(String(20), unique=True)
    subcat_xml_path = Column(String(4000))
    subclass_id = Column(ForeignKey('arson_subclassification.subclass_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    subclass = relationship('ArsonSubclassification')


class ArsonSubclassification(Base):
    __tablename__ = 'arson_subclassification'

    subclass_id = Column(SmallInteger, primary_key=True)
    subclass_name = Column(String(100))
    subclass_code = Column(String(20), unique=True)
    subclass_xml_path = Column(String(4000))


class AsrAgeRange(Base):
    __tablename__ = 'asr_age_range'

    age_range_id = Column(BigInteger, primary_key=True)
    age_range_name = Column(String(20))
    age_range_code = Column(String(20), unique=True)
    juvenile_flag = Column(String(1), nullable=False)
    ff_sort_order = Column(String(3))
    age_sex = Column(String(1))
    xml_code = Column(String(2001))


class AsrAgeSexSubcat(Base):
    __tablename__ = 'asr_age_sex_subcat'
    __table_args__ = (
        UniqueConstraint('asr_month_id', 'offense_subcat_id', 'age_range_id'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('asr_age_sex_subcat_id_seq'::regclass)"))
    arrest_count = Column(Integer)
    arrest_status = Column(SmallInteger)
    active_flag = Column(String(1))
    prepared_date = Column(DateTime(True))
    report_date = Column(DateTime(True))
    ff_line_number = Column(BigInteger)
    age_range_id = Column(ForeignKey('asr_age_range.age_range_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    asr_month_id = Column(ForeignKey('asr_month.asr_month_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    offense_subcat_id = Column(ForeignKey('asr_offense_subcat.offense_subcat_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    age_range = relationship('AsrAgeRange')
    asr_month = relationship('AsrMonth')
    offense_subcat = relationship('AsrOffenseSubcat')


class AsrEthnicity(Base):
    __tablename__ = 'asr_ethnicity'

    ethnicity_id = Column(BigInteger, primary_key=True)
    ethnicity_name = Column(String(100))
    ethnicity_code = Column(String(20), unique=True)
    ff_sort_order = Column(String(3))


class AsrEthnicityOffense(Base):
    __tablename__ = 'asr_ethnicity_offense'
    __table_args__ = (
        UniqueConstraint('asr_month_id', 'offense_subcat_id', 'ethnicity_id', 'juvenile_flag'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('asr_ethnicity_offense_id_seq'::regclass)"))
    juvenile_flag = Column(String(1), nullable=False)
    arrest_count = Column(Integer)
    arrest_status = Column(SmallInteger)
    prepared_date = Column(DateTime(True))
    report_date = Column(DateTime(True))
    ff_line_number = Column(BigInteger)
    asr_month_id = Column(ForeignKey('asr_month.asr_month_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    ethnicity_id = Column(ForeignKey('asr_ethnicity.ethnicity_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    offense_subcat_id = Column(ForeignKey('asr_offense_subcat.offense_subcat_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    asr_month = relationship('AsrMonth')
    ethnicity = relationship('AsrEthnicity')
    offense_subcat = relationship('AsrOffenseSubcat')


class AsrMonth(Base):
    __tablename__ = 'asr_month'
    __table_args__ = (
        UniqueConstraint('agency_id', 'data_year', 'month_num', 'data_home'),
    )

    asr_month_id = Column(BigInteger, primary_key=True)
    data_year = Column(SmallInteger, nullable=False)
    month_num = Column(SmallInteger, nullable=False)
    source_flag = Column(String(1), nullable=False)
    reported_flag = Column(String(1))
    orig_format = Column(String(1))
    update_flag = Column(String(1))
    ff_line_number = Column(BigInteger)
    ddocname = Column(String(100))
    did = Column(BigInteger)
    data_home = Column(String(1), nullable=False)
    agency_id = Column(ForeignKey('ref_agency.agency_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    agency = relationship('RefAgency')


class AsrJuvenileDisposition(AsrMonth):
    __tablename__ = 'asr_juvenile_disposition'

    asr_month_id = Column(ForeignKey('asr_month.asr_month_id', deferrable=True, initially='DEFERRED'), primary_key=True)
    report_date = Column(DateTime(True))
    prepared_date = Column(DateTime(True))
    handled_within_dept = Column(Integer)
    juvenile_court = Column(Integer)
    welfare_agency = Column(Integer)
    other_police = Column(Integer)
    adult_court = Column(Integer)
    ff_line_number = Column(BigInteger)


class AsrOffense(Base):
    __tablename__ = 'asr_offense'

    offense_id = Column(BigInteger, primary_key=True)
    offense_name = Column(String(100))
    offense_code = Column(String(20), unique=True)
    total_flag = Column(String(1))
    offense_cat_id = Column(ForeignKey('asr_offense_category.offense_cat_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    offense_cat = relationship('AsrOffenseCategory')


class AsrOffenseCategory(Base):
    __tablename__ = 'asr_offense_category'

    offense_cat_id = Column(BigInteger, primary_key=True)
    offense_cat_name = Column(String(100))
    offense_cat_code = Column(String(20), unique=True)


class AsrOffenseSubcat(Base):
    __tablename__ = 'asr_offense_subcat'

    offense_subcat_id = Column(BigInteger, primary_key=True)
    offense_subcat_name = Column(String(100))
    offense_subcat_code = Column(String(20), unique=True)
    srs_offense_code = Column(String(3))
    master_offense_code = Column(SmallInteger)
    total_flag = Column(String(1))
    adult_juv_flag = Column(String(1))
    offense_id = Column(ForeignKey('asr_offense.offense_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    offense = relationship('AsrOffense')


class AsrRaceOffenseSubcat(Base):
    __tablename__ = 'asr_race_offense_subcat'
    __table_args__ = (
        UniqueConstraint('asr_month_id', 'offense_subcat_id', 'race_id', 'juvenile_flag'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('asr_race_offense_subcat_id_seq'::regclass)"))
    juvenile_flag = Column(String(1), nullable=False)
    arrest_count = Column(Integer)
    arrest_status = Column(SmallInteger)
    active_flag = Column(String(1))
    prepared_date = Column(DateTime(True))
    report_date = Column(DateTime(True))
    ff_line_number = Column(BigInteger)
    asr_month_id = Column(ForeignKey('asr_month.asr_month_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    offense_subcat_id = Column(ForeignKey('asr_offense_subcat.offense_subcat_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    race_id = Column(ForeignKey('ref_race.race_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    asr_month = relationship('AsrMonth')
    offense_subcat = relationship('AsrOffenseSubcat')
    race = relationship('RefRace')


class CrimeType(Base):
    __tablename__ = 'crime_type'

    crime_type_id = Column(SmallInteger, primary_key=True)
    crime_type_name = Column(String(50))
    crime_type_sort_order = Column(SmallInteger)
    crime_flag = Column(String(1))


class CtArrestee(Base):
    __tablename__ = 'ct_arrestee'

    arrestee_id = Column(BigInteger, primary_key=True)
    age = Column(SmallInteger)
    sex_code = Column(String(1))
    ethnicity_id = Column(ForeignKey('nibrs_ethnicity.ethnicity_id', deferrable=True, initially='DEFERRED'), index=True)
    incident_id = Column(ForeignKey('ct_incident.incident_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    race_id = Column(ForeignKey('ref_race.race_id', deferrable=True, initially='DEFERRED'), index=True)

    ethnicity = relationship('NibrsEthnicity')
    incident = relationship('CtIncident')
    race = relationship('RefRace')


class CtIncident(Base):
    __tablename__ = 'ct_incident'

    incident_id = Column(BigInteger, primary_key=True)
    data_year = Column(SmallInteger, nullable=False)
    incident_number = Column(String(15))
    incident_date = Column(DateTime(True))
    source_flag = Column(String(1), nullable=False)
    ddocname = Column(String(100))
    report_date = Column(DateTime(True))
    prepared_date = Column(DateTime(True))
    report_date_flag = Column(String(1))
    incident_hour = Column(SmallInteger)
    cleared_except_flag = Column(String(1))
    update_flag = Column(String(1))
    ff_line_number = Column(BigInteger)
    data_home = Column(String(1), nullable=False)
    orig_format = Column(String(1))
    unknown_offender = Column(String(1))
    did = Column(BigInteger)
    nibrs_incident_id = Column(BigInteger)
    agency_id = Column(ForeignKey('ref_agency.agency_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    ct_month_id = Column(ForeignKey('ct_month.ct_month_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    agency = relationship('RefAgency')
    ct_month = relationship('CtMonth')


class CtMonth(Base):
    __tablename__ = 'ct_month'

    ct_month_id = Column(BigInteger, primary_key=True)
    month_num = Column(SmallInteger, nullable=False)
    data_year = Column(SmallInteger, nullable=False)
    reported_status = Column(String(1))
    reported_count = Column(Integer)
    update_flag = Column(String(1))
    ff_line_number = Column(BigInteger)
    ddocname = Column(String(100))
    did = Column(BigInteger)
    data_home = Column(String(1), nullable=False)
    orig_format = Column(String(1))
    agency_id = Column(ForeignKey('ref_agency.agency_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    agency = relationship('RefAgency')


class CtOffender(Base):
    __tablename__ = 'ct_offender'

    offender_id = Column(BigInteger, primary_key=True)
    age = Column(SmallInteger)
    sex_code = Column(String(1))
    ethnicity_id = Column(ForeignKey('nibrs_ethnicity.ethnicity_id', deferrable=True, initially='DEFERRED'), index=True)
    incident_id = Column(ForeignKey('ct_incident.incident_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    race_id = Column(ForeignKey('ref_race.race_id', deferrable=True, initially='DEFERRED'), index=True)

    ethnicity = relationship('NibrsEthnicity')
    incident = relationship('CtIncident')
    race = relationship('RefRace')


class CtOffense(Base):
    __tablename__ = 'ct_offense'

    offense_id = Column(BigInteger, primary_key=True)
    ct_offense_flag = Column(String(1))
    incident_id = Column(ForeignKey('ct_incident.incident_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    location_id = Column(ForeignKey('nibrs_location_type.location_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    offense_type_id = Column(ForeignKey('nibrs_offense_type.offense_type_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    incident = relationship('CtIncident')
    location = relationship('NibrsLocationType')
    offense_type = relationship('NibrsOffenseType')


class CtProperty(Base):
    __tablename__ = 'ct_property'

    property_id = Column(BigInteger, primary_key=True)
    stolen_value = Column(BigInteger)
    recovered_flag = Column(String(1))
    date_recovered = Column(DateTime(True))
    recovered_value = Column(BigInteger)
    incident_id = Column(ForeignKey('ct_incident.incident_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    prop_desc_id = Column(ForeignKey('nibrs_prop_desc_type.prop_desc_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    incident = relationship('CtIncident')
    prop_desc = relationship('NibrsPropDescType')


class CtVictim(Base):
    __tablename__ = 'ct_victim'
    __table_args__ = (
        UniqueConstraint('incident_id', 'victim_type_id'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('ct_victim_id_seq'::regclass)"))
    incident_id = Column(ForeignKey('ct_incident.incident_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    victim_type_id = Column(ForeignKey('nibrs_victim_type.victim_type_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    incident = relationship('CtIncident')
    victim_type = relationship('NibrsVictimType')


class CtWeapon(Base):
    __tablename__ = 'ct_weapon'

    ct_weapon_id = Column(BigInteger, primary_key=True)
    incident_id = Column(ForeignKey('ct_incident.incident_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    weapon_id = Column(ForeignKey('nibrs_weapon_type.weapon_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    incident = relationship('CtIncident')
    weapon = relationship('NibrsWeaponType')

class HcBiasMotivation(Base):
    __tablename__ = 'hc_bias_motivation'
    __table_args__ = (
        UniqueConstraint('offense_id', 'bias_id'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('hc_bias_motivation_id_seq'::regclass)"))
    bias_id = Column(ForeignKey('nibrs_bias_list.bias_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    offense_id = Column(ForeignKey('hc_offense.offense_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    bias = relationship('NibrsBiasList')
    offense = relationship('HcOffense')


class HcIncident(Base):
    __tablename__ = 'hc_incident'

    incident_id = Column(BigInteger, primary_key=True)
    incident_no = Column(String(20))
    incident_date = Column(DateTime(True))
    data_home = Column(String(1))
    source_flag = Column(String(1))
    ddocname = Column(String(100))
    report_date = Column(DateTime(True))
    prepared_date = Column(DateTime(True))
    victim_count = Column(SmallInteger)
    adult_victim_count = Column(SmallInteger)
    incident_status = Column(SmallInteger)
    juvenile_victim_count = Column(SmallInteger)
    offender_count = Column(SmallInteger)
    adult_offender_count = Column(SmallInteger)
    juvenile_offender_count = Column(SmallInteger)
    update_flag = Column(String(1))
    ff_line_number = Column(BigInteger)
    orig_format = Column(String(1))
    did = Column(BigInteger)
    nibrs_incident_id = Column(BigInteger)
    agency_id = Column(ForeignKey('ref_agency.agency_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    hc_quarter_id = Column(ForeignKey('hc_quarter.hc_quarter_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    offender_ethnicity_id = Column(ForeignKey('nibrs_ethnicity.ethnicity_id', deferrable=True, initially='DEFERRED'), index=True)
    offender_race_id = Column(ForeignKey('ref_race.race_id', deferrable=True, initially='DEFERRED'), index=True)

    agency = relationship('RefAgency')
    hc_quarter = relationship('HcQuarter')
    offender_ethnicity = relationship('NibrsEthnicity')
    offender_race = relationship('RefRace')


class HcOffense(Base):
    __tablename__ = 'hc_offense'

    offense_id = Column(BigInteger, primary_key=True)
    victim_count = Column(SmallInteger)
    nibrs_offense_id = Column(BigInteger)
    incident_id = Column(ForeignKey('hc_incident.incident_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    location_id = Column(ForeignKey('nibrs_location_type.location_id', deferrable=True, initially='DEFERRED'), index=True)
    offense_type_id = Column(ForeignKey('nibrs_offense_type.offense_type_id', deferrable=True, initially='DEFERRED'), index=True)

    incident = relationship('HcIncident')
    location = relationship('NibrsLocationType')
    offense_type = relationship('NibrsOffenseType')


class HcQuarter(Base):
    __tablename__ = 'hc_quarter'
    __table_args__ = (
        UniqueConstraint('agency_id', 'quarter_num', 'data_year', 'data_home'),
    )

    quarter_num = Column(SmallInteger, nullable=False)
    data_year = Column(SmallInteger, nullable=False)
    reported_status = Column(String(1))
    reported_count = Column(BigInteger)
    hc_quarter_id = Column(BigInteger, primary_key=True)
    update_flag = Column(String(1))
    orig_format = Column(String(1))
    ff_line_number = Column(BigInteger)
    ddocname = Column(String(100))
    did = Column(BigInteger)
    data_home = Column(String(1), nullable=False)
    agency_id = Column(ForeignKey('ref_agency.agency_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    agency = relationship('RefAgency')


class HcVictim(Base):
    __tablename__ = 'hc_victim'
    __table_args__ = (
        UniqueConstraint('offense_id', 'victim_type_id'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('hc_victim_id_seq'::regclass)"))
    offense_id = Column(ForeignKey('hc_offense.offense_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    victim_type_id = Column(ForeignKey('nibrs_victim_type.victim_type_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    offense = relationship('HcOffense')
    victim_type = relationship('NibrsVictimType')


class HtMonth(Base):
    __tablename__ = 'ht_month'
    __table_args__ = (
        UniqueConstraint('agency_id', 'data_year', 'month_num', 'data_home'),
    )

    ht_month_id = Column(BigInteger, primary_key=True)
    data_year = Column(SmallInteger, nullable=False)
    month_num = Column(SmallInteger, nullable=False)
    data_home = Column(String(1), nullable=False)
    source_flag = Column(String(1), nullable=False)
    ddocname = Column(String(100))
    report_date = Column(DateTime(True))
    prepared_date = Column(DateTime(True))
    prepared_by_user = Column(String(100))
    prepared_by_email = Column(String(200))
    orig_format = Column(String(1), nullable=False)
    total_reported_count = Column(Integer)
    total_unfounded_count = Column(Integer)
    total_actual_count = Column(Integer)
    total_cleared_count = Column(Integer)
    total_juvenile_cleared_count = Column(Integer)
    update_flag = Column(String(1))
    reported_flag = Column(String(1))
    did = Column(BigInteger)
    ff_line_number = Column(BigInteger)
    agency_id = Column(ForeignKey('ref_agency.agency_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    agency = relationship('RefAgency')


class HtMonthOffenseSubcat(Base):
    __tablename__ = 'ht_month_offense_subcat'
    __table_args__ = (
        UniqueConstraint('offense_subcat_id', 'ht_month_id'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('ht_month_offense_subcat_id_seq'::regclass)"))
    reported_count = Column(Integer)
    reported_status = Column(SmallInteger)
    unfounded_count = Column(Integer)
    unfounded_status = Column(SmallInteger)
    actual_count = Column(Integer)
    actual_status = Column(SmallInteger)
    cleared_count = Column(Integer)
    cleared_status = Column(SmallInteger)
    juvenile_cleared_count = Column(Integer)
    juvenile_cleared_status = Column(SmallInteger)
    ht_month_id = Column(ForeignKey('ht_month.ht_month_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    offense_subcat_id = Column(ForeignKey('reta_offense_subcat.offense_subcat_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    ht_month = relationship('HtMonth')
    offense_subcat = relationship('RetaOffenseSubcat')


class NibrsActivityType(Base):
    __tablename__ = 'nibrs_activity_type'

    activity_type_id = Column(SmallInteger, primary_key=True)
    activity_type_code = Column(String(2))
    activity_type_name = Column(String(100))


class NibrsAge(Base):
    __tablename__ = 'nibrs_age'

    age_id = Column(SmallInteger, primary_key=True)
    age_code = Column(String(2))
    age_name = Column(String(100))


class NibrsArrestType(Base):
    __tablename__ = 'nibrs_arrest_type'

    arrest_type_id = Column(SmallInteger, primary_key=True)
    arrest_type_code = Column(String(1))
    arrest_type_name = Column(String(100))


class NibrsArrestee(Base):
    __tablename__ = 'nibrs_arrestee'

    arrestee_id = Column(BigInteger, primary_key=True)
    arrestee_seq_num = Column(BigInteger)
    arrest_num = Column(String(12))
    arrest_date = Column(DateTime(True))
    multiple_indicator = Column(String(1))
    age_num = Column(SmallInteger)
    sex_code = Column(String(1))
    resident_code = Column(String(1))
    under_18_disposition_code = Column(String(1))
    clearance_ind = Column(String(1))
    ff_line_number = Column(BigInteger)
    age_range_low_num = Column(SmallInteger)
    age_range_high_num = Column(SmallInteger)
    age_id = Column(ForeignKey('nibrs_age.age_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    arrest_type_id = Column(ForeignKey('nibrs_arrest_type.arrest_type_id', deferrable=True, initially='DEFERRED'), index=True)
    ethnicity_id = Column(ForeignKey('nibrs_ethnicity.ethnicity_id', deferrable=True, initially='DEFERRED'), index=True)
    incident_id = Column(ForeignKey('nibrs_incident.incident_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    offense_type_id = Column(ForeignKey('nibrs_offense_type.offense_type_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    race_id = Column(ForeignKey('ref_race.race_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    age = relationship('NibrsAge')
    arrest_type = relationship('NibrsArrestType')
    ethnicity = relationship('NibrsEthnicity')
    incident = relationship('NibrsIncident')
    offense_type = relationship('NibrsOffenseType')
    race = relationship('RefRace')


class NibrsArresteeWeapon(Base):
    __tablename__ = 'nibrs_arrestee_weapon'

    nibrs_arrestee_weapon_id = Column(BigInteger, primary_key=True)
    arrestee_id = Column(ForeignKey('nibrs_arrestee.arrestee_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    weapon_id = Column(ForeignKey('nibrs_weapon_type.weapon_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    arrestee = relationship('NibrsArrestee')
    weapon = relationship('NibrsWeaponType')


class NibrsAssignmentType(Base):
    __tablename__ = 'nibrs_assignment_type'

    assignment_type_id = Column(SmallInteger, primary_key=True)
    assignment_type_code = Column(String(1))
    assignment_type_name = Column(String(100))


class NibrsBiasList(Base):
    __tablename__ = 'nibrs_bias_list'

    bias_id = Column(SmallInteger, primary_key=True)
    bias_code = Column(String(2))
    bias_name = Column(String(100))


class NibrsBiasMotivation(Base):
    __tablename__ = 'nibrs_bias_motivation'
    __table_args__ = (
        UniqueConstraint('bias_id', 'offense_id'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('nibrs_bias_motivation_id_seq'::regclass)"))
    bias_id = Column(ForeignKey('nibrs_bias_list.bias_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    offense_id = Column(ForeignKey('nibrs_offense.offense_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    bias = relationship('NibrsBiasList')
    offense = relationship('NibrsOffense')


class NibrsCircumstance(Base):
    __tablename__ = 'nibrs_circumstances'

    circumstances_id = Column(SmallInteger, primary_key=True)
    circumstances_type = Column(String(1))
    circumstances_code = Column(SmallInteger)
    circumstances_name = Column(String(100))


class NibrsClearedExcept(Base):
    __tablename__ = 'nibrs_cleared_except'

    cleared_except_id = Column(SmallInteger, primary_key=True)
    cleared_except_code = Column(String(1))
    cleared_except_name = Column(String(100))


class NibrsCriminalAct(Base):
    __tablename__ = 'nibrs_criminal_act'
    __table_args__ = (
        UniqueConstraint('criminal_act_id', 'offense_id'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('nibrs_criminal_act_id_seq'::regclass)"))
    criminal_act_id = Column(ForeignKey('nibrs_criminal_act_type.criminal_act_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    offense_id = Column(ForeignKey('nibrs_offense.offense_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    criminal_act = relationship('NibrsCriminalActType')
    offense = relationship('NibrsOffense')


class NibrsCriminalActType(Base):
    __tablename__ = 'nibrs_criminal_act_type'

    criminal_act_id = Column(SmallInteger, primary_key=True)
    criminal_act_code = Column(String(1))
    criminal_act_name = Column(String(100))


class NibrsDrugMeasureType(Base):
    __tablename__ = 'nibrs_drug_measure_type'

    drug_measure_type_id = Column(SmallInteger, primary_key=True)
    drug_measure_code = Column(String(2))
    drug_measure_name = Column(String(100))


class NibrsEd(Base):
    __tablename__ = 'nibrs_eds'

    id = Column(Integer, primary_key=True, server_default=text("nextval('nibrs_eds_id_seq'::regclass)"))
    ddocname = Column(String(100))
    data_year = Column(SmallInteger)
    month_num = Column(SmallInteger)
    relative_rec_num = Column(Integer)
    segment_action_type = Column(String(1))
    ori = Column(String(9))
    incident_num = Column(String(12))
    level = Column(String(1))
    offense_code = Column(String(3))
    person_seq_num = Column(String(3))
    type_prop_loss = Column(String(1))
    data_element_num = Column(String(3))
    error_num = Column(SmallInteger)
    data_field = Column(String(12))
    error_msg = Column(String(79))
    submission_ser_num = Column(Integer)


class NibrsEthnicity(Base):
    __tablename__ = 'nibrs_ethnicity'

    ethnicity_id = Column(SmallInteger, primary_key=True)
    ethnicity_code = Column(String(1))
    ethnicity_name = Column(String(100))
    hc_flag = Column(String(1))


class NibrsGrpbArrest(Base):
    __tablename__ = 'nibrs_grpb_arrest'

    grpb_arrest_id = Column(BigInteger, primary_key=True)
    arrest_num = Column(String(15))
    arrest_date = Column(DateTime(True))
    arrest_seq_num = Column(SmallInteger)
    city = Column(String(4))
    arrest_type_id = Column(SmallInteger)
    offense_type_id = Column(BigInteger)
    sex_code = Column(String(1))
    resident_code = Column(String(1))
    under_18_disposition_code = Column(String(1))
    age_num = Column(SmallInteger)
    arrest_year = Column(SmallInteger)
    ff_line_number = Column(BigInteger)
    data_home = Column(String(1))
    ddocname = Column(String(100))
    did = Column(BigInteger)
    age_range_low_num = Column(SmallInteger)
    age_range_high_num = Column(SmallInteger)
    age_id = Column(ForeignKey('nibrs_age.age_id', deferrable=True, initially='DEFERRED'), index=True)
    agency_id = Column(ForeignKey('ref_agency.agency_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    ethnicity_id = Column(ForeignKey('nibrs_ethnicity.ethnicity_id', deferrable=True, initially='DEFERRED'), index=True)
    nibrs_month_id = Column(ForeignKey('nibrs_month.nibrs_month_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    race_id = Column(ForeignKey('ref_race.race_id', deferrable=True, initially='DEFERRED'), index=True)

    age = relationship('NibrsAge')
    agency = relationship('RefAgency')
    ethnicity = relationship('NibrsEthnicity')
    nibrs_month = relationship('NibrsMonth')
    race = relationship('RefRace')


class NibrsGrpbArrestWeapon(Base):
    __tablename__ = 'nibrs_grpb_arrest_weapon'

    nibrs_grpb_arrest_weapon_id = Column(BigInteger, primary_key=True)
    grpb_arrest_id = Column(ForeignKey('nibrs_grpb_arrest.grpb_arrest_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    weapon_id = Column(ForeignKey('nibrs_weapon_type.weapon_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    grpb_arrest = relationship('NibrsGrpbArrest')
    weapon = relationship('NibrsWeaponType')


class NibrsIncident(Base):
    __tablename__ = 'nibrs_incident'

    incident_id = Column(BigInteger, primary_key=True)
    incident_number = Column(String(15))
    cargo_theft_flag = Column(String(1))
    submission_date = Column(DateTime(True))
    incident_date = Column(DateTime(True))
    report_date_flag = Column(String(1))
    incident_hour = Column(SmallInteger)
    cleared_except_date = Column(DateTime(True))
    incident_status = Column(SmallInteger)
    data_home = Column(String(1))
    ddocname = Column(String(100))
    orig_format = Column(String(1))
    ff_line_number = Column(BigInteger)
    did = Column(BigInteger)
    agency_id = Column(ForeignKey('ref_agency.agency_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    cleared_except_id = Column(ForeignKey('nibrs_cleared_except.cleared_except_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    nibrs_month_id = Column(ForeignKey('nibrs_month.nibrs_month_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    agency = relationship('RefAgency')
    cleared_except = relationship('NibrsClearedExcept')
    nibrs_month = relationship('NibrsMonth')


class NibrsInjury(Base):
    __tablename__ = 'nibrs_injury'

    injury_id = Column(SmallInteger, primary_key=True)
    injury_code = Column(String(1))
    injury_name = Column(String(100))


class NibrsJustifiableForce(Base):
    __tablename__ = 'nibrs_justifiable_force'

    justifiable_force_id = Column(SmallInteger, primary_key=True)
    justifiable_force_code = Column(String(1))
    justifiable_force_name = Column(String(100))


class NibrsLocationType(Base):
    __tablename__ = 'nibrs_location_type'

    location_id = Column(BigInteger, primary_key=True)
    location_code = Column(String(2))
    location_name = Column(String(100))


class NibrsMonth(Base):
    __tablename__ = 'nibrs_month'
    __table_args__ = (
        UniqueConstraint('agency_id', 'month_num', 'data_year', 'data_home'),
    )

    nibrs_month_id = Column(BigInteger, primary_key=True)
    month_num = Column(SmallInteger, nullable=False)
    data_year = Column(SmallInteger, nullable=False)
    reported_status = Column(String(1))
    report_date = Column(DateTime(True))
    prepared_date = Column(DateTime(True))
    update_flag = Column(String(1), nullable=False)
    orig_format = Column(String(1), nullable=False)
    ff_line_number = Column(BigInteger)
    data_home = Column(String(1))
    ddocname = Column(String(50))
    did = Column(BigInteger)
    agency_id = Column(ForeignKey('ref_agency.agency_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    agency = relationship('RefAgency')


class NibrsOffender(Base):
    __tablename__ = 'nibrs_offender'

    offender_id = Column(BigInteger, primary_key=True)
    offender_seq_num = Column(SmallInteger)
    age_num = Column(SmallInteger)
    sex_code = Column(String(1))
    ff_line_number = Column(BigInteger)
    age_range_low_num = Column(SmallInteger)
    age_range_high_num = Column(SmallInteger)
    age_id = Column(ForeignKey('nibrs_age.age_id', deferrable=True, initially='DEFERRED'), index=True)
    ethnicity_id = Column(ForeignKey('nibrs_ethnicity.ethnicity_id', deferrable=True, initially='DEFERRED'), index=True)
    incident_id = Column(ForeignKey('nibrs_incident.incident_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    race_id = Column(ForeignKey('ref_race.race_id', deferrable=True, initially='DEFERRED'), index=True)

    age = relationship('NibrsAge')
    ethnicity = relationship('NibrsEthnicity')
    incident = relationship('NibrsIncident')
    race = relationship('RefRace')


class NibrsOffense(Base):
    __tablename__ = 'nibrs_offense'

    offense_id = Column(BigInteger, primary_key=True)
    attempt_complete_flag = Column(String(1))
    num_premises_entered = Column(SmallInteger)
    method_entry_code = Column(String(1))
    ff_line_number = Column(BigInteger)
    incident_id = Column(ForeignKey('nibrs_incident.incident_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    location_id = Column(ForeignKey('nibrs_location_type.location_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    offense_type_id = Column(ForeignKey('nibrs_offense_type.offense_type_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    incident = relationship('NibrsIncident')
    location = relationship('NibrsLocationType')
    offense_type = relationship('NibrsOffenseType')


class NibrsOffenseType(Base):
    __tablename__ = 'nibrs_offense_type'

    offense_type_id = Column(BigInteger, primary_key=True)
    offense_code = Column(String(5))
    offense_name = Column(String(100))
    crime_against = Column(String(100))
    ct_flag = Column(String(1))
    hc_flag = Column(String(1))
    hc_code = Column(String(5))
    offense_category_name = Column(String(100))


class NibrsPropDescType(Base):
    __tablename__ = 'nibrs_prop_desc_type'

    prop_desc_id = Column(SmallInteger, primary_key=True)
    prop_desc_code = Column(String(2))
    prop_desc_name = Column(String(100))


class NibrsPropLossType(Base):
    __tablename__ = 'nibrs_prop_loss_type'

    prop_loss_id = Column(SmallInteger, primary_key=True)
    prop_loss_name = Column(String(100))


class NibrsProperty(Base):
    __tablename__ = 'nibrs_property'

    property_id = Column(BigInteger, primary_key=True)
    stolen_count = Column(SmallInteger)
    recovered_count = Column(SmallInteger)
    ff_line_number = Column(BigInteger)
    incident_id = Column(ForeignKey('nibrs_incident.incident_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    prop_loss_id = Column(ForeignKey('nibrs_prop_loss_type.prop_loss_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    incident = relationship('NibrsIncident')
    prop_loss = relationship('NibrsPropLossType')


class NibrsPropertyDesc(Base):
    __tablename__ = 'nibrs_property_desc'

    property_value = Column(BigInteger)
    date_recovered = Column(DateTime(True))
    nibrs_prop_desc_id = Column(BigInteger, primary_key=True)
    prop_desc_id = Column(ForeignKey('nibrs_prop_desc_type.prop_desc_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    property_id = Column(ForeignKey('nibrs_property.property_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    prop_desc = relationship('NibrsPropDescType')
    property = relationship('NibrsProperty')


class NibrsRelationship(Base):
    __tablename__ = 'nibrs_relationship'

    relationship_id = Column(SmallInteger, primary_key=True)
    relationship_code = Column(String(2))
    relationship_name = Column(String(100))


class NibrsSumMonthTemp(Base):
    __tablename__ = 'nibrs_sum_month_temp'

    id = Column(Integer, primary_key=True, server_default=text("nextval('nibrs_sum_month_temp_id_seq'::regclass)"))
    nibrs_month_id = Column(BigInteger)
    agency_id = Column(BigInteger)
    month_num = Column(SmallInteger)
    data_year = Column(SmallInteger)
    reported_status = Column(String(1))
    report_date = Column(DateTime(True))
    prepared_date = Column(DateTime(True))
    orig_format = Column(String(1))
    ff_line_number = Column(BigInteger)
    data_home = Column(String(1))
    ddocname = Column(String(50))
    did = Column(BigInteger)
    nibrs_ct_flag = Column(String(1))
    nibrs_hc_flag = Column(String(1))
    nibrs_leoka_flag = Column(String(1))
    nibrs_arson_flag = Column(String(1))
    nibrs_ht_flag = Column(String(1))


class NibrsSuspectUsing(Base):
    __tablename__ = 'nibrs_suspect_using'
    __table_args__ = (
        UniqueConstraint('suspect_using_id', 'offense_id'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('nibrs_suspect_using_id_seq'::regclass)"))
    offense_id = Column(ForeignKey('nibrs_offense.offense_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    suspect_using_id = Column(ForeignKey('nibrs_using_list.suspect_using_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    offense = relationship('NibrsOffense')
    suspect_using = relationship('NibrsUsingList')


class NibrsSuspectedDrug(Base):
    __tablename__ = 'nibrs_suspected_drug'

    est_drug_qty = Column(Float(53))
    nibrs_suspected_drug_id = Column(BigInteger, primary_key=True)
    drug_measure_type_id = Column(ForeignKey('nibrs_drug_measure_type.drug_measure_type_id', deferrable=True, initially='DEFERRED'), index=True)
    property_id = Column(ForeignKey('nibrs_property.property_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    suspected_drug_type_id = Column(ForeignKey('nibrs_suspected_drug_type.suspected_drug_type_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    drug_measure_type = relationship('NibrsDrugMeasureType')
    property = relationship('NibrsProperty')
    suspected_drug_type = relationship('NibrsSuspectedDrugType')


class NibrsSuspectedDrugType(Base):
    __tablename__ = 'nibrs_suspected_drug_type'

    suspected_drug_type_id = Column(SmallInteger, primary_key=True)
    suspected_drug_code = Column(String(1))
    suspected_drug_name = Column(String(100))


class NibrsUsingList(Base):
    __tablename__ = 'nibrs_using_list'

    suspect_using_id = Column(SmallInteger, primary_key=True)
    suspect_using_code = Column(String(1))
    suspect_using_name = Column(String(100))


class NibrsVictim(Base):
    __tablename__ = 'nibrs_victim'

    victim_id = Column(BigInteger, primary_key=True)
    victim_seq_num = Column(SmallInteger)
    outside_agency_id = Column(BigInteger)
    age_num = Column(SmallInteger)
    sex_code = Column(String(1))
    resident_status_code = Column(String(1))
    agency_data_year = Column(SmallInteger)
    ff_line_number = Column(BigInteger)
    age_range_low_num = Column(SmallInteger)
    age_range_high_num = Column(SmallInteger)
    activity_type_id = Column(ForeignKey('nibrs_activity_type.activity_type_id', deferrable=True, initially='DEFERRED'), index=True)
    age_id = Column(ForeignKey('nibrs_age.age_id', deferrable=True, initially='DEFERRED'), index=True)
    assignment_type_id = Column(ForeignKey('nibrs_assignment_type.assignment_type_id', deferrable=True, initially='DEFERRED'), index=True)
    ethnicity_id = Column(ForeignKey('nibrs_ethnicity.ethnicity_id', deferrable=True, initially='DEFERRED'), index=True)
    incident_id = Column(ForeignKey('nibrs_incident.incident_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    race_id = Column(ForeignKey('ref_race.race_id', deferrable=True, initially='DEFERRED'), index=True)
    victim_type_id = Column(ForeignKey('nibrs_victim_type.victim_type_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    activity_type = relationship('NibrsActivityType')
    age = relationship('NibrsAge')
    assignment_type = relationship('NibrsAssignmentType')
    ethnicity = relationship('NibrsEthnicity')
    incident = relationship('NibrsIncident')
    race = relationship('RefRace')
    victim_type = relationship('NibrsVictimType')


class NibrsVictimCircumstance(Base):
    __tablename__ = 'nibrs_victim_circumstances'
    __table_args__ = (
        UniqueConstraint('victim_id', 'circumstances_id'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('nibrs_victim_circumstances_id_seq'::regclass)"))
    circumstances_id = Column(ForeignKey('nibrs_circumstances.circumstances_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    justifiable_force_id = Column(ForeignKey('nibrs_justifiable_force.justifiable_force_id', deferrable=True, initially='DEFERRED'), index=True)
    victim_id = Column(ForeignKey('nibrs_victim.victim_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    circumstances = relationship('NibrsCircumstance')
    justifiable_force = relationship('NibrsJustifiableForce')
    victim = relationship('NibrsVictim')


class NibrsVictimInjury(Base):
    __tablename__ = 'nibrs_victim_injury'
    __table_args__ = (
        UniqueConstraint('victim_id', 'injury_id'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('nibrs_victim_injury_id_seq'::regclass)"))
    injury_id = Column(ForeignKey('nibrs_injury.injury_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    victim_id = Column(ForeignKey('nibrs_victim.victim_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    injury = relationship('NibrsInjury')
    victim = relationship('NibrsVictim')


class NibrsVictimOffenderRel(Base):
    __tablename__ = 'nibrs_victim_offender_rel'

    nibrs_victim_offender_id = Column(BigInteger, primary_key=True)
    offender_id = Column(ForeignKey('nibrs_offender.offender_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    relationship_id = Column(ForeignKey('nibrs_relationship.relationship_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    victim_id = Column(ForeignKey('nibrs_victim.victim_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    offender = relationship('NibrsOffender')
    relationship_ = relationship('NibrsRelationship')
    victim = relationship('NibrsVictim')


class NibrsVictimOffense(Base):
    __tablename__ = 'nibrs_victim_offense'
    __table_args__ = (
        UniqueConstraint('victim_id', 'offense_id'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('nibrs_victim_offense_id_seq'::regclass)"))
    offense_id = Column(ForeignKey('nibrs_offense.offense_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    victim_id = Column(ForeignKey('nibrs_victim.victim_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    offense = relationship('NibrsOffense')
    victim = relationship('NibrsVictim')


class NibrsVictimType(Base):
    __tablename__ = 'nibrs_victim_type'

    victim_type_id = Column(SmallInteger, primary_key=True)
    victim_type_code = Column(String(1))
    victim_type_name = Column(String(100))


class NibrsWeapon(Base):
    __tablename__ = 'nibrs_weapon'

    nibrs_weapon_id = Column(BigInteger, primary_key=True)
    offense_id = Column(ForeignKey('nibrs_offense.offense_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    weapon_id = Column(ForeignKey('nibrs_weapon_type.weapon_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    offense = relationship('NibrsOffense')
    weapon = relationship('NibrsWeaponType')


class NibrsWeaponType(Base):
    __tablename__ = 'nibrs_weapon_type'

    weapon_id = Column(SmallInteger, primary_key=True)
    weapon_code = Column(String(3))
    weapon_name = Column(String(100))
    shr_flag = Column(String(1))


class OffenseClassification(Base):
    __tablename__ = 'offense_classification'

    classification_id = Column(SmallInteger, primary_key=True)
    classification_name = Column(String(50))
    class_sort_order = Column(SmallInteger)


class RefAgency(Base):
    __tablename__ = 'ref_agency'

    agency_id = Column(BigInteger, primary_key=True)
    ori = Column(String(9), nullable=False, unique=True)
    legacy_ori = Column(String(9), nullable=False)
    ucr_agency_name = Column(String(100))
    ncic_agency_name = Column(String(100))
    pub_agency_name = Column(String(100))
    special_mailing_group = Column(String(1))
    special_mailing_address = Column(String(1))
    agency_status = Column(String(1), nullable=False)
    judicial_dist_code = Column(String(4))
    fid_code = Column(String(2))
    added_date = Column(DateTime(True))
    change_timestamp = Column(DateTime(True))
    change_user = Column(String(100))
    legacy_notify_agency = Column(String(1))
    dormant_year = Column(SmallInteger)
    agency_type_id = Column(ForeignKey('ref_agency_type.agency_type_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    campus_id = Column(ForeignKey('ref_university_campus.campus_id', deferrable=True, initially='DEFERRED'), index=True)
    city_id = Column(ForeignKey('ref_city.city_id', deferrable=True, initially='DEFERRED'), index=True)
    department_id = Column(ForeignKey('ref_department.department_id', deferrable=True, initially='DEFERRED'), index=True)
    field_office_id = Column(ForeignKey('ref_field_office.field_office_id', deferrable=True, initially='DEFERRED'), index=True)
    population_family_id = Column(ForeignKey('ref_population_family.population_family_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    state_id = Column(ForeignKey('ref_state.state_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    submitting_agency_id = Column(ForeignKey('ref_submitting_agency.agency_id', deferrable=True, initially='DEFERRED'), index=True)
    tribe_id = Column(ForeignKey('ref_tribe.tribe_id', deferrable=True, initially='DEFERRED'), index=True)

    agency_type = relationship('RefAgencyType')
    campus = relationship('RefUniversityCampu')
    city = relationship('RefCity')
    department = relationship('RefDepartment')
    field_office = relationship('RefFieldOffice')
    population_family = relationship('RefPopulationFamily')
    state = relationship('RefState')
    submitting_agency = relationship('RefSubmittingAgency')
    tribe = relationship('RefTribe')


class RefAgencyCounty(Base):
    __tablename__ = 'ref_agency_county'
    __table_args__ = (
        UniqueConstraint('agency_id', 'county_id', 'metro_div_id', 'data_year'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('ref_agency_county_id_seq'::regclass)"))
    core_city_flag = Column(String(1))
    data_year = Column(SmallInteger, nullable=False)
    population = Column(BigInteger)
    census = Column(BigInteger)
    legacy_county_code = Column(String(20))
    legacy_msa_code = Column(String(20))
    source_flag = Column(String(1))
    change_timestamp = Column(DateTime(True))
    change_user = Column(String(100))
    agency_id = Column(ForeignKey('ref_agency.agency_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    county_id = Column(ForeignKey('ref_county.county_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    metro_div_id = Column(ForeignKey('ref_metro_division.metro_div_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    agency = relationship('RefAgency')
    county = relationship('RefCounty')
    metro_div = relationship('RefMetroDivision')


class RefAgencyCoveredBy(Base):
    __tablename__ = 'ref_agency_covered_by'
    __table_args__ = (
        UniqueConstraint('agency_id', 'data_year'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('ref_agency_covered_by_id_seq'::regclass)"))
    data_year = Column(SmallInteger, nullable=False)
    agency_id = Column(ForeignKey('ref_agency.agency_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    covered_by_agency_id = Column(ForeignKey('ref_agency.agency_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    agency = relationship('RefAgency', primaryjoin='RefAgencyCoveredBy.agency_id == RefAgency.agency_id')
    covered_by_agency = relationship('RefAgency', primaryjoin='RefAgencyCoveredBy.covered_by_agency_id == RefAgency.agency_id')


class RefAgencyDataContent(Base):
    __tablename__ = 'ref_agency_data_content'
    __table_args__ = (
        UniqueConstraint('agency_id', 'data_year'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('ref_agency_data_content_id_seq'::regclass)"))
    data_year = Column(SmallInteger, nullable=False)
    reporting_type = Column(String(1))
    nibrs_ct_flag = Column(String(1))
    nibrs_hc_flag = Column(String(1))
    nibrs_leoka_flag = Column(String(1))
    nibrs_arson_flag = Column(String(1))
    summary_rape_def = Column(String(1))
    nibrs_ht_flag = Column(String(1))
    agency_id = Column(ForeignKey('ref_agency.agency_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    agency = relationship('RefAgency')


class RefAgencyPoc(Base):
    __tablename__ = 'ref_agency_poc'
    __table_args__ = (
        UniqueConstraint('agency_id', 'poc_id'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('ref_agency_poc_id_seq'::regclass)"))
    agency_id = Column(BigInteger, nullable=False)
    primary_poc_flag = Column(String(1))
    poc_id = Column(ForeignKey('ref_poc.poc_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    poc = relationship('RefPoc')


class RefAgencyType(Base):
    __tablename__ = 'ref_agency_type'

    agency_type_id = Column(SmallInteger, primary_key=True)
    agency_type_name = Column(String(100))
    default_pop_family_id = Column(ForeignKey('ref_population_family.population_family_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    default_pop_family = relationship('RefPopulationFamily')


class RefCampusPopulation(Base):
    __tablename__ = 'ref_campus_population'
    __table_args__ = (
        UniqueConstraint('campus_id', 'data_year'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('ref_campus_population_id_seq'::regclass)"))
    data_year = Column(SmallInteger, nullable=False)
    population = Column(BigInteger)
    source_flag = Column(String(1), nullable=False)
    census = Column(BigInteger)
    change_timestamp = Column(DateTime(True))
    change_user = Column(String(100))
    reporting_population = Column(BigInteger)
    campus_id = Column(ForeignKey('ref_university_campus.campus_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    campus = relationship('RefUniversityCampu')


class RefCity(Base):
    __tablename__ = 'ref_city'
    __table_args__ = (
        UniqueConstraint('city_name', 'state_id'),
    )

    city_id = Column(BigInteger, primary_key=True)
    city_name = Column(String(100))
    state_id = Column(ForeignKey('ref_state.state_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    state = relationship('RefState')


class RefContinent(Base):
    __tablename__ = 'ref_continent'

    continent_id = Column(SmallInteger, primary_key=True)
    continent_desc = Column(String(50))


class RefCountry(Base):
    __tablename__ = 'ref_country'

    country_id = Column(SmallInteger, primary_key=True)
    country_desc = Column(String(50))
    continent_id = Column(ForeignKey('ref_continent.continent_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    continent = relationship('RefContinent')


class RefCounty(Base):
    __tablename__ = 'ref_county'

    county_id = Column(BigInteger, primary_key=True)
    county_name = Column(String(100))
    county_ansi_code = Column(String(5))
    county_fips_code = Column(String(5))
    legacy_county_code = Column(String(5))
    comments = Column(String(1000))
    state_id = Column(ForeignKey('ref_state.state_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    state = relationship('RefState')


class RefCountyPopulation(Base):
    __tablename__ = 'ref_county_population'
    __table_args__ = (
        UniqueConstraint('county_id', 'data_year'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('ref_county_population_id_seq'::regclass)"))
    data_year = Column(SmallInteger, nullable=False)
    population = Column(BigInteger)
    source_flag = Column(String(1), nullable=False)
    change_timestamp = Column(DateTime(True))
    change_user = Column(String(100))
    reporting_population = Column(BigInteger)
    county_id = Column(ForeignKey('ref_county.county_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    county = relationship('RefCounty')


class RefDepartment(Base):
    __tablename__ = 'ref_department'

    department_id = Column(SmallInteger, primary_key=True)
    department_name = Column(String(100), nullable=False)
    active_flag = Column(String(1), nullable=False)
    sort_order = Column(SmallInteger)


class RefDivision(Base):
    __tablename__ = 'ref_division'

    division_id = Column(SmallInteger, primary_key=True)
    division_code = Column(String(2))
    division_name = Column(String(100))
    division_desc = Column(String(100))
    region_id = Column(ForeignKey('ref_region.region_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    region = relationship('RefRegion')


class RefFieldOffice(Base):
    __tablename__ = 'ref_field_office'

    field_office_id = Column(BigInteger, primary_key=True)
    field_office_code = Column(String(10))
    field_office_name = Column(String(100))
    field_office_alpha_code = Column(String(2))
    field_office_numeric_code = Column(String(10))


class RefGlobalLocation(Base):
    __tablename__ = 'ref_global_location'

    global_location_id = Column(BigInteger, primary_key=True)
    global_location_desc = Column(String(50))
    country_id = Column(ForeignKey('ref_country.country_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    country = relationship('RefCountry')


class RefMetroDivPopulation(Base):
    __tablename__ = 'ref_metro_div_population'
    __table_args__ = (
        UniqueConstraint('metro_div_id', 'data_year'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('ref_metro_div_population_id_seq'::regclass)"))
    data_year = Column(SmallInteger, nullable=False)
    population = Column(BigInteger)
    source_flag = Column(String(1), nullable=False)
    census = Column(BigInteger)
    change_timestamp = Column(DateTime(True))
    change_user = Column(String(100))
    reporting_population = Column(BigInteger)
    metro_div_id = Column(ForeignKey('ref_metro_division.metro_div_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    metro_div = relationship('RefMetroDivision')


class RefMetroDivision(Base):
    __tablename__ = 'ref_metro_division'

    metro_div_id = Column(BigInteger, primary_key=True)
    metro_div_name = Column(String(100))
    msa_flag = Column(String(1))
    metro_div_omb_code = Column(String(5))
    legacy_msa_code = Column(String(5))
    msa_id = Column(ForeignKey('ref_msa.msa_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    msa = relationship('RefMsa')


class RefMsa(Base):
    __tablename__ = 'ref_msa'
    __table_args__ = (
        UniqueConstraint('msa_name', 'msa_omb_code'),
    )

    msa_id = Column(BigInteger, primary_key=True)
    msa_name = Column(String(100))
    msa_omb_code = Column(String(5))


class RefParentPopulationGroup(Base):
    __tablename__ = 'ref_parent_population_group'

    parent_pop_group_id = Column(BigInteger, primary_key=True)
    parent_pop_group_code = Column(String(2))
    parent_pop_group_desc = Column(String(100))
    publication_name = Column(String(100))
    population_family_id = Column(ForeignKey('ref_population_family.population_family_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    population_family = relationship('RefPopulationFamily')


class RefPoc(Base):
    __tablename__ = 'ref_poc'

    poc_id = Column(BigInteger, primary_key=True)
    poc_name = Column(String(200))
    poc_title = Column(String(200))
    poc_email = Column(String(200))
    poc_phone1 = Column(String(50))
    poc_phone2 = Column(String(50))
    mailing_address_1 = Column(String(150))
    mailing_address_2 = Column(String(150))
    mailing_address_3 = Column(String(150))
    mailing_address_4 = Column(String(150))
    zip_code = Column(String(10))
    city_name = Column(String(100))
    poc_fax1 = Column(String(20))
    poc_fax2 = Column(String(20))
    state_id = Column(ForeignKey('ref_state.state_id', deferrable=True, initially='DEFERRED'), index=True)

    state = relationship('RefState')


class RefPocRole(Base):
    __tablename__ = 'ref_poc_role'

    poc_role_id = Column(SmallInteger, primary_key=True)
    poc_role_name = Column(String(100))


class RefPocRoleAssign(Base):
    __tablename__ = 'ref_poc_role_assign'
    __table_args__ = (
        UniqueConstraint('poc_id', 'poc_role_id'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('ref_poc_role_assign_id_seq'::regclass)"))
    poc_id = Column(ForeignKey('ref_poc.poc_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    poc_role_id = Column(ForeignKey('ref_poc_role.poc_role_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    poc = relationship('RefPoc')
    poc_role = relationship('RefPocRole')


class RefPopulationFamily(Base):
    __tablename__ = 'ref_population_family'

    population_family_id = Column(SmallInteger, primary_key=True)
    population_family_name = Column(String(100))
    population_family_desc = Column(String(200))
    sort_order = Column(SmallInteger)


class RefPopulationGroup(Base):
    __tablename__ = 'ref_population_group'

    population_group_id = Column(BigInteger, primary_key=True)
    population_group_code = Column(String(2))
    population_group_desc = Column(String(150))
    publication_name = Column(String(100))
    parent_pop_group_id = Column(ForeignKey('ref_parent_population_group.parent_pop_group_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    parent_pop_group = relationship('RefParentPopulationGroup')


class RefRace(Base):
    __tablename__ = 'ref_race'

    race_id = Column(SmallInteger, primary_key=True)
    race_code = Column(String(2), nullable=False, unique=True)
    race_desc = Column(String(100), nullable=False)
    sort_order = Column(SmallInteger)
    start_year = Column(SmallInteger)
    end_year = Column(SmallInteger)
    notes = Column(String(1000))


class RefRegion(Base):
    __tablename__ = 'ref_region'

    region_id = Column(SmallInteger, primary_key=True)
    region_code = Column(String(2))
    region_name = Column(String(100))
    region_desc = Column(String(100))


class RefState(Base):
    __tablename__ = 'ref_state'

    state_id = Column(SmallInteger, primary_key=True)
    state_name = Column(String(100))
    state_code = Column(String(2))
    state_abbr = Column(String(2))
    state_postal_abbr = Column(String(2))
    state_fips_code = Column(String(2))
    state_pub_freq_months = Column(SmallInteger)
    division_id = Column(ForeignKey('ref_division.division_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    division = relationship('RefDivision')


class RefSubmittingAgency(Base):
    __tablename__ = 'ref_submitting_agency'

    agency_id = Column(BigInteger, primary_key=True)
    sai = Column(String(9))
    agency_name = Column(String(150))
    notify_agency = Column(String(1))
    agency_email = Column(String(200))
    agency_website = Column(String(2000))
    comments = Column(String(2000))
    state_id = Column(ForeignKey('ref_state.state_id', deferrable=True, initially='DEFERRED'), index=True)

    state = relationship('RefState')


class RefTribe(Base):
    __tablename__ = 'ref_tribe'

    tribe_id = Column(BigInteger, primary_key=True)
    tribe_name = Column(String(100), unique=True)


class RefTribePopulation(Base):
    __tablename__ = 'ref_tribe_population'
    __table_args__ = (
        UniqueConstraint('tribe_id', 'data_year'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('ref_tribe_population_id_seq'::regclass)"))
    data_year = Column(SmallInteger, nullable=False)
    population = Column(BigInteger)
    source_flag = Column(String(1), nullable=False)
    census = Column(BigInteger)
    change_timestamp = Column(DateTime(True))
    change_user = Column(String(100))
    reporting_population = Column(BigInteger)
    tribe_id = Column(ForeignKey('ref_tribe.tribe_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    tribe = relationship('RefTribe')


class RefUniversity(Base):
    __tablename__ = 'ref_university'

    university_id = Column(BigInteger, primary_key=True)
    university_abbr = Column(String(20))
    university_name = Column(String(100), unique=True)


class RefUniversityCampu(Base):
    __tablename__ = 'ref_university_campus'

    campus_id = Column(BigInteger, primary_key=True)
    campus_name = Column(String(100))
    university_id = Column(ForeignKey('ref_university.university_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    university = relationship('RefUniversity')


class RetaMonth(Base):
    __tablename__ = 'reta_month'
    __table_args__ = (
        UniqueConstraint('agency_id', 'data_year', 'month_num', 'data_home', 'source_flag'),
    )

    reta_month_id = Column(BigInteger, primary_key=True)
    data_year = Column(SmallInteger, nullable=False)
    month_num = Column(SmallInteger, nullable=False)
    data_home = Column(String(1), nullable=False)
    source_flag = Column(String(1), nullable=False)
    reported_flag = Column(String(1), nullable=False)
    ddocname = Column(String(100))
    month_included_in = Column(SmallInteger)
    report_date = Column(DateTime(True))
    prepared_date = Column(DateTime(True))
    prepared_by_user = Column(String(100))
    prepared_by_email = Column(String(200))
    orig_format = Column(String(1), nullable=False)
    total_reported_count = Column(Integer)
    total_unfounded_count = Column(Integer)
    total_actual_count = Column(Integer)
    total_cleared_count = Column(Integer)
    total_juvenile_cleared_count = Column(Integer)
    leoka_felony = Column(SmallInteger)
    leoka_accident = Column(SmallInteger)
    leoka_assault = Column(Integer)
    leoka_status = Column(SmallInteger)
    update_flag = Column(String(1))
    did = Column(BigInteger)
    ff_line_number = Column(BigInteger)
    agency_id = Column(ForeignKey('ref_agency.agency_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    agency = relationship('RefAgency')


class RetaMonthOffenseSubcat(Base):
    __tablename__ = 'reta_month_offense_subcat'
    __table_args__ = (
        UniqueConstraint('offense_subcat_id', 'reta_month_id'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('reta_month_offense_subcat_id_seq'::regclass)"))
    reported_count = Column(Integer)
    reported_status = Column(SmallInteger)
    unfounded_count = Column(Integer)
    unfounded_status = Column(SmallInteger)
    actual_count = Column(Integer)
    actual_status = Column(SmallInteger)
    cleared_count = Column(Integer)
    cleared_status = Column(SmallInteger)
    juvenile_cleared_count = Column(Integer)
    juvenile_cleared_status = Column(SmallInteger)
    offense_subcat_id = Column(ForeignKey('reta_offense_subcat.offense_subcat_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    reta_month_id = Column(ForeignKey('reta_month.reta_month_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    offense_subcat = relationship('RetaOffenseSubcat')
    reta_month = relationship('RetaMonth')


class RetaOffense(Base):
    __tablename__ = 'reta_offense'

    offense_id = Column(BigInteger, primary_key=True)
    offense_name = Column(String(100), nullable=False)
    offense_code = Column(String(20), nullable=False, unique=True)
    offense_xml_path = Column(String(1000))
    offense_sort_order = Column(BigInteger)
    classification_id = Column(ForeignKey('offense_classification.classification_id', deferrable=True, initially='DEFERRED'), index=True)
    offense_category_id = Column(ForeignKey('reta_offense_category.offense_category_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    classification = relationship('OffenseClassification')
    offense_category = relationship('RetaOffenseCategory')


class RetaOffenseCategory(Base):
    __tablename__ = 'reta_offense_category'

    offense_category_id = Column(SmallInteger, primary_key=True)
    offense_category_name = Column(String(50))
    offense_category_sort_order = Column(SmallInteger, nullable=False)
    crime_type_id = Column(ForeignKey('crime_type.crime_type_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    crime_type = relationship('CrimeType')


class RetaOffenseSubcat(Base):
    __tablename__ = 'reta_offense_subcat'

    offense_subcat_id = Column(BigInteger, primary_key=True)
    offense_subcat_name = Column(String(100), nullable=False)
    offense_subcat_code = Column(String(20), nullable=False, unique=True)
    offense_subcat_xml_path = Column(String(1000))
    offense_subcat_sort_order = Column(BigInteger)
    part = Column(String(1))
    crime_index_flag = Column(String(1))
    offense_id = Column(ForeignKey('reta_offense.offense_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    offense = relationship('RetaOffense')


class ShrCircumstance(Base):
    __tablename__ = 'shr_circumstances'

    circumstances_id = Column(SmallInteger, primary_key=True)
    circumstances_code = Column(String(2), nullable=False)
    sub_code = Column(String(1))
    circumstances_name = Column(String(100), nullable=False)
    sub_name = Column(String(100))
    current_flag = Column(String(1))


class ShrIncident(Base):
    __tablename__ = 'shr_incident'
    __table_args__ = (
        UniqueConstraint('shr_month_id', 'incident_num', 'data_home'),
    )

    incident_id = Column(BigInteger, primary_key=True)
    homicide_code = Column(String(1))
    incident_num = Column(String(3))
    incident_status = Column(SmallInteger)
    update_flag = Column(String(1))
    data_home = Column(String(1))
    prepared_date = Column(DateTime(True))
    report_date = Column(DateTime(True))
    ddocname = Column(String(100))
    ff_line_number = Column(BigInteger)
    orig_format = Column(String(1))
    did = Column(BigInteger)
    nibrs_incident_id = Column(BigInteger)
    shr_month_id = Column(ForeignKey('shr_month.shr_month_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    situation_id = Column(ForeignKey('shr_situation.situation_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    shr_month = relationship('ShrMonth')
    situation = relationship('ShrSituation')


class ShrMonth(Base):
    __tablename__ = 'shr_month'
    __table_args__ = (
        UniqueConstraint('agency_id', 'data_year', 'month_num', 'data_home'),
    )

    shr_month_id = Column(BigInteger, primary_key=True)
    data_year = Column(SmallInteger, nullable=False)
    month_num = Column(SmallInteger, nullable=False)
    data_home = Column(String(1), nullable=False)
    source_flag = Column(String(1))
    reported_flag = Column(String(1))
    orig_format = Column(String(1))
    update_flag = Column(String(1))
    ff_line_number = Column(BigInteger)
    ddocname = Column(String(100))
    did = Column(BigInteger)
    agency_id = Column(ForeignKey('ref_agency.agency_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    agency = relationship('RefAgency')


class ShrOffender(Base):
    __tablename__ = 'shr_offender'

    offender_id = Column(BigInteger, primary_key=True)
    offender_num = Column(String(20))
    age_num = Column(SmallInteger)
    sex_code = Column(String(1))
    nibrs_offense_id = Column(BigInteger)
    nibrs_offender_id = Column(BigInteger)
    age_id = Column(ForeignKey('nibrs_age.age_id', deferrable=True, initially='DEFERRED'), index=True)
    ethnicity_id = Column(ForeignKey('nibrs_ethnicity.ethnicity_id', deferrable=True, initially='DEFERRED'), index=True)
    race_id = Column(ForeignKey('ref_race.race_id', deferrable=True, initially='DEFERRED'), index=True)

    age = relationship('NibrsAge')
    ethnicity = relationship('NibrsEthnicity')
    race = relationship('RefRace')


class ShrOffense(Base):
    __tablename__ = 'shr_offense'

    offense_id = Column(BigInteger, primary_key=True)
    nibrs_offense_id = Column(BigInteger)
    circumstances_id = Column(ForeignKey('shr_circumstances.circumstances_id', deferrable=True, initially='DEFERRED'), index=True)
    incident_id = Column(ForeignKey('shr_incident.incident_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    offender_id = Column(ForeignKey('shr_offender.offender_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    relationship_id = Column(ForeignKey('shr_relationship.relationship_id', deferrable=True, initially='DEFERRED'), index=True)
    victim_id = Column(ForeignKey('shr_victim.victim_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    weapon_id = Column(ForeignKey('nibrs_weapon_type.weapon_id', deferrable=True, initially='DEFERRED'), index=True)

    circumstances = relationship('ShrCircumstance')
    incident = relationship('ShrIncident')
    offender = relationship('ShrOffender')
    relationship_ = relationship('ShrRelationship')
    victim = relationship('ShrVictim')
    weapon = relationship('NibrsWeaponType')


class ShrRelationship(Base):
    __tablename__ = 'shr_relationship'

    relationship_id = Column(SmallInteger, primary_key=True)
    relationship_code = Column(String(2))
    relationship_name = Column(String(100))


class ShrSituation(Base):
    __tablename__ = 'shr_situation'

    situation_id = Column(SmallInteger, primary_key=True)
    situation_code = Column(String(1))
    situation_name = Column(String(100))


class ShrVictim(Base):
    __tablename__ = 'shr_victim'

    victim_id = Column(BigInteger, primary_key=True)
    victim_num = Column(String(20))
    age_num = Column(SmallInteger)
    sex_code = Column(String(1))
    nibrs_victim_id = Column(BigInteger)
    nibrs_offense_id = Column(BigInteger)
    age_id = Column(ForeignKey('nibrs_age.age_id', deferrable=True, initially='DEFERRED'), index=True)
    ethnicity_id = Column(ForeignKey('nibrs_ethnicity.ethnicity_id', deferrable=True, initially='DEFERRED'), index=True)
    race_id = Column(ForeignKey('ref_race.race_id', deferrable=True, initially='DEFERRED'), index=True)

    age = relationship('NibrsAge')
    ethnicity = relationship('NibrsEthnicity')
    race = relationship('RefRace')


class SuppLarcenyType(Base):
    __tablename__ = 'supp_larceny_type'

    larceny_type_id = Column(BigInteger, primary_key=True)
    larceny_type_name = Column(String(100), nullable=False)
    larceny_type_code = Column(String(20), nullable=False)
    larceny_xml_name = Column(String(100))


class SuppMonth(Base):
    __tablename__ = 'supp_month'
    __table_args__ = (
        UniqueConstraint('agency_id', 'data_year', 'month_num', 'data_home'),
    )

    supp_month_id = Column(BigInteger, primary_key=True)
    data_year = Column(SmallInteger, nullable=False)
    month_num = Column(SmallInteger, nullable=False)
    data_home = Column(String(1), nullable=False)
    source_flag = Column(String(1))
    reported_flag = Column(String(1), nullable=False)
    report_date = Column(DateTime(True))
    prepared_date = Column(DateTime(True))
    ddocname = Column(String(100))
    orig_format = Column(String(1), nullable=False)
    mv_stolen_local_rec_local = Column(BigInteger)
    mv_stolen_local_rec_other = Column(BigInteger)
    mv_tot_local_stolen_rec = Column(BigInteger)
    mv_stolen_other_rec_local = Column(BigInteger)
    mv_stolen_status = Column(SmallInteger)
    update_flag = Column(String(1))
    did = Column(BigInteger)
    ff_line_number = Column(BigInteger)
    agency_id = Column(ForeignKey('ref_agency.agency_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    agency = relationship('RefAgency')


class SuppOffense(Base):
    __tablename__ = 'supp_offense'

    offense_id = Column(BigInteger, primary_key=True)
    offense_name = Column(String(100), nullable=False)
    offense_code = Column(String(20), nullable=False)


class SuppOffenseSubcat(Base):
    __tablename__ = 'supp_offense_subcat'

    offense_subcat_id = Column(BigInteger, primary_key=True)
    offense_subcat_name = Column(String(100), nullable=False)
    offense_subcat_code = Column(String(20), nullable=False)
    offense_subcat_xml_name = Column(String(100))
    offense_id = Column(ForeignKey('supp_offense.offense_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    offense = relationship('SuppOffense')


class SuppPropByOffenseSubcat(Base):
    __tablename__ = 'supp_prop_by_offense_subcat'
    __table_args__ = (
        UniqueConstraint('supp_month_id', 'offense_subcat_id'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('supp_prop_by_offense_subcat_id_seq'::regclass)"))
    actual_count = Column(Integer)
    actual_status = Column(SmallInteger)
    stolen_value = Column(BigInteger)
    stolen_value_status = Column(SmallInteger)
    offense_subcat_id = Column(ForeignKey('supp_offense_subcat.offense_subcat_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    supp_month_id = Column(ForeignKey('supp_month.supp_month_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    offense_subcat = relationship('SuppOffenseSubcat')
    supp_month = relationship('SuppMonth')


class SuppPropertyByTypeValue(Base):
    __tablename__ = 'supp_property_by_type_value'
    __table_args__ = (
        UniqueConstraint('prop_type_id', 'supp_month_id'),
    )

    id = Column(Integer, primary_key=True, server_default=text("nextval('supp_property_by_type_value_id_seq'::regclass)"))
    stolen_value = Column(BigInteger)
    stolen_value_status = Column(SmallInteger)
    recovered_value = Column(BigInteger)
    recovered_value_status = Column(SmallInteger)
    prop_type_id = Column(ForeignKey('supp_property_type.prop_type_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)
    supp_month_id = Column(ForeignKey('supp_month.supp_month_id', deferrable=True, initially='DEFERRED'), nullable=False, index=True)

    prop_type = relationship('SuppPropertyType')
    supp_month = relationship('SuppMonth')


class SuppPropertyType(Base):
    __tablename__ = 'supp_property_type'

    prop_type_id = Column(BigInteger, primary_key=True)
    prop_type_name = Column(String(100), nullable=False)
    prop_type_code = Column(String(20), nullable=False)
    prop_type_code_num = Column(SmallInteger, nullable=False)

