# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import pytest
from flex.core import validate_api_call

class TestArsonCounts:
    def test_national_counts(self, testapp, swagger):
        res = testapp.get('/arson/national')
        assert res.status_code == 200
        assert res.headers['Cache-Control'] is not None
        assert res.headers['Surrogate-Control'] is not None
        validate_api_call(swagger, raw_request=res.request, raw_response=res)

    def test_state_counts(self, testapp, swagger):
        res = testapp.get('/arson/states/ri')
        assert res.status_code == 200
        assert res.headers['Cache-Control'] is not None
        assert res.headers['Surrogate-Control'] is not None
        validate_api_call(swagger, raw_request=res.request,y raw_response=res)
