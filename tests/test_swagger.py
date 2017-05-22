import pytest
import subprocess

class TestSwagger:
    def test_validate_swagger(self):
        path = pytest.config.rootdir + "/crime_data/static/swagger.json"
        cmd = "curl -X POST -d @{} -s -H 'Content-Type:application/json' http://online.swagger.io/validator/debug -f".format(path)
        output = subprocess.check_output(cmd, stderr=subprocess.STDOUT, shell=True)
        assert output.decode("ascii") == "{}"
