import json
from os import getenv
from functools import lru_cache


@lru_cache(maxsize=None)
def service_credentials():
    if getenv('VCAP_SERVICES'):
        service_env = json.loads(getenv('VCAP_SERVICES'))
        creds = [
            u['credentials'] for u in service_env['user-provided']
            if 'credentials' in u
        ]

        return creds[0]
    else:
        return {}


def get_credential(key):
    """A method for looking up credentials"""

    return service_credentials()[key]
