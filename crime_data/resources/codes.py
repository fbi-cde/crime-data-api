from flask import url_for, jsonify
from webargs.flaskparser import use_args

from crime_data.common import marshmallow_schemas, models
from crime_data.common.base import CdeResource, cache_for
from crime_data.common.marshmallow_schemas import (ArgumentsSchema,
                                                   CodeIndexResponseSchema)

CODE_MODELS = {
    'arson_subcategory': models.ArsonSubcategory,
    'arson_subclassification': models.ArsonSubclassification,
    'asr_age_range': models.AsrAgeRange,
    'asr_ethnicity': models.AsrEthnicity,
    'asr_offense': models.AsrOffense,
    'asr_offense_category': models.AsrOffenseCategory,
    'asr_offense_subcat': models.AsrOffenseSubcat,
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
    'nibrs_using_list': models.NibrsUsingList,
    'nibrs_victim_type': models.NibrsVictimType,
    'nibrs_weapon_type': models.NibrsWeaponType,
    'offense_classification': models.OffenseClassification,
    'ref_agency_type': models.RefAgencyType,
    'ref_continent': models.RefContinent,
    'ref_county': models.RefCounty,
    'ref_country': models.RefCountry,
    'ref_metro_division': models.RefMetroDivision,
    'ref_msa': models.RefMsa,
    'ref_population_group': models.RefPopulationGroup,
    'ref_race': models.RefRace,
    'ref_state': models.RefState,
    'ref_tribe': models.RefTribe,
    'ref_university': models.RefUniversity,
    'reta_offense': models.RetaOffense,
    'reta_offense_category': models.RetaOffenseCategory,
    'reta_offense_subcat': models.RetaOffenseSubcat,
    'supp_larceny_type': models.SuppLarcenyType,
    'supp_property_type': models.SuppPropertyType
}

CODE_SCHEMAS = {
    'arson_subcategory': marshmallow_schemas.ArsonSubcategorySchema,
    'arson_subclassification': marshmallow_schemas.ArsonSubclassificationSchema,
    'asr_age_range': marshmallow_schemas.AsrAgeRangeSchema,
    'asr_ethnicity': marshmallow_schemas.AsrEthnicitySchema,
    'asr_offense': marshmallow_schemas.AsrOffenseSchema,
    'asr_offense_category': marshmallow_schemas.AsrOffenseCategorySchema,
    'asr_offense_subcat': marshmallow_schemas.AsrOffenseSubcatSchema,
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
    'nibrs_using_list': marshmallow_schemas.NibrsUsingListSchema,
    'nibrs_victim_type': marshmallow_schemas.NibrsVictimTypeSchema,
    'nibrs_weapon_type': marshmallow_schemas.NibrsWeaponTypeSchema,
    'offense_classification': marshmallow_schemas.OffenseClassificationSchema,
    'ref_agency_type': marshmallow_schemas.RefAgencyTypeSchema,
    'ref_continent': marshmallow_schemas.RefContinentSchema,
    'ref_county': marshmallow_schemas.RefCountySchema,
    'ref_country': marshmallow_schemas.RefCountrySchema,
    'ref_metro_division': marshmallow_schemas.RefMetroDivision,
    'ref_msa': marshmallow_schemas.RefMsaSchema,
    'ref_population_group': marshmallow_schemas.RefPopulationGroupSchema,
    'ref_race': marshmallow_schemas.RefRaceSchema,
    'ref_state': marshmallow_schemas.RefStateSchema,
    'ref_tribe': marshmallow_schemas.RefTribeSchema,
    'ref_university': marshmallow_schemas.RefUniversitySchema,
    'reta_offense': marshmallow_schemas.RetaOffenseSchema,
    'reta_offense_category': marshmallow_schemas.RetaOffenseCategorySchema,
    'reta_offense_subcat': marshmallow_schemas.RetaOffenseSubcatSchema,
    'supp_larceny_type': marshmallow_schemas.SuppLarcenyTypeSchema,
    'supp_property_type': marshmallow_schemas.SuppPropertyTypeSchema
}


class CodeReferenceIndex(CdeResource):
    @cache_for(3600)
    def get(self):
        endpoints = {key: url_for('codereferencelist', code_table=key)
                     for key in CODE_SCHEMAS}
        return jsonify(endpoints)


class CodeReferenceList(CdeResource):
    @use_args(ArgumentsSchema)
    @cache_for(3600)
    def get(self, args, code_table, output=None):
        self.schema = CODE_SCHEMAS[code_table](many=True)
        output = args['output'] if output is None else output
        codes = CODE_MODELS[code_table].query
        if output == 'csv':
            return self.as_csv_response(codes, code_table, args)
        else:
            return jsonify(self.schema.dump(codes).data)
