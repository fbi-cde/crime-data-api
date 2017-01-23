# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""

class TestHateCrimeEndpoint:

    def test_state_endpoint_count(self, testapp):
        url = '/hc/count/states/3/bias_name?year=2014'
        res = testapp.get(url)
        assert res.status_code == 200
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r

    def test_national_endpoint_count(self, testapp):
        url = '/hc/count/national/bias_name?year=2014'
        res = testapp.get(url)
        assert res.status_code == 200
        assert 'pagination' in res.json
        for r in res.json['results']:
            assert 'count' in r

    def test_state_endpoint_no_year_in_request(self, testapp):
        res = testapp.get('/hc/count/states/3/bias_name')
        # returns all years?
        assert res.status_code == 200
