import pytest
from crime_data.common.base import ExplorerOffenseMapping
from crime_data.common.cdemodels import OffenseHateCrimeCountView

class TestOffenseHateCrimeCountView:
    """Test the OffenseOffenderCountView"""

    def test_count_for_a_state(self, app):
        v = OffenseHateCrimeCountView('bias_name', year=1999, state_id=47, offense_name='Aggravated Assault')
        results = v.query({}).fetchall()

        expected = [
            ('1999', 'Aggravated Assault', 'Anti-Black or African American', 1),
            ('1999', 'Aggravated Assault', 'Anti-White', 1)]
        assert len(results) > 0
        # assert len(results) == len(expected)
        # for row, expect in zip(results, expected):
        #     assert row == expect

    @pytest.mark.parametrize('year', [1999, None])
    @pytest.mark.parametrize('state_id', [47, None])
    @pytest.mark.parametrize('offense_name', ['Aggravated Assault', None])
    @pytest.mark.parametrize('variable', OffenseHateCrimeCountView.VARIABLES)
    def test_endpoint(self, app, year, state_id, offense_name, variable):
        v = OffenseHateCrimeCountView(variable, year=year, state_id=state_id, offense_name=offense_name)
        results = v.query({}).fetchall()
        seen_values = set()
        # for row in results:
        #     row_key = (row.year, row.offense_name, row[variable], )
        #     assert row_key not in seen_values
        #     seen_values.add(row_key)
        for row in results:
            assert 'count' in row

    @pytest.mark.parametrize('explorer_offense', ExplorerOffenseMapping.NIBRS_OFFENSE_MAPPING.keys())
    @pytest.mark.parametrize('variable', OffenseHateCrimeCountView.VARIABLES)
    def test_endpoint_for_explorer_offense(self, app, explorer_offense, variable):
        v = OffenseHateCrimeCountView(variable, year=1992, state_id=2, explorer_offense=explorer_offense)
        results = v.query({}).fetchall()
        #assert len(results) > 0
        if len(results) > 0:
            # seen_values = set()
            # for row in results:
            #     row_key = (row.year, row.offense_name, row[variable], )
            #     assert row_key not in seen_values
            #     seen_values.add(row_key)
            for row in results:
                assert 'count' in row
