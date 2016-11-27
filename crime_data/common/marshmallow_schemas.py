# coding: utf-8

import os

from flask_marshmallow import Marshmallow
from marshmallow import fields as marsh_fields
from marshmallow import Schema, post_dump

from . import cdemodels, models

ma = Marshmallow()

# Map of age codes to correct null values.
AGE_CODES = {'BB': 0, 'NB': 0, 'NN': 0, '99': 99, }


class SchemaFormater(object):
    @classmethod
    def format_age(cls, data):
        """Turns the age_num field into
        something a little more useful.
        """
        if 'age_num' in data and data['age']:
            if data['age']['age_code'] in AGE_CODES:
                data['age_num'] = AGE_CODES[data['age']['age_code']]
        return data


# Schemas for request parsing
class ArgumentsSchema(Schema):
    output = marsh_fields.String(missing='json')
    aggregate_many = marsh_fields.String(missing='false')
    page = marsh_fields.Integer(missing=1)
    per_page = marsh_fields.Integer(missing=10)
    fields = marsh_fields.String()
    tuning = marsh_fields.Boolean(missing=False)
    if os.getenv('VCAP_APPLICATION'):
        api_key = marsh_fields.String(
            required=True,
            error_messages={'required': 'Get API key from Catherine'})


class GroupableArgsSchema(ArgumentsSchema):
    by = marsh_fields.String(missing='year')


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
    by = marsh_fields.String(missing='ori')


class AgenciesRetaArgsSchema(ArgumentsSchema):
    state = marsh_fields.String()
    ori = marsh_fields.String()
    victim_ethnicity = marsh_fields.String()
    offender_ethnicity = marsh_fields.String()
    by = marsh_fields.String(missing='ori')

# Schemas for data serialization


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
        exclude = ('weapons', )


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
        exclude = ('city_id', 'state', )
        ordered = True

#    state = ma.Nested(RefStateSchema)

class RefContinentSchema(ma.ModelSchema):
    class Meta:
        model = models.RefContinent
        exclude = ('continent_id', )
        ordered = True


class RefCountySchema(ma.ModelSchema):
    class Meta:
        model = models.RefCounty
        exclude = ('county_id', 'state', )
        ordered = True

    state = ma.Nested(RefStateSchema)


class RefCountrySchema(ma.ModelSchema):
    class Meta:
        model = models.RefCounty
        exclude = ('country_id', 'continent', )
        ordered = True

    state = ma.Nested(RefContinentSchema)


class RefMsaSchema(ma.ModelSchema):
    class Meta:
        model = models.RefMsa
        exclude = ('msa_id', )
        ordered = True

    state = ma.Nested(RefContinentSchema)


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


class RefUniversitySchema(ma.ModelSchema):
    class Meta:
        model = models.RefUniversity
        exclude = ('university_id', )

        
class RefAgencySchema(ma.ModelSchema, ArgumentsSchema):
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
        exclude = ('incident', 'offense_id', )

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


class NibrsInjurySchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsInjury
        exclude = ('injury_id', )
        ordered = True


class NibrsVictimTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsVictimType
        exclude = ('victim_type_id', 'victims', )


class NibrsWeaponTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsWeaponType
        exclude = ('weapon_id', )
        ordered = True


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
        exclude = ('victim_seq_num', 'victim_id', )

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
        exclude = ('arrest_type_id', )
        ordered = True


class NibrsOffenderSchema(ma.ModelSchema, SchemaFormater):
    class Meta:
        model = models.NibrsOffender
        exclude = ('offender_id',
                   'incident',
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


class NibrsAssignmentTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsAssignmentType
        exclude = ('assignment_type_id', )
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
        exclude = ('criminal_act_id', )
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
        exclude = ('relationship_id', )
        ordered = True


class NibrsSuspectedDrugTypeSchema(ma.ModelSchema):
    class Meta:
        model = models.NibrsSuspectedDrugType
        exclude = ('suspected_drug_type_id', )
        ordered = True


class OffenseClassificationSchema(ma.ModelSchema):
    class Meta:
        model = models.OffenseClassification
        exclude = ('classification_id', )
        ordered = True


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
