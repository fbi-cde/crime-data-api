# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import pytest
from crime_data.resources.meta import FAMILIES

class TestCodesEndpoint:
    @pytest.mark.parametrize('endpoint', FAMILIES)
    def test_meta_endpoint_exists(self, testapp, endpoint):
        res = testapp.get('/meta/{0}'.format(endpoint))
        assert res.status_code == 200

        assert 'filters' in res.json
        assert res.json['filters'] == FAMILIES[endpoint].filter_columns
