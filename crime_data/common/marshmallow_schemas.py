# coding: utf-8

import os

from flask_marshmallow import Marshmallow
from marshmallow import fields as marsh_fields
from marshmallow import Schema, post_dump
from . import cdemodels, models, newmodels, lookupmodels
from crime_data.common.base import ExplorerOffenseMapping

ma = Marshmallow()

# Map of age codes to correct null values.
AGE_CODES = {'BB': 0, 'NB': 0, 'NN': 0, '99': 99, }


class SchemaFormater(object):
    """Useful methods for schema transformations"""

    @classmethod
    def format_age(cls, data):
        """Turns the age_num field into something a little more useful."""

        if 'age_num' in data and data['age']:
            if data['age']['age_code'] in AGE_CODES:
                data['age_num'] = AGE_CODES[data['age']['age_code']]
        return data


class ApiKeySchema(Schema):
    api_key = marsh_fields.String(
        required=False,
        error_messages={'required': 'Get API key from Catherine'})
    api_header_key = marsh_fields.String(
        load_from='X-API-KEY',
        required=False,
        location='headers')

# Schemas for request parsing
class ArgumentsSchema(ApiKeySchema):
    """Input arguments for many API methods"""

    output = marsh_fields.String(missing='json')
    aggregate_many = marsh_fields.String(missing='false')
    page = marsh_fields.Integer(missing=1)
    per_page = marsh_fields.Integer(missing=10)
    fields = marsh_fields.String()
    tuning = marsh_fields.Boolean(missing=False)


# class IncidentViewCountArgsYear(ArgumentsSchema):
#     """
#     Groupable queries can be grouped by one or more fields found in the
#     tables separated by commas
#     """
#     county_id = marsh_fields.Integer()
#     state_id = marsh_fields.Integer()
#     variable = marsh_fields.String(missing='')
#     year = marsh_fields.String(required=True)

class IncidentViewCountArgs(ArgumentsSchema):
    """
    Groupable queries can be grouped by one or more fields found in the
    tables separated by commas
    """
    county_id = marsh_fields.Integer()
    state_id = marsh_fields.Integer()
    variable = marsh_fields.String(required=True)
    year = marsh_fields.String(missing=None)


class OffenseCountViewArgs(IncidentViewCountArgs):
    """Adds offense_name as a field"""

    offense_name = marsh_fields.String(metadata={'description': 'The NIBRS offense name to subgroup by'})
    explorer_offense = marsh_fields.String(metadata={'description': 'A standardized offense class used by the explorer',
                                                     'enum': ExplorerOffenseMapping.NIBRS_OFFENSE_MAPPING.keys()})
    year = marsh_fields.String(metadata={'description': 'A year to return data for'})
# Anything in an ArgumentsSchema will, dangerously ironically,
# not be filtered for...


class OffenseCountViewArgsYear(IncidentViewCountArgs):
    """Adds offense_name as a field"""

    offense_name = marsh_fields.String(metadata={'description': 'The NIBRS offense name to subgroup by'})
    explorer_offense = marsh_fields.String(metadata={'description': 'A standardized offense class used by the explorer',
                                                     'enum': ExplorerOffenseMapping.NIBRS_OFFENSE_MAPPING.keys()})
    year = marsh_fields.String(metadata={'description': 'A year to return data for'})

class ViewCountArgs(ArgumentsSchema):
    """The regular arguments shema but also add a year argument"""

    year = marsh_fields.String(missing=None)


class ViewCountYearRequiredArgs(ArgumentsSchema):
    """When the year is required"""

    year = marsh_fields.String(required=True, metadata={'description': 'A year to return data for'})


class GroupableArgsSchema(ArgumentsSchema):

    """
    Groupable queries can be grouped by one or more fields found in the
    tables separated by commas
    """

    by = marsh_fields.String(missing='year')


class AgenciesIncidentArgsSchema(ArgumentsSchema):
    """Extra parameters apply to queries against the incidents table."""

    incident_hour = marsh_fields.Integer()
    crime_against = marsh_fields.String()
    offense_code = marsh_fields.String()
    offense_name = marsh_fields.String()
    offense_category_name = marsh_fields.String()
    method_entry_code = marsh_fields.String()
    location_code = marsh_fields.String()
    location_name = marsh_fields.String()
    state = marsh_fields.String()
    by = marsh_fields.String(missing='ori')


class AgenciesRetaArgsSchema(ArgumentsSchema):
    """RET A Agencies can be queried with additional arguments."""

    state = marsh_fields.String()
    ori = marsh_fields.String()
    victim_ethnicity = marsh_fields.String()
    offender_ethnicity = marsh_fields.String()
    by = marsh_fields.String(missing='ori')


