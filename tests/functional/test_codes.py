# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
from crime_data.resources.codes import CodeReferenceList

class TestCodesEndpoint:
    def test_codes_endpoints_exists(self, user, testapp):
        for code in CodeReferenceList.models:
            res = testapp.get('/codes/{0}'.format(code))
            assert res.status_code == 200
