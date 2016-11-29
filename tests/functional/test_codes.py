# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import pytest
from crime_data.resources.codes import CodeReferenceList

class TestCodesEndpoint:
    @pytest.mark.parametrize("table", CodeReferenceList.models)
    def test_codes_endpoint_exists(self, user, testapp, table):
        res = testapp.get('/codes/{0}'.format(table))
        assert res.status_code == 200