class PaginationSchema(Schema):
    """Many API methods include a Pagination record in their responses."""

    count = marsh_fields.Integer(dumpOnly=True)
    page = marsh_fields.Integer(dumpOnly=True)
    pages = marsh_fields.Integer(dumpOnly=True)
    per_page = marsh_fields.Integer(dumpOnly=True)

# Schemas for data serialization
class ArsonSummarySchema(ma.ModelSchema):
    class Meta:
        model = newmodels.ArsonSummary
        exclude = ('arson_summary_id', 'state_id', 'agency_id', )
        ordered = True


class ArsonSubclassificationSchema(ma.ModelSchema):
    class Meta:
        model = models.ArsonSubclassification
        exclude = ('subclass_xml_path', )
        ordered = True


class ArsonSubcategorySchema(ma.ModelSchema):
    class Meta:
        model = models.ArsonSubcategory
        exclude = ('subcat_xml_path', )

    subclass = ma.Nested(ArsonSubclassificationSchema)


class AgencySumsSchema(Schema):
    class Meta:
        model = newmodels.AgencySums

    id = marsh_fields.Integer()
    year = marsh_fields.Integer()
    agency_id = marsh_fields.Integer()
    ori = marsh_fields.String()
    state_postal_abbr = marsh_fields.String()
    pub_agency_name = marsh_fields.String()
    offense_id = marsh_fields.Integer()
    offense_code = marsh_fields.String() # reta_offense
    offense_subcat_code = marsh_fields.String()
    offense_subcat_name = marsh_fields.String()
    offense_name = marsh_fields.String()
    reported = marsh_fields.Integer()
    unfounded = marsh_fields.Integer()
    actual = marsh_fields.Integer()
    cleared = marsh_fields.Integer()
    juvenile_cleared = marsh_fields.Integer()
    ucr_agency_name = marsh_fields.String()
    ncic_agency_name = marsh_fields.String()
    pub_agency_name = marsh_fields.String()
    # county_name = marsh_fields.String()
    # county_ansi_code = marsh_fields.String()
    # county_fips_code = marsh_fields.String()
    # legacy_county_code = marsh_fields.String()

class AgencyOffensesSchema(Schema):
    class Meta:
        model = newmodels.AgencyOffenseCounts
        exclude = ('offense_id', )

    id = marsh_fields.Integer()
    year = marsh_fields.Integer()
    agency_id = marsh_fields.Integer()
    ori = marsh_fields.String()
    state_postal_abbr = marsh_fields.String()
    pub_agency_name = marsh_fields.String()
    offense_code = marsh_fields.String() # reta_offense
    offense_name = marsh_fields.String()
    classification = marsh_fields.String()
    reported = marsh_fields.Integer()
    unfounded = marsh_fields.Integer()
    actual = marsh_fields.Integer()
    cleared = marsh_fields.Integer()
    juvenile_cleared = marsh_fields.Integer()
    ucr_agency_name = marsh_fields.String()
    ncic_agency_name = marsh_fields.String()
    pub_agency_name = marsh_fields.String()


class NibrsRelationshipSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsRelationship
        exclude = ('relationships', 'offender', 'victim')


class NibrsVictimOffenderRelSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsVictimOffenderRel

    relationship_ = ma.Nested(NibrsRelationshipSchema)


class NibrsCriminalActTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsCriminalActType
        exclude = ('criminal_acts', )


class NibrsCriminalActSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsCriminalAct
        exclude = ('offenses', )

    criminal_act = ma.Nested(NibrsCriminalActTypeSchema)


class NibrsUsingListSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsUsingList
        exclude = ('suspect_using_id', )


class NibrsWeaponTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsWeaponType
        exclude = ('weapon_id', 'weapons', )
        ordered = True


class NibrsWeaponSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsWeapon
        exclude = ('offense', )

    weapon = ma.Nested(NibrsWeaponTypeSchema)


class SummarySchema(ma.ModelSchema):
    class Meta:
        model = models.RetaMonthOffenseSubcat

    year = marsh_fields.Integer()
    month = marsh_fields.Integer()
    ori = marsh_fields.String()
    agency_name = marsh_fields.String()
    state = marsh_fields.String()
    city = marsh_fields.String()
    tribe = marsh_fields.String()
    offense_subcat = marsh_fields.String()
    offense_subcat_code = marsh_fields.String()
    offense = marsh_fields.String()
    offense_code = marsh_fields.String()
    offense_category = marsh_fields.String()


