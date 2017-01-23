# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import pytest
from crime_data.common.marshmallow_schemas import VICTIM_COUNT_VARIABLE_ENUM

class TestVictimsEndpoint:

    @pytest.mark.parametrize('variable', VICTIM_COUNT_VARIABLE_ENUM)
    def test_state_endpoint_count(self, testapp, variable):
        url = '/victims/count/states/3/{}?year=2014'.format(variable)
        res = testapp.get(url)
        assert res.status_code == 200
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r

    @pytest.mark.parametrize('variable', VICTIM_COUNT_VARIABLE_ENUM)
    def test_state_endpoint_count(self, testapp, variable):
        url = '/victims/count/national/{}?year=2014'.format(variable)
        res = testapp.get(url)
        assert res.status_code == 200
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r

    @pytest.mark.xfail
    def test_state_endpoint_no_year_in_request(self, testapp):
        res = testapp.get('/victims/count/states/3/race_code')
        assert res.status_code == 500
