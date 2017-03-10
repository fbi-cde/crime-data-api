# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""

class TestParticipationEndpoint:
    def test_national_participation_endpoint(self, testapp):
        res = testapp.get('/participation/national')
        assert res.status_code == 200