class RefRegionSchema(ma.ModelSchema):
    class Meta:
        model = lookupmodels.RefRegion
        exclude = ('region_id', )


class RefDivisionSchema(ma.ModelSchema):
    class Meta:
        model = models.RefDivision
        exclude = ('division_id', )

    region = ma.Nested(RefRegionSchema)


class RefStateSchema(ma.ModelSchema):
    class Meta:
        model = models.RefState
        exclude = ('state_id', 'counties')

    division = ma.Nested(RefDivisionSchema)


class RefCitySchema(ma.ModelSchema):
    class Meta:
        model = models.RefCity
        exclude = ('state', )
        ordered = True

    state = ma.Nested(RefStateSchema)


class RefContinentSchema(ma.ModelSchema):
    class Meta:
        model = models.RefContinent
        ordered = True


class RefCountySchema(ma.ModelSchema):
    class Meta:
        model = models.RefCounty
        exclude = ('state', 'agencies', 'agency_associations', )
        ordered = True

    state = ma.Nested(RefStateSchema)


class RefCountrySchema(ma.ModelSchema):
    class Meta:
        model = models.RefCountry
        ordered = True

    continent = ma.Nested(RefContinentSchema)


class RefMsaSchema(ma.ModelSchema):
    class Meta:
        model = models.RefMsa
        ordered = True


class RefMetroDivision(ma.ModelSchema):
    class Meta:
        model = models.RefMetroDivision
        ordered = True


class RefPopulationFamilySchema(ma.ModelSchema):
    class Meta:
        model = models.RefPopulationFamily
        exclude = ('population_family_id', )


class RefPopulationGroupSchema(ma.ModelSchema):
    class Meta:
        model = models.RefPopulationGroup
        exclude = ('population_group_id', 'parent_pop_group', )


class RefFieldOfficeSchema(ma.ModelSchema):
    class Meta:
        model = models.RefFieldOffice
        exclude = ('field_office_id', )


class RefAgencyTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.RefAgencyType
        exclude = ('default_pop_family_id', )


class RefDepartmentSchema(ma.ModelSchema):
    class Meta:
        model = models.RefDepartment
        exclude = ('department_id', )


class RefSubmittingAgencySchema(ma.ModelSchema):
    class Meta:
        model = models.RefSubmittingAgency
        exclude = ('agency_id', )

    state = ma.Nested(RefStateSchema)


class RefTribeSchema(ma.ModelSchema):
    class Meta:
        model = models.RefTribe


class RefAgencyCountySchema(ma.ModelSchema):
    class Meta:
        model = models.RefAgencyCounty
        exclude = ('change_timestamp', 'change_user', 'agency', )

    county = ma.Nested(RefCountySchema)


class RefUniversitySchema(ma.ModelSchema):
    class Meta:
        model = models.RefUniversity


class RefAgencySchema(ma.ModelSchema, ArgumentsSchema):
    class Meta:
        model = models.RefAgency
        exclude = ('county_associations',
                   'special_mailing_group',
                   'special_mailing_address',
                   'change_user', )

    city = ma.Nested(RefCitySchema)
    state = ma.Nested(RefStateSchema)
    agency_type = ma.Nested(RefAgencyTypeSchema)
    department = ma.Nested(RefDepartmentSchema)
    field_office = ma.Nested(RefFieldOfficeSchema)
    population_family = ma.Nested(RefPopulationFamilySchema)
    submitting_agency = ma.Nested(RefSubmittingAgencySchema)
    tribe = ma.Nested(RefTribeSchema)
    counties = ma.Nested(RefCountySchema, many=True)


class RetaMonthSchema(ma.ModelSchema):
    class Meta:
        model = models.RetaMonth
        exclude = ('reta_month_id',
                   'prepared_by_user',
                   'prepared_by_email',
                   'did',
                   'ff_line_number', )

    agency = ma.Nested(RefAgencySchema)


class RefRaceSchema(ma.ModelSchema):
    class Meta:
        model = models.RefRace
        exclude = ('race_id',
                   'arrestees',
                   'offenders',
                   'victims',
                   'sort_order', )


class AsrAgeRangeSchema(ma.ModelSchema):
    class Meta:
        model = models.AsrAgeRange
        exclude = ('age_range_id', )
        ordered = True


class AsrEthnicitySchema(ma.ModelSchema):
    class Meta:
        model = models.AsrEthnicity
        exclude = ('ethnicity_id', )
        ordered = True


