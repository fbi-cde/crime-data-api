# coding: utf-8

import os

from flask_marshmallow import Marshmallow
from marshmallow import fields as marsh_fields
from marshmallow import Schema

from . import cdemodels, models

ma = Marshmallow()


# Schemas for request parsing
class ArgumentsSchema(Schema):
    page = marsh_fields.Integer(missing=1)
    per_page = marsh_fields.Integer(missing=10)
    fields = marsh_fields.String()
    if os.getenv('VCAP_APPLICATION'):
        api_key = marsh_fields.String(
            required=True,
            error_messages={'required': 'Get API key from Catherine'})


class AgenciesIncidentArgsSchema(ArgumentsSchema):
    incident_hour = marsh_fields.Integer()
    crime_against = marsh_fields.String()
    offense_code = marsh_fields.String()
    offense_name = marsh_fields.String()
    offense_category_name = marsh_fields.String()
    method_entry_code = marsh_fields.String()
    location_code = marsh_fields.String()
    location_name = marsh_fields.String()
    state = marsh_fields.String()


class AgenciesRetaArgsSchema(ArgumentsSchema):
    state = marsh_fields.String()
    ori = marsh_fields.String()
    victim_ethnicity = marsh_fields.String()
    offender_ethnicity = marsh_fields.String()
    by = marsh_fields.String(missing='ori')


class IncidentCountArgsSchema(ArgumentsSchema):
    by = marsh_fields.String(missing='year')

    # Schemas for data serialization


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
        model = models.RefRegion
        exclude = ('region_id', )


class RefDivisionSchema(ma.ModelSchema):
    class Meta:
        model = models.RefDivision
        exclude = ('division_id', )

    region = ma.Nested(RefRegionSchema)


class RefStateSchema(ma.ModelSchema):
    class Meta:
        model = models.RefState
        exclude = ('state_id', )

    division = ma.Nested(RefDivisionSchema)


class RefCitySchema(ma.ModelSchema):
    class Meta:
        model = models.RefCity
        exclude = ('city_id', )

    # state = ma.Nested(RefStateSchema)


class RefPopulationFamilySchema(ma.ModelSchema):
    class Meta:
        model = models.RefPopulationFamily
        exclude = ('population_family_id', )


class RefFieldOfficeSchema(ma.ModelSchema):
    class Meta:
        model = models.RefFieldOffice
        exclude = ('field_office_id', )


class RefAgencyTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.RefAgencyType
        exclude = ('agency_type_id', 'default_pop_family_id', )


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
        exclude = ('tribe_id', )


class RefAgencySchema(ma.ModelSchema):
    class Meta:
        model = models.RefAgency

    city = ma.Nested(RefCitySchema)
    state = ma.Nested(RefStateSchema)
    agency_type = ma.Nested(RefAgencyTypeSchema)
    department = ma.Nested(RefDepartmentSchema)
    field_office = ma.Nested(RefFieldOfficeSchema)
    population_family = ma.Nested(RefPopulationFamilySchema)
    submitting_agency = ma.Nested(RefSubmittingAgencySchema)
    tribe = ma.Nested(RefTribeSchema)


class RetaMonthSchema(ma.ModelSchema):
    class Meta:
        model = models.RetaMonth
        exclude = ('reta_month_id', )

    agency = ma.Nested(RefAgencySchema)


class RefRaceSchema(ma.ModelSchema):
    class Meta:
        model = models.RefRace
        exclude = ('race_id',
                   'arrestees',
                   'offenders',
                   'victims',
                   'sort_order', )


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


class NibrsPropLossTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsPropLossType
        exclude = ('prop_loss_id', 'property', )


class NibrsPropertySchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsProperty
        exclude = ('incident', 'property_id', )

    prop_loss = ma.Nested(NibrsPropLossTypeSchema)


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


class NibrsActivityTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsActivityType
        exclude = ('activity_type_id', 'victims', )


class NibrsVictimSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsVictim
        exclude = ('victim_id', 'victim_seq_num', )

    ethnicity = ma.Nested(NibrsEthnicitySchema)
    race = ma.Nested(RefRaceSchema)
    victim_type = ma.Nested(NibrsVictimTypeSchema)
    age = ma.Nested(NibrsAgeSchema)
    activity_type = ma.Nested(NibrsActivityTypeSchema)


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


class RetaOffenseSubcatSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.CdeRetaOffenseSubcat
        exclude = ('offense',
                   'offense_subcat_sort_order',
                   'offense_subcat_xml_path', )


class RetaOffenseClassSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.CdeOffenseClassification
        exclude = ('class_sort_order', )


class RetaOffenseSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.CdeRetaOffense
        exclude = ('category',
                   'offense_category',
                   'offense_sort_order',
                   'offense_xml_path', )

    subcategories = ma.Nested(RetaOffenseSubcatSchema, many=True)
    classification = ma.Nested(RetaOffenseClassSchema)


class RetaOffenseCategorySchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.CdeRetaOffenseCategory
        exclude = ('crime_type', 'offense_category_sort_order', )

    offenses = ma.Nested(RetaOffenseSchema, many=True)


class CrimeTypeSchema(ma.ModelSchema):
    class Meta:
        model = cdemodels.CdeCrimeType
        exclude = ('crime_type_sort_order', )

    categories = ma.Nested(RetaOffenseCategorySchema, many=True)
