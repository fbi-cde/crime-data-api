# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import pytest
from crime_data.resources.codes import CODE_MODELS


class TestCodesIndex:
    """Test the /codes URL endpoint"""

    def test_codes_index_exists(self, testapp):
        res = testapp.get('/codes')
        assert res.status_code == 200


class TestCodesEndpoint:
    """Test the /codes/* methods"""

    @pytest.mark.parametrize('table', CODE_MODELS)
    def test_codes_endpoint_exists(self, testapp, table):
        res = testapp.get('/codes/{0}'.format(table))
        assert res.status_code == 200
        assert 'results' in res.json


    @pytest.mark.parametrize('table', CODE_MODELS)
    def test_codes_endpoint_csv(self, testapp, table):
        res = testapp.get('/codes/{0}.csv'.format(table))
        assert res.status_code == 200


    @pytest.mark.parametrize('table,key', [
        ('nibrs_arrest_type', 'arrestees'),
        ('nibrs_assignment_type', 'victims'),
        ('nibrs_criminal_act_type', 'criminal_acts'),
        ('nibrs_relationship', 'relationships'),
        ('nibrs_weapon_type', 'weapons')
    ])
    def test_codes_dont_have_backwards_associations(self, testapp, table, key):
        res = testapp.get('/codes/{0}'.format(table))
        assert res.status_code == 200
        assert key not in res.json['results'][0]
