# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
from flex.core import validate_api_call

class TestHateCrimeEndpoint:

    def test_state_endpoint_count(self, testapp, swagger):
        url = '/hc/count/states/3/bias_name?year=2014'
        res = testapp.get(url)
        assert res.status_code == 200
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r

    def test_state_endpoint_count_with_postal_code(self, testapp, swagger):
        url = '/hc/count/states/AR/bias_name?year=2014'
        res = testapp.get(url)
        assert res.status_code == 200
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r

    def test_national_endpoint_count(self, testapp, swagger):
        url = '/hc/count/national/bias_name?year=2014'
        res = testapp.get(url)
        assert res.status_code == 200
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r

    def test_state_endpoint_no_year_in_request(self, testapp):
        res = testapp.get('/hc/count/states/3/bias_name')
        # returns all years?
        assert res.status_code == 200