class AsrOffenseSchema(ma.ModelSchema):
    class Meta:
        model = models.AsrOffense
        exclude = ('offense_id', )
        ordered = True


class AsrOffenseCategorySchema(ma.ModelSchema):
    class Meta:
        model = models.AsrOffenseCategory
        exclude = ('offense_cat_id', )
        ordered = True


class AsrOffenseSubcatSchema(ma.ModelSchema):
    class Meta:
        model = models.AsrOffenseSubcat
        exclude = ('offense_subcat_id', )
        ordered = True

    offense = ma.Nested(AsrOffenseSchema)


class NibrsLocationTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsLocationType
        exclude = ('offenses', 'location_id')
        ordered = True


class NibrsOffenseTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsOffenseType
        exclude = ('arrestees', 'offenses', 'offense_type_id', )
        ordered = True


class NibrsOffenseSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsOffense
        exclude = ('incident', 'offense_id', 'ff_line_number', )

    criminal_acts = ma.Nested(NibrsCriminalActSchema, many=True)
    weapons = ma.Nested(NibrsWeaponSchema, many=True)
    offense_type = ma.Nested(NibrsOffenseTypeSchema)
    location = ma.Nested(NibrsLocationTypeSchema)
    method_entry_code = marsh_fields.String()


class NibrsClearedExceptSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsClearedExcept
        exclude = ('cleared_except_id', )


class NibrsPropDescTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsPropDescType
        exclude = ('prop_desc_id', )


class NibrsPropLossTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsPropLossType
        exclude = ('property', )


class NibrsPropertySchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsProperty
        exclude = ('incident', 'property_id', )

    prop_loss = ma.Nested(NibrsPropLossTypeSchema, exclude=('prop_loss_id', ))


class NibrsAgeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsAge
        exclude = ('age_id', 'arrestees', 'offenders', 'victims', )


class NibrsEthnicitySchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsEthnicity
        exclude = ('ethnicity_id', 'arrestees', 'offenders', 'victims', )


class NibrsInjurySchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsInjury
        exclude = ('injury_id', )
        ordered = True


class NibrsVictimTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsVictimType
        exclude = ('victim_type_id', 'victims', )


class NibrsActivityTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsActivityType
        exclude = ('activity_type_id', 'victims', )
        ordered = True


class NibrsInjurySchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsInjury
        # exclude = ('victim_id')

    injury_code = marsh_fields.String()


class NibrsVictimInjurySchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsVictimInjury
        exclude = ('victim_id', 'victim')

    injury = ma.Nested(NibrsInjurySchema)


class NibrsVictimSchema(ma.ModelSchema, SchemaFormater):
    class Meta:
        model = models.NibrsVictim
        exclude = ('victim_seq_num', 'victim_id', 'ff_line_number', )

    injuries = ma.Nested(NibrsVictimInjurySchema, many=True)
    relationships = ma.Nested(NibrsVictimOffenderRelSchema, many=True)

    ethnicity = ma.Nested(NibrsEthnicitySchema)
    race = ma.Nested(RefRaceSchema)
    victim_type = ma.Nested(NibrsVictimTypeSchema)
    age = ma.Nested(NibrsAgeSchema)
    activity_type = ma.Nested(NibrsActivityTypeSchema)
    age_num = marsh_fields.Integer(missing=0)

    @post_dump
    def check_age(self, out_data):
        out_data = self.format_age(out_data)
        return out_data


class NibrsArresteeSchema(ma.ModelSchema, SchemaFormater):
    class Meta:
        model = models.NibrsArrestee
        exclude = ('arrestee_id',
                   'arrestee_seq_num',
                   'arrest_num',
                   'ff_line_number',
                   'incident',
                   'offense_type', )

    ethnicity = ma.Nested(NibrsEthnicitySchema)
    race = ma.Nested(RefRaceSchema)
    age = ma.Nested(NibrsAgeSchema)
    age_num = marsh_fields.Integer(missing=0)

    @post_dump
    def check_age(self, out_data):
        out_data = self.format_age(out_data)
        return out_data


class NibrsArrestTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsArrestType
        exclude = ('arrest_type_id', 'arrestees', )
        ordered = True


class NibrsOffenderSchema(ma.ModelSchema, SchemaFormater):
    class Meta:
        model = models.NibrsOffender
        exclude = ('offender_id',
                   'incident',
                   'ff_line_number',
                   'offender_seq_num',
                   'relationships', )

    ethnicity = ma.Nested(NibrsEthnicitySchema)
    race = ma.Nested(RefRaceSchema)
    age = ma.Nested(NibrsAgeSchema)
    age_num = marsh_fields.Integer(missing=0)

    @post_dump
    def check_age(self, out_data):
        out_data = self.format_age(out_data)
        return out_data


class NibrsIncidentSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsIncident
        exclude = ('data_home',
                   'ddocname',
                   'ff_line_number',
                   'did',
                   'nibrs_month',
                   'orig_format',
                   'incident_number', )

    offenses = ma.Nested(NibrsOffenseSchema, many=True)
    agency = ma.Nested(RefAgencySchema)
    cleared_except = ma.Nested(NibrsClearedExceptSchema)
    property = ma.Nested(NibrsPropertySchema, many=True)
    victims = ma.Nested(NibrsVictimSchema, many=True)
    arrestees = ma.Nested(NibrsArresteeSchema, many=True)
    offenders = ma.Nested(NibrsOffenderSchema, many=True)


class NibrsIncidentRepresentationSchema(ma.ModelSchema):
    class Meta:
        models = newmodels.NibrsIncidentRepresentation
        fields = ('representation', )

class CachedNibrsIncidentSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsIncident
        fields = ('incident_id', 'representation', )

    representation = ma.Nested(NibrsIncidentRepresentationSchema)


class NibrsAssignmentTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsAssignmentType
        exclude = ('assignment_type_id', 'victims', )
        ordered = True


class NibrsBiasListSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsBiasList
        exclude = ('bias_id', )
        ordered = True


class NibrsCircumstanceSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsCircumstance
        exclude = ('circumstances_id', )
        ordered = True


class NibrsCriminalActTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsCriminalActType
        exclude = ('criminal_act_id', 'criminal_acts', )
        ordered = True


class NibrsDrugMeasureTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsDrugMeasureType
        exclude = ('drug_measure_type_id', )
        ordered = True


class NibrsJustifiableForceSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsJustifiableForce
        exclude = ('justifiable_force_id', )
        ordered = True


class NibrsRelationshipSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsRelationship
        exclude = ('relationship_id', 'relationships', )
        ordered = True


class NibrsSuspectedDrugTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsSuspectedDrugType
        exclude = ('suspected_drug_type_id', )
        ordered = True


class OffenseClassificationSchema(ma.ModelSchema):
    class Meta:
        model = models.OffenseClassification
        ordered = True


class RetaOffenseSubcatSchema(ma.ModelSchema):
    class Meta:
        model = models.RetaOffenseSubcat
        exclude = ('offense',
                   'offense_subcat_sort_order',
                   'offense_subcat_xml_path', )


class RetaOffenseClassSchema(ma.ModelSchema):
    class Meta:
        model = models.OffenseClassification
        exclude = ('class_sort_order', )


class RetaOffenseSchema(ma.ModelSchema):
    class Meta:
        model = models.RetaOffense
        exclude = ('category',
                   'offense_category',
                   'offense_sort_order',
                   'offense_xml_path', )

    subcategories = ma.Nested(RetaOffenseSubcatSchema, many=True)
    classification = ma.Nested(RetaOffenseClassSchema)


class RetaOffenseCategorySchema(ma.ModelSchema):
    class Meta:
        model = models.RetaOffenseCategory
        exclude = ('crime_type', 'offense_category_sort_order', )

    offenses = ma.Nested(RetaOffenseSchema, many=True)


class CrimeTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.CrimeType
        exclude = ('crime_type_sort_order', )

    categories = ma.Nested(RetaOffenseCategorySchema, many=True)


class SuppLarcenyTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.SuppLarcenyType
        exclude = ('larceny_type_id', )
        ordered = True


class SuppPropertyTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.SuppPropertyType
        exclude = ('property_type_id', )
        ordered = True


### Count schemas
class IncidentCountSchema(Schema):
    """
    The basic response fields for an incident count query. There might
    be additional fields in each record if more detailed groupings are
    specified using the `by` parameter.
    """

    class Meta:
        ordered = True

    actual_count = marsh_fields.Integer(dump_only=True)
    reported_count = marsh_fields.Integer(dump_only=True)
    unfounded_count = marsh_fields.Integer(dump_only=True)
    cleared_count = marsh_fields.Integer(dump_only=True)
    juvenile_cleared_count = marsh_fields.Integer(dump_only=True)
    year = marsh_fields.Integer(dump_only=True)


