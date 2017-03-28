# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
from flex.core import validate_api_call

class TestGeoEndpoint:
    def test_state_detail_endpoint(self, testapp, swagger):
        res = testapp.get('/geo/states/WY')
        assert res.status_code == 200
        validate_api_call(swagger, raw_request=res.request, raw_response=res)

    def test_county_detail_endpoint(self, testapp, swagger):
        res = testapp.get('/geo/counties/39043')
        assert res.status_code == 200
