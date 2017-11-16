# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import pytest

class TestLookupEndpoint:
    def test_lookup_state_endpoint_exists(self, testapp):
        res = testapp.get('/lookup/state')
        assert res.status_code == 200

    def test_lookup_region_endpoint_exists(self, testapp):
        res = testapp.get('/lookup/region')
        assert res.status_code == 200
