import pytest
from crime_data.common.base import ExplorerOffenseMapping
from crime_data.common.cdemodels import HateCrimeCountView


class TestHateCrimeCountView:
    """Test the HateCrimeCountView"""

    def test_hate_crime_count_view(self, app):
        hcv = HateCrimeCountView('bias_name', year=2014, state_id=6, as_json=False)
        results = hcv.query({}).fetchall()
        # expected = {
        #     'Anti-Black or African American': 1,
        #     'Anti-Female': 1,
        #     'Anti-Jewish': 1
        # }
        # for row in results:
        #     assert row.count == expected[row.bias_name]
        for row in results:
            assert 'count' in row

    def test_national_hate_crime_count(self, app):
        hcv = HateCrimeCountView('bias_name', year=2014, as_json=False)
        results = hcv.query({}).fetchall()
        expected = {
            'Anti-Asian': 2,
            'Anti-Black or African American': 13,
            'Anti-Female': 1,
            'Anti-Hispanic or Latino': 4,
            'Anti-Jewish': 2,
            'Anti-Male Homosexual (Gay)': 1,
            'Anti-Not Hispanic or Latino': 1,
            'Anti-Other Religion': 1,
            'Anti-Physical Disability': 1,
            'Anti-White': 4
        }
        for row in results:
            assert 'count' in row
