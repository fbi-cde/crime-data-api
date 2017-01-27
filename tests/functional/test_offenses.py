# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import pytest
from crime_data.common.marshmallow_schemas import OFFENSE_COUNT_VARIABLE_ENUM


class TestOffensesEndpoint:
    def test_offenses_endpoint_exists(self, testapp):
        res = testapp.get('/offenses/')
        assert res.status_code == 200

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

    @pytest.mark.parametrize('variable', OFFENSE_COUNT_VARIABLE_ENUM)
    def test_state_endpoint_count(self, testapp, variable):
        url = '/offenses/count/states/3/{}?year=2014'.format(variable)
        res = testapp.get(url)
        assert res.status_code == 200
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r

    @pytest.mark.parametrize('variable', OFFENSE_COUNT_VARIABLE_ENUM)
    def test_state_endpoint_count(self, testapp, variable):
        url = '/offenses/count/national/{}?year=2014'.format(variable)
        res = testapp.get(url)
        assert res.status_code == 200
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r

    @pytest.mark.xfail
    def test_state_endpoint_no_year_in_request(self, testapp):
        res = testapp.get('/offenses/count/states/3/location_name')
        assert res.status_code == 500