# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import pytest
from crime_data.common.cdemodels import OffenseHateCrimeCountView

class TestOffendersOffensesEndpoint:
    def test_state_endpoint_no_year_in_request(self, testapp):
        res = testapp.get('/hc/count/states/3/bias_name/offenses')
        assert 'pagination' in res.json
        assert res.status_code == 200
        for r in res.json['results']:
            assert 'count' in r

    def test_state_endpoint_no_year_in_request_with_postal_code(self, testapp):
        res = testapp.get('/hc/count/states/AR/bias_name/offenses')
        assert 'pagination' in res.json
        assert res.status_code == 200
        for r in res.json['results']:
            assert 'count' in r

    @pytest.mark.parametrize('variable', OffenseHateCrimeCountView.VARIABLES)
    def test_victims_offenses_endpoint_with_just_state_year(self, testapp, variable):
        url = '/hc/count/states/43/{}/offenses?year=2014'.format(variable)
        res = testapp.get(url)
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r

    def test_victims_offenses_endpoint_with_just_state_year_and_postal_code(self, testapp):
        url = '/hc/count/states/NY/bias_name/offenses?year=2014'
        res = testapp.get(url)
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r

    @pytest.mark.parametrize('variable', OffenseHateCrimeCountView.VARIABLES)
    def test_victims_offenses_endpoint_with_state_year_offense(self, testapp, variable):
        url = '/hc/count/states/43/{}/offenses?offense_name=Aggravated+Assault&year=2014'.format(variable)
        res = testapp.get(url)
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r
