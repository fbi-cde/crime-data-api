# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import pytest
from crime_data.resources.beta.codes import CODE_MODELS
from flex.core import validate_api_call


class TestCodesIndex:
    """Test the /codes URL endpoint"""

    def test_codes_index_exists(self, testapp, swagger_beta):
        res = testapp.get('/codes')
        assert res.status_code == 200
        validate_api_call(swagger_beta, raw_request=res.request, raw_response=res)

class TestCodesEndpoint:
    """Test the /codes/* methods"""

    @pytest.mark.parametrize('table,id_col', [
        ('arson_subcategory', 'subcategory_code'),
        ('arson_subclassification', 'subclass_code'),
        ('asr_age_range', 'age_range_code'),
        ('asr_ethnicity', 'ethnicity_code'),
        ('asr_offense', 'offense_code'),
        ('asr_offense_category', 'offense_cat_code'),
        ('asr_offense_subcat', 'offense_subcat_code'),
        ('crime_type', 'crime_type_id'),
        ('nibrs_activity_type', 'activity_type_code'),
        ('nibrs_age', 'age_code'),
        ('nibrs_arrest_type', 'arrest_type_code'),
        ('nibrs_assignment_type', 'assignment_type_code'),
        ('nibrs_bias_list', 'bias_code'),
        ('nibrs_circumstance', 'circumstances_code'),
        ('nibrs_criminal_act_type', 'criminal_act_code'),
        ('nibrs_cleared_except', 'cleared_except_code'),
        ('nibrs_drug_measure_type', 'drug_measure_code'),
        ('nibrs_ethnicity', 'ethnicity_code'),
        ('nibrs_injury', 'injury_code'),
        ('nibrs_justifiable_force', 'justifiable_force_code'),
        ('nibrs_location_type', 'location_code'),
        ('nibrs_offense_type', 'offense_code'),
        ('nibrs_prop_desc_type', 'prop_desc_code'),
        ('nibrs_prop_loss_type', 'prop_loss_id'),
        ('nibrs_relationship', 'relationship_code'),
        ('nibrs_suspected_drug_type', 'suspected_drug_code'),
        ('nibrs_using_list', 'suspect_using_code'),
        ('nibrs_victim_type', 'victim_type_code'),
        ('nibrs_weapon_type', 'weapon_code'),
        ('offense_classification', 'classification_id'),
        ('ref_agency_type', 'agency_type_id'),
        ('ref_continent', 'continent_id'),
        ('ref_county', 'county_id'),
        ('ref_country', 'country_id'),
        ('ref_metro_division', 'metro_div_id'),
        ('ref_msa', 'msa_id'),
        ('ref_population_group', 'population_group_code'),
        ('ref_race', 'race_code'),
        ('ref_state', 'state_code'),
        ('ref_tribe', 'tribe_id'),
        ('ref_university', 'university_id'),
        ('reta_offense', 'offense_code'),
        ('reta_offense_category', 'offense_category_id'),
        ('reta_offense_subcat', 'offense_subcat_code'),
        ('supp_larceny_type', 'larceny_type_code'),
        ('supp_property_type', 'prop_type_code')
    ])
    def test_codes_endpoint_exists(self, testapp, swagger_beta, table, id_col):
        res = testapp.get('/codes/{0}'.format(table))
        validate_api_call(swagger_beta, raw_request=res.request, raw_response=res)
        assert res.status_code == 200
        assert id_col in res.json[0]

        res = testapp.get('/codes/{0}.csv'.format(table))
        assert res.status_code == 200

    @pytest.mark.parametrize('table,key', [
        ('nibrs_arrest_type', 'arrestees'),
        ('nibrs_assignment_type', 'victims'),
        ('nibrs_criminal_act_type', 'criminal_acts'),
        ('nibrs_relationship', 'relationships'),
        ('nibrs_weapon_type', 'weapons')
    ])
    def test_codes_dont_have_backwards_associations(self, testapp, table, key):
        res = testapp.get('/codes/{0}'.format(table))
        assert res.status_code == 200
        assert key not in res.json[0]
