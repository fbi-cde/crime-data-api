# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
from flex.core import validate_api_call

class TestParticipationEndpoint:
    def test_national_participation_endpoint(self, testapp, swagger):
        res = testapp.get('/participation/national')
        assert res.status_code == 200
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