class IncidentViewCountSchema(Schema):
    """
    The basic response fields for an incident - Pre-computed Materialized View - query.
    """

    class Meta:
        ordered = True

    count = marsh_fields.Integer(dump_only=True)
    state_id = marsh_fields.Integer(dump_only=True)
    county_id = marsh_fields.Integer(dump_only=True)
    year = marsh_fields.Integer(dump_only=True)
    race_code = marsh_fields.String(dump_only=True)
    sex_code = marsh_fields.String(dump_only=True)
    age_num = marsh_fields.String(dump_only=True)
    location_name = marsh_fields.String(dump_only=True)
    offense_name = marsh_fields.String(dump_only=True)
    prop_desc_name = marsh_fields.String(dump_only=True)
    victim_type_name = marsh_fields.String(dump_only=True)


class AgencyParticipationSchema(ma.ModelSchema):
    class Meta:
        model = newmodels.AgencyParticipation
        exclude = ('agency_id', )
        ordered = True


class ArsonCountSchema(Schema):
    """
    The basic response for an arson count response. These records might
    contain additional information depending on what fields are specified
    for the `by` parameter
    """

    class Meta:
        ordered = True

    actual_count = marsh_fields.Integer(dump_only=True)
    cleared_count = marsh_fields.Integer(dump_only=True)
    est_damage_value = marsh_fields.Integer(dump_only=True)
    juvenile_cleared_count = marsh_fields.Integer(dump_only=True)
    reported_count = marsh_fields.Integer(dump_only=True)
    unfounded_count = marsh_fields.Integer(dump_only=True)
    uninhabited_count = marsh_fields.Integer(dump_only=True)
    year = marsh_fields.Integer(dump_only=True)


class CountViewResponseSchema(Schema):

    count = marsh_fields.Integer(dump_only=True, required=True)
    year = marsh_fields.Integer(dump_only=True, required=True)


class CargoTheftCountViewResponseSchema(CountViewResponseSchema):

    stolen_value = marsh_fields.String(dump_only=True)
    recovered_value = marsh_fields.String(dump_only=True)


class OffenseCountViewResponseSchema(CountViewResponseSchema):

    offense_name = marsh_fields.String(dump_only=True)


class OffenseCargoTheftCountViewResponseSchema(CountViewResponseSchema):

    offense_name = marsh_fields.String(dump_only=True)
    stolen_value = marsh_fields.String(dump_only=True)
    recovered_value = marsh_fields.String(dump_only=True)

# response schemas
class PaginatedResponseSchema(Schema):
    """
    Many endpoints return paginated responses with both pagination and
    results subrecords
    """

    class Meta:
        ordered = True

    pagination = ma.Nested(PaginationSchema)


class AgenciesListResponseSchema(PaginatedResponseSchema):
    results = ma.Nested(RefAgencySchema, many=True)


class AgenciesDetailResponseSchema(PaginatedResponseSchema):
    results = ma.Nested(RefAgencySchema)

class AgenciesParticipationResponseSchema(PaginatedResponseSchema):
    results = ma.Nested(AgencyParticipationSchema)

class IncidentsCountResponseSchema(PaginatedResponseSchema):
    results = ma.Nested(IncidentCountSchema, many=True)


class IncidentsDetailResponseSchema(PaginatedResponseSchema):
    results = ma.Nested(NibrsIncidentSchema)


class IncidentsListResponseSchema(PaginatedResponseSchema):
    results = ma.Nested(NibrsIncidentSchema, many=True)


class OffensesListResponseSchema(PaginatedResponseSchema):
    results = ma.Nested(CrimeTypeSchema, many=True)


class ArsonCountResponseSchema(PaginatedResponseSchema):
    results = ma.Nested(ArsonCountSchema, many=True)


class CodeIndexResponseSchema(Schema):
    key = marsh_fields.String()


class StateCountyResponseSchema(ma.ModelSchema):
    """Schema for counties in the StateDetail response."""

    class Meta:
        model = cdemodels.CdeRefCounty
        fields = ('county_id', 'county_name', 'fips', 'population', )

    fips = marsh_fields.String()
    population = marsh_fields.Integer()


class ParticipationRateSchema(ma.ModelSchema):
    """Response format for participation record"""

    class Meta:
        model = newmodels.ParticipationRate
        ordered = True
        exclude = ('participation_id', 'state_id', 'state_abbr', 'state_name', )


class StateParticipationRateSchema(ParticipationRateSchema):
    class Meta:
        model = newmodels.ParticipationRate
        exclude = ('participation_id', )
        ordered = True


