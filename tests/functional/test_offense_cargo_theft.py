# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import pytest
from crime_data.common.cdemodels import OffenseCargoTheftCountView

class TestVictimsEndpoint:
    def test_state_endpoint_no_year_in_request(self, testapp):
        res = testapp.get('/ct/count/states/3/prop_desc_name/offenses')
        assert 'pagination' in res.json
        assert res.status_code == 200
        for r in res.json['results']:
            assert 'count' in r
            assert 'recovered_value' in r
            assert 'stolen_value' in r

    @pytest.mark.parametrize('variable', OffenseCargoTheftCountView.VARIABLES)
    def test_victims_offenses_endpoint_with_just_state_year(self, testapp, variable):
        url = '/ct/count/states/43/{}/offenses?year=2014'.format(variable)
        res = testapp.get(url)
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r
            assert 'stolen_value' in r
            assert 'recovered_value' in r

    @pytest.mark.parametrize('variable', OffenseCargoTheftCountView.VARIABLES)
    def test_victims_offenses_endpoint_with_state_year_offense(self, testapp, variable):
        url = '/ct/count/states/43/{}/offenses?offense_name=Robbery&year=2014'.format(variable)
        res = testapp.get(url)
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r
            assert 'stolen_value' in r
            assert 'recovered_value' in r
