# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import pytest


class TestOffensesEndpoint:
    def test_offenses_endpoint_exists(self, user, testapp):
        res = testapp.get('/offenses/')
        assert res.status_code == 200

    def test_offenses_endpoint_includes_metadata(self, user, testapp):
        res = testapp.get('/offenses/')
        assert 'pagination' in res.json

    def test_offenses_endpoint_returns_crime_types(self, user, testapp):
        res = testapp.get('/offenses/')
        assert len(res.json['results']) > 0
        assert 'crime_type_name' in res.json['results'][0]

    def test_offenses_endpoint_includes_categories(self, user, testapp):
        res = testapp.get('/offenses/')
        for crime_type in res.json['results']:
            assert 'categories' in crime_type
            for category in crime_type['categories']:
                assert 'offense_category_name' in category
