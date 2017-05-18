# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import pytest
from crime_data.common.cdemodels import OffenseCountView
from flex.core import validate_api_call

class TestOffensesEndpoint:
    def test_offenses_endpoint_exists(self, testapp, swagger):
        res = testapp.get('/offenses/')
        assert res.status_code == 200
#        validate_api_call(swagger, raw_request=res.request, raw_response=res)

    def test_offenses_endpoint_includes_metadata(self, testapp):
        res = testapp.get('/offenses/')
        assert 'pagination' in res.json

    def test_offenses_endpoint_returns_crime_types(self, testapp):
        res = testapp.get('/offenses/')
        assert len(res.json['results']) > 0
        assert 'crime_type_name' in res.json['results'][0]

    def test_offenses_endpoint_includes_categories(self, testapp):
        res = testapp.get('/offenses/')
        for crime_type in res.json['results']:
            assert 'categories' in crime_type
            for category in crime_type['categories']:
                assert 'offense_category_name' in category

    @pytest.mark.parametrize('variable', OffenseCountView.VARIABLES)
    def test_state_endpoint_count(self, testapp, swagger, variable):
        url = '/offenses/count/states/3/{}?year=2014'.format(variable)
        res = testapp.get(url)
        assert res.status_code == 200
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r

    def test_state_endpoint_count_with_postal_code(self, testapp, swagger):
        url = '/offenses/count/states/AR/weapon_name?year=2014'
        res = testapp.get(url)
        assert res.status_code == 200
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r

    def test_state_endpoint_count_with_agencies(self, testapp, swagger):
        url = '/offenses/count/agencies/MI2336700/weapon_name?year=2014'
        res = testapp.get(url)
        assert res.status_code == 200
        #validate_api_call(swagger, raw_request=res.request, raw_response=res)
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r

    @pytest.mark.parametrize('variable', OffenseCountView.VARIABLES)
    def test_national_endpoint_count(self, testapp, swagger, variable):
        url = '/offenses/count/national/{}?year=2014'.format(variable)
        res = testapp.get(url)
        assert res.status_code == 200
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r
            
