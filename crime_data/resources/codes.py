from webargs.flaskparser import use_args

from crime_data.common import marshmallow_schemas, models
from crime_data.common.base import CdeResource
from crime_data.common.marshmallow_schemas import ArgumentsSchema


class CodeReferenceList(CdeResource):
    models = {
        'asr_age_range': models.AsrAgeRange,
        'asr_ethnicity': models.AsrEthnicity,
        'asr_offense': models.AsrOffense,
        'asr_offense_category': models.AsrOffenseCategory,
        'crime_type': models.CrimeType,
        'nibrs_activity_type': models.NibrsActivityType,
        'nibrs_age': models.NibrsAge,
        'nibrs_arrest_type': models.NibrsArrestType,
        'nibrs_assignment_type': models.NibrsAssignmentType,
        'nibrs_bias_list': models.NibrsBiasList,
        'nibrs_circumstance': models.NibrsCircumstance,
        'nibrs_criminal_act_type': models.NibrsCriminalActType,
        'nibrs_cleared_except': models.NibrsClearedExcept,
        'nibrs_drug_measure_type': models.NibrsDrugMeasureType,
        'nibrs_ethnicity': models.NibrsEthnicity,
        'nibrs_injury': models.NibrsInjury,
        'nibrs_justifiable_force': models.NibrsJustifiableForce,
        'nibrs_location_type': models.NibrsLocationType,
        'nibrs_offense_type': models.NibrsOffenseType,
        'nibrs_prop_desc_type': models.NibrsPropDescType,
        'nibrs_prop_loss_type': models.NibrsPropLossType,
        'nibrs_relationship': models.NibrsRelationship,
        'nibrs_suspected_drug_type': models.NibrsSuspectedDrugType,
        'nibrs_victim_type': models.NibrsVictimType,
        'nibrs_weapon_type': models.NibrsWeaponType,
        'offense_classification': models.OffenseClassification,
        'ref_agency_type': models.RefAgencyType,
        'ref_city': models.RefCity,
        'ref_continent': models.RefContinent,
        'ref_county': models.RefCounty,
        'ref_country': models.RefCountry,
        'ref_msa': models.RefMsa,
        'ref_race': models.RefRace,
        'ref_state': models.RefState,
        'ref_tribe': models.RefTribe,
        'ref_university': models.RefUniversity,
        'reta_offense_category': models.RetaOffenseCategory,
        'supp_larceny_type': models.SuppLarcenyType,
        'supp_property_type': models.SuppPropertyType
    }

    schemas = {
        'asr_age_range': marshmallow_schemas.AsrAgeRangeSchema,
        'asr_ethnicity': marshmallow_schemas.AsrEthnicitySchema,
        'asr_offense': marshmallow_schemas.AsrOffenseSchema,
        'asr_offense_category': marshmallow_schemas.AsrOffenseCategorySchema,
        'crime_type': marshmallow_schemas.CrimeTypeSchema,
        'nibrs_activity_type': marshmallow_schemas.NibrsActivityTypeSchema,
        'nibrs_age': marshmallow_schemas.NibrsAgeSchema,
        'nibrs_arrest_type': marshmallow_schemas.NibrsArrestTypeSchema,
        'nibrs_assignment_type': marshmallow_schemas.NibrsAssignmentTypeSchema,
        'nibrs_bias_list': marshmallow_schemas.NibrsBiasListSchema,
        'nibrs_circumstance': marshmallow_schemas.NibrsCircumstanceSchema,
        'nibrs_cleared_except': marshmallow_schemas.NibrsClearedExceptSchema,
        'nibrs_criminal_act_type': marshmallow_schemas.NibrsCriminalActTypeSchema,
        'nibrs_drug_measure_type': marshmallow_schemas.NibrsDrugMeasureTypeSchema,
        'nibrs_ethnicity': marshmallow_schemas.NibrsEthnicitySchema,
        'nibrs_injury': marshmallow_schemas.NibrsInjurySchema,
        'nibrs_justifiable_force': marshmallow_schemas.NibrsJustifiableForceSchema,
        'nibrs_location_type': marshmallow_schemas.NibrsLocationTypeSchema,
        'nibrs_offense_type': marshmallow_schemas.NibrsOffenseTypeSchema,
        'nibrs_prop_desc_type': marshmallow_schemas.NibrsPropDescTypeSchema,
        'nibrs_prop_loss_type': marshmallow_schemas.NibrsPropLossTypeSchema,
        'nibrs_relationship': marshmallow_schemas.NibrsRelationshipSchema,
        'nibrs_suspected_drug_type': marshmallow_schemas.NibrsSuspectedDrugTypeSchema,
        'nibrs_victim_type': marshmallow_schemas.NibrsVictimTypeSchema,
        'nibrs_weapon_type': marshmallow_schemas.NibrsWeaponTypeSchema,
        'offense_classification': marshmallow_schemas.OffenseClassificationSchema,
        'ref_agency_type': marshmallow_schemas.RefAgencyTypeSchema,
        'ref_city': marshmallow_schemas.RefCitySchema,
        'ref_continent': marshmallow_schemas.RefContinentSchema,
        'ref_county': marshmallow_schemas.RefCountySchema,
        'ref_country': marshmallow_schemas.RefCountrySchema,
        'ref_msa': marshmallow_schemas.RefMsaSchema,
        'ref_race': marshmallow_schemas.RefRaceSchema,
        'ref_state': marshmallow_schemas.RefStateSchema,
        'ref_tribe': marshmallow_schemas.RefTribeSchema,
        'ref_university': marshmallow_schemas.RefUniversitySchema,
        'reta_offense_category': marshmallow_schemas.RetaOffenseCategorySchema,
        'supp_larceny_type': marshmallow_schemas.SuppLarcenyTypeSchema,
        'supp_property_type': marshmallow_schemas.SuppPropertyTypeSchema
    }

    @use_args(ArgumentsSchema)
    def get(self, args, code_table, output=None):
        self.schema = self.schemas[code_table](many=True)
        output = args['output'] if output is None else output
        codes = self.models[code_table].query
        if output == 'csv':
            return self.as_csv_response(codes, code_table, args)
        else:
            return self.with_metadata(codes, args)
