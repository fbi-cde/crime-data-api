# -*- coding: utf-8 -*-
import pytest
import json
import crime_data.common.credentials as c
from crime_data.common.base import CdeResource

class EmptyCdeResource(CdeResource):
    pass

class TestCdeResource:
    """Tests for the CDE Resource class"""

    def test_verify_key(self, monkeypatch):
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
        c.service_credentials.cache_clear()

        cde = EmptyCdeResource()
        cde.verify_api_key({'api_key': 'key'})

    def test_verify_uuencoded_key(self, monkeypatch):
        TEST_VCAP = {
            'user-provided': [
                {
                    'credentials': {
                        'API_KEY': 'foo&bar='
                    }
                }
            ]
        }
        monkeypatch.setenv('VCAP_SERVICES', json.dumps(TEST_VCAP))
        c.service_credentials.cache_clear()

        cde = EmptyCdeResource()
        cde.verify_api_key({'api_key': 'foo%26bar%3D'})

    def test_verify_wrong_key(self, monkeypatch):
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
        c.service_credentials.cache_clear()

        cde = EmptyCdeResource()

        with pytest.raises(Exception):
            cde.verify_api_key({'api_key': 'wrong'})
