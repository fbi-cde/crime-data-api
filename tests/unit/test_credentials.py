# -*- coding: utf-8 -*-
import pytest
import json
import crime_data.common.credentials as c

class TestCredentialsUnit:
    """Tests for the credentials class"""

    def test_credentials_lookup_when_undefined(self, monkeypatch):
        monkeypatch.delenv('VCAP_SERVICES', raising=False)
        c.service_credentials.cache_clear()

        assert c.service_credentials() == {}
        with pytest.raises(KeyError):
            c.get_credential('foo')

    def test_credentials_lookup(self, monkeypatch):
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

        assert c.service_credentials() == {'API_KEY': 'key'}
        assert c.get_credential('API_KEY') == 'key'
        with pytest.raises(KeyError):
            c.get_credential('blah')
