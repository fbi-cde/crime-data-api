# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import pytest

class TestStatusEndpoint:
    def test_status_endpoint_exists(self, testapp):
        res = testapp.get('/status')
        assert res.status_code == 200
