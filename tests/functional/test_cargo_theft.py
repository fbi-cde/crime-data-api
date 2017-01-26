# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import pytest
from crime_data.common.cdemodels import CargoTheftCountView


class TestCargoTheftEndpoint:

    @pytest.mark.parametrize('variable', CargoTheftCountView.VARIABLES)
    def test_state_endpoint_count(self, testapp, variable):
        url = '/ct/count/states/3/{}?year=2014'.format(variable)
        res = testapp.get(url)
        assert res.status_code == 200
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r

    @pytest.mark.parametrize('variable', CargoTheftCountView.VARIABLES)
    def test_national_endpoint_count(self, testapp, variable):
        url = '/ct/count/national/{}?year=2014'.format(variable)
        res = testapp.get(url)
        assert res.status_code == 200
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r

    def test_state_endpoint_no_year_in_request(self, testapp):
        res = testapp.get('/ct/count/states/3/prop_desc_name')
        # returns all years?
        assert res.status_code == 200