class StateDetailResponseSchema(ma.ModelSchema):
    """Response schema for the StateDetail API method."""

    class Meta:
        model = cdemodels.CdeRefState
        ordered = True
        fields = ('state_id', 'name', 'postal_abbr', 'fips_code', 'current_year',
                  'participating_agencies', 'participation_rate', 'participating_population',
                  'total_population', 'total_agencies', 'police_officers', 'counties',
                  'participation', )

    name = marsh_fields.String(attribute='state_name')
    postal_abbr = marsh_fields.String(attribute='state_postal_abbr')
    fips_code = marsh_fields.String(attribute='state_fips_code')
    total_population = marsh_fields.Integer()
    participating_population = marsh_fields.Integer()
    total_agencies = marsh_fields.Integer()
    participating_agencies = marsh_fields.Integer()
    participation_rate = marsh_fields.Float()
    police_officers = marsh_fields.Integer()
    current_year = marsh_fields.Integer()

    # This is not the most efficient, since it's a N queries for population, but
    # that is something we can fix later if a problem
    counties = ma.Nested(StateCountyResponseSchema,
                         attribute='counties',
                         many=True)
    participation = ma.Nested(ParticipationRateSchema,
                              attribute='participation_rates',
                              many=True)


class CountyDetailResponseSchema(ma.ModelSchema):
    """Response schema for the CountyDetail method."""

    class Meta:
        model = cdemodels.CdeRefCounty
        ordered = True
        fields = ('county_id', 'county_name',
                  'fips', 'population',
                  'num_agencies', 'police_officers',
                  'state_name', 'state_abbr', )

    fips = marsh_fields.String()
    population = marsh_fields.Integer()
    num_agencies = marsh_fields.Integer()
    police_officers = marsh_fields.Integer()
    state_name = marsh_fields.String()
    state_abbr = marsh_fields.String()


class AgencySchema(ma.ModelSchema):
    """Response schema for the CdeAgency table"""

    class Meta:
        model = newmodels.CdeAgency
        ordered = True
        exclude = ('agency_id', 'state_id', 'city_id',
                   'submitting_agency_id', 'covered_by_id', 'primary_county_id',
        )


class HtAgencySchema(ma.ModelSchema):
    """Response schema for the human trafficking endpoints"""
    class Meta:
        model = newmodels.HtAgency
        ordered = True
        exclude = ('id', 'agency_id', 'state_id', )


class HtSummarySchema(ma.ModelSchema):
    """Response schema for the summary endpoint"""
    class Meta:
        model = newmodels.HtSummary
        ordered = True
        exclude = ('id', 'agency_id', 'state_id', )


class EstimateSchema(ma.ModelSchema):
   """Response schema for the RetaEstimated table"""

   class Meta:
       model = newmodels.RetaEstimated
       ordered = True
       exclude = ('estimate_id', 'state_id', 'state', )


class NationalEstimateSchema(EstimateSchema):
    class Meta:
        exclude = ('estimate_id', 'state_id', 'state', 'state_abbr', )


class ArrestsNationalSchema(ma.ModelSchema):
    """Schema for the arrests national schema"""

    class Meta:
        model = newmodels.ArrestsNational
        ordered = True
        exclude = ('id', )


class RegionLKSchema(ma.ModelSchema):
    class Meta:
        model = lookupmodels.RegionLK
        ordered = True

class StateLKSchema(ma.ModelSchema):
    class Meta:
        model = lookupmodels.StateLK
        ordered = True

class NIBRSAgencyVictimDenormCountSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSAgencyVictimDenormCount
        ordered = True

class NIBRSAgencyVictimDenormSexSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSAgencyVictimDenormSex
        ordered = True

class NIBRSAgencyVictimDenormRaceSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSAgencyVictimDenormRace
        ordered = True

class NIBRSAgencyVictimDenormEthnicitySchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSAgencyVictimDenormEthnicity
        ordered = True

class NIBRSAgencyVictimDenormAgeSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSAgencyVictimDenormAge
        ordered = True

class NIBRSAgencyVictimDenormLocationSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSAgencyVictimDenormLocation
        ordered = True

class NIBRSAgencyOffenderDenormCountSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSAgencyOffenderDenormCount
        ordered = True

class NIBRSAgencyOffenderDenormSexSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSAgencyOffenderDenormSex
        ordered = True

class NIBRSAgencyOffenderDenormRaceSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSAgencyOffenderDenormRace
        ordered = True

class NIBRSAgencyOffenderDenormEthnicitySchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSAgencyOffenderDenormEthnicity
        ordered = True

class NIBRSAgencyOffenderDenormAgeSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSAgencyOffenderDenormAge
        ordered = True

class NIBRSStateVictimDenormCountSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSStateVictimDenormCount
        ordered = True

class NIBRSStateVictimDenormSexSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSStateVictimDenormSex
        ordered = True

class NIBRSStateVictimDenormRaceSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSStateVictimDenormRace
        ordered = True

class NIBRSStateVictimDenormEthnicitySchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSStateVictimDenormEthnicity
        ordered = True

class NIBRSStateVictimDenormAgeSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSStateVictimDenormAge
        ordered = True

class NIBRSStateVictimDenormLocationSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSStateVictimDenormLocation
        ordered = True

class NIBRSStateOffenderDenormCountSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSStateOffenderDenormCount
        ordered = True

class NIBRSStateOffenderDenormSexSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSStateOffenderDenormSex
        ordered = True

class NIBRSStateOffenderDenormRaceSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSStateOffenderDenormRace
        ordered = True

class NIBRSStateOffenderDenormEthnicitySchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSStateOffenderDenormEthnicity
        ordered = True

class NIBRSStateOffenderDenormAgeSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSStateOffenderDenormAge
        ordered = True


class NIBRSNationalVictimDenormCountSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSNationalVictimDenormCount
        ordered = True

class NIBRSNationalVictimDenormSexSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSNationalVictimDenormSex
        ordered = True

class NIBRSNationalVictimDenormRaceSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSNationalVictimDenormRace
        ordered = True

class NIBRSNationalVictimDenormEthnicitySchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSNationalVictimDenormEthnicity
        ordered = True

class NIBRSNationalVictimDenormAgeSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSNationalVictimDenormAge
        ordered = True

class NIBRSNationalVictimDenormLocationSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSNationalVictimDenormLocation
        ordered = True

class NIBRSNationalOffenderDenormCountSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSNationalOffenderDenormCount
        ordered = True

class NIBRSNationalOffenderDenormSexSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSNationalOffenderDenormSex
        ordered = True

class NIBRSNationalOffenderDenormRaceSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSNationalOffenderDenormRace
        ordered = True

class NIBRSNationalOffenderDenormEthnicitySchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSNationalOffenderDenormEthnicity
        ordered = True

class NIBRSNationalOffenderDenormAgeSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSNationalOffenderDenormAge
        ordered = True

class NIBRSNationalDenormVictimOffenderRelationshipSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSNationalDenormVictimOffenderRelationship
        ordered = True

class NIBRSAgencyDenormVictimOffenderRelationshipSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSAgencyDenormVictimOffenderRelationship
        ordered = True

class NIBRSStateDenormVictimOffenderRelationshipSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSStateDenormVictimOffenderRelationship
        ordered = True

class NIBRSNationalOffenseCountSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSNationalOffenseCount
        ordered = True

class NIBRSAgencyOffenseCountSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSAgencyOffenseCount
        ordered = True

class NIBRSStateOffenseCountSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.NIBRSStateOffenseCount
        ordered = True

class SHRStateHomicideVictimSexSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.SHRStateHomicideVictimSex
        ordered = True

class SHRNationalHomicideVictimSexSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.SHRNationalHomicideVictimSex
        ordered = True

class SHRStateHomicideVictimRaceSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.SHRStateHomicideVictimRace
        ordered = True

class SHRNationalHomicideVictimRaceSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.SHRNationalHomicideVictimRace
        ordered = True

class SHRStateHomicideVictimAgeSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.SHRStateHomicideVictimAge
        ordered = True

class SHRNationalHomicideVictimAgeSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.SHRNationalHomicideVictimAge
        ordered = True

class SHRStateHomicideVictimEthnicitySchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.SHRStateHomicideVictimEthnicity
        ordered = True

class SHRNationalHomicideVictimEthnicitySchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.SHRNationalHomicideVictimEthnicity
        ordered = True

class SHRStateHomicideOffenderSexSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.SHRStateHomicideOffenderSex
        ordered = True

class SHRNationalHomicideOffenderSexSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.SHRNationalHomicideOffenderSex
        ordered = True

class SHRStateHomicideOffenderRaceSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.SHRStateHomicideOffenderRace
        ordered = True

class SHRNationalHomicideOffenderRaceSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.SHRNationalHomicideOffenderRace
        ordered = True

class SHRStateHomicideOffenderAgeSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.SHRStateHomicideOffenderAge
        ordered = True

class SHRNationalHomicideOffenderAgeSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.SHRNationalHomicideOffenderAge
        ordered = True

class SHRStateHomicideOffenderEthnicitySchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.SHRStateHomicideOffenderEthnicity
        ordered = True

class SHRNationalHomicideOffenderEthnicitySchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.SHRNationalHomicideOffenderEthnicity
        ordered = True
