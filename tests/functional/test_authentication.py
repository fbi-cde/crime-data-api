# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""

import json
import crime_data.common.credentials as c

class TestAuthentication:
    """For testing authentication"""

    def test_header_login(self, monkeypatch, testapp):
        TEST_VCAP = {
            'user-provided': [
                {
                    'credentials': {
                        'API_KEY': 'key'
                    }
                }
            ]
        }
        monkeypatch.setenv('VCAP_SERVICES', json.dumps(TEST_VCAP))
        monkeypatch.setenv('VCAP_APPLICATION', "foo")
        c.service_credentials.cache_clear()

        res = testapp.get('/geo/states/WY', headers={'X-API-KEY': 'key'})
        assert res.status_code == 200

    def test_query_login(self, monkeypatch, testapp):
        TEST_VCAP = {
            'user-provided': [
                {
                    'credentials': {
                        'API_KEY': 'key'
                    }
                }
            ]
        }
        monkeypatch.setenv('VCAP_SERVICES', json.dumps(TEST_VCAP))
        monkeypatch.setenv('VCAP_APPLICATION', "foo")
        c.service_credentials.cache_clear()

        res = testapp.get('/geo/states/WY?api_key=key')
        assert res.status_code == 200

    def test_missing_login(self, monkeypatch, testapp):
        TEST_VCAP = {
            'user-provided': [
                {
                    'credentials': {
                        'API_KEY': 'key'
                    }
                }
            ]
        }
        monkeypatch.setenv('VCAP_SERVICES', json.dumps(TEST_VCAP))
        monkeypatch.setenv('VCAP_APPLICATION', "foo")
        c.service_credentials.cache_clear()

        res = testapp.get('/geo/states/WY', expect_errors=True)
        assert res.status_code == 401

    def test_optional_login(self, testapp):
        res = testapp.get('/geo/states/WY')
        assert res.status_code == 200
