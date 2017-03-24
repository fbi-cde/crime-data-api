# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import pytest
from crime_data.common.cdemodels import OffenseOffenderCountView
from crime_data.common.base import ExplorerOffenseMapping
from flex.core import validate_api_call

class TestOffendersOffensesEndpoint:
    def test_state_endpoint_no_year_in_request(self, testapp, swagger):
        res = testapp.get('/offenders/count/states/3/race_code/offenses')
        assert 'pagination' in res.json
        assert res.status_code == 200
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        for r in res.json['results']:
            assert 'count' in r

    @pytest.mark.parametrize('variable', OffenseOffenderCountView.VARIABLES)
    def test_offenders_offenses_endpoint_with_just_state_year(self, testapp, swagger, variable):
        url = '/offenders/count/states/43/{}/offenses?year=2014'.format(variable)
        res = testapp.get(url)
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r

    @pytest.mark.parametrize('variable', OffenseOffenderCountView.VARIABLES)
    def test_offenders_offenses_endpoint_with_state_postal_code(self, testapp, swagger, variable):
        url = '/offenders/count/states/AR/{}/offenses?year=2014'.format(variable)
        res = testapp.get(url)
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r

    @pytest.mark.parametrize('variable', OffenseOffenderCountView.VARIABLES)
    def test_offenders_offenses_endpoint_with_state_year_offense(self, testapp, swagger, variable):
        url = '/offenders/count/states/43/{}/offenses?offense_name=Aggravated+Assault&year=2014'.format(variable)
        res = testapp.get(url)
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r

    @pytest.mark.parametrize('variable', OffenseOffenderCountView.VARIABLES)
    @pytest.mark.parametrize('explorer_offense', ExplorerOffenseMapping.NIBRS_OFFENSE_MAPPING.keys())
    def test_offenders_offenses_endpoint_with_state_year_explorer_offense(self, testapp, swagger, variable, explorer_offense):
        url = '/offenders/count/states/43/{}/offenses?explorer_offense={}&year=2014'.format(variable, explorer_offense)
        res = testapp.get(url)
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r
