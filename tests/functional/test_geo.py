# # -*- coding: utf-8 -*-
# """Functional tests using WebTest.

# See: http://webtest.readthedocs.org/
# """
import pytest
from flex.core import validate_api_call

class TestGeoEndpoint:
    def test_state_detail_endpoint(self, testapp, swagger):
         url = '/geo/states/RI'
         res = testapp.get(url)
         assert res.status_code == 200
         validate_api_call(swagger, raw_request=res.request, raw_response=res)

    def test_county_detail_endpoint(self, testapp, swagger):
         res = testapp.get('/geo/counties/44003')
         assert res.status_code == 200
