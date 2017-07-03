# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import pytest
from flex.core import validate_api_call

class TestArsonCounts:
    def test_national_counts(self, testapp, swagger_beta):
        res = testapp.get('/arson/national')
        assert res.status_code == 200
        validate_api_call(swagger_beta, raw_request=res.request, raw_response=res)

    def test_state_counts(self, testapp, swagger_beta):
        res = testapp.get('/arson/states/ri')
        assert res.status_code == 200
        validate_api_call(swagger_beta, raw_request=res.request, raw_response=res)
