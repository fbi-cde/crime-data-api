# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import pytest
from crime_data.common.cdemodels import VictimCountView
from flex.core import validate_api_call

class TestVictimsEndpoint:

    @pytest.mark.parametrize('variable', VictimCountView.VARIABLES)
    def test_state_endpoint_count(self, testapp, swagger, variable):
        url = '/victims/count/states/3/{}?year=2014'.format(variable)
        res = testapp.get(url)
        assert res.status_code == 200
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert variable in r
        validate_api_call(swagger, raw_request=res.request, raw_response=res)


    def test_state_endpoint_count_with_postal_code(self, testapp, swagger):
        url = '/victims/count/states/AR/race_code?year=2014'
        res = testapp.get(url)
        assert res.status_code == 200
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'race_code' in r
        validate_api_call(swagger, raw_request=res.request, raw_response=res)

    @pytest.mark.parametrize('variable', VictimCountView.VARIABLES)
    def test_national_endpoint_count(self, testapp, swagger, variable):
        url = '/victims/count/national/{}?year=2014'.format(variable)
        res = testapp.get(url)
        assert res.status_code == 200
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert variable in r
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
