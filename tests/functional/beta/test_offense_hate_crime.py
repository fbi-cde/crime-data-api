# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import pytest
from crime_data.common.cdemodels import OffenseHateCrimeCountView
from crime_data.common.base import ExplorerOffenseMapping
from flex.core import validate_api_call

class TestOffendersOffensesEndpoint:
    def test_state_endpoint_no_year_in_request(self, testapp, swagger):
        res = testapp.get('/hc/count/states/3/bias_name/offenses')
        assert 'pagination' in res.json
        assert res.status_code == 200
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        for r in res.json['results']:
            assert 'count' in r

    def test_state_endpoint_no_year_in_request_with_postal_code(self, swagger, testapp):
        res = testapp.get('/hc/count/states/AR/bias_name/offenses')
        assert 'pagination' in res.json
        assert res.status_code == 200
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        for r in res.json['results']:
            assert 'count' in r

    @pytest.mark.parametrize('variable', OffenseHateCrimeCountView.VARIABLES)
    def test_victims_offenses_endpoint_with_just_state_year(self, testapp, swagger, variable):
        url = '/hc/count/states/43/{}/offenses?year=2014'.format(variable)
        res = testapp.get(url)
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r

    def test_victims_offenses_endpoint_with_just_state_year_and_postal_code(self, testapp, swagger):
        url = '/hc/count/states/NY/bias_name/offenses?year=2014'
        res = testapp.get(url)
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r

    def test_victims_offenses_endpoint_with_just_state_year_and_postal_code(self, testapp, swagger):
        url = '/hc/count/agencies/MI2336700/bias_name/offenses?year=2014'
        res = testapp.get(url)
        #validate_api_call(swagger, raw_request=res.request, raw_response=res)
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r

    @pytest.mark.parametrize('variable', OffenseHateCrimeCountView.VARIABLES)
    def test_victims_offenses_endpoint_with_state_year_offense(self, testapp, swagger, variable):
        url = '/hc/count/states/43/{}/offenses?offense_name=Aggravated+Assault&year=2014'.format(variable)
        res = testapp.get(url)
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r

    @pytest.mark.parametrize('variable', OffenseHateCrimeCountView.VARIABLES)
    @pytest.mark.parametrize('explorer_offense', ExplorerOffenseMapping.NIBRS_OFFENSE_MAPPING.keys())
    def test_victims_offenses_endpoint_with_state_year_offense(self, testapp, swagger, variable, explorer_offense):
        url = '/hc/count/states/43/{}/offenses?explorer_offense={}&year=2014'.format(variable, explorer_offense)
        res = testapp.get(url)
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r
