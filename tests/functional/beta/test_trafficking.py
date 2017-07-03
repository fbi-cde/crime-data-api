# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import pytest
from crime_data.common.newmodels import HtAgency
from flex.core import validate_api_call

class TestHtAgenciesEndpoint:

    def test_agencies_endpoint(self, testapp, swagger_beta):
        res = testapp.get('/ht/agencies?state_abbr=RI')
        assert res.status_code == 200
        validate_api_call(swagger_beta, raw_request=res.request, raw_response=res)

    @pytest.mark.parametrize('field,value', [
        ['state_abbr', 'HI'],
        ['ori', 'HI0020000']])
    def test_agencies_filter(self, testapp, swagger_beta, field, value):
        url = '/ht/agencies?{}={}'.format(field, value)
        res = testapp.get(url)
        assert res.status_code == 200
        validate_api_call(swagger_beta, raw_request=res.request, raw_response=res)

    def test_states_endpoint(self, testapp, swagger_beta):
        res = testapp.get('/ht/states?state_abbr=RI')
        assert res.status_code == 200
        validate_api_call(swagger_beta, raw_request=res.request, raw_response=res)

        res = testapp.get('/ht/states?year=2015&state_abbr=RI')
        assert res.status_code == 200
        validate_api_call(swagger_beta, raw_request=res.request, raw_response=res)
