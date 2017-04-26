# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""

import pytest
from flex.core import validate_api_call


class TestEstimatesEndpoint:
    @pytest.mark.xfail
    def test_national_estimates(self, testapp, swagger):
        res = testapp.get('/estimates/national?per_page=100')
        assert res.status_code == 200
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
    @pytest.mark.xfail
    def test_state_estimates(self, testapp, swagger):
        res = testapp.get('/estimates/states/NE?per_page=100')
        assert res.status_code == 200
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
