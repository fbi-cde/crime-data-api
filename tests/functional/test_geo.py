# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""

class TestGeoEndpoint:
    def test_state_detail_endpoint(self, testapp):
        res = testapp.get('/geo/states/WY')
        assert res.status_code == 200

    def test_county_detail_endpoint(self, testapp):
        res = testapp.get('/geo/counties/39043')
        assert res.status_code == 200
