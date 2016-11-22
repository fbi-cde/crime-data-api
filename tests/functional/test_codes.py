# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""

class TestCodesEndpoint:
    def test_nibrs_activity_endpoint_exists(self, user, testapp):
        res = testapp.get('/codes/nibrs_activity_type')
        assert res.status_code == 200
