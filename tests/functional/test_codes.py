# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import pytest
from crime_data.resources.codes import CODE_MODELS


class TestCodesIndex:
    def test_codes_index_exists(self, testapp):
        res = testapp.get('/codes')
        assert res.status_code == 200


class TestCodesEndpoint:
    @pytest.mark.parametrize("table", CODE_MODELS)
    def test_codes_endpoint_exists(self, testapp, table):
        res = testapp.get('/codes/{0}'.format(table))
        assert res.status_code == 200

    @pytest.mark.parametrize("table", CODE_MODELS)
    def test_codes_endpoint_csv(self, testapp, table):
        res = testapp.get('/codes/{0}.csv'.format(table))
        assert res.status_code == 200
