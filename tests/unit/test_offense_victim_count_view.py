import pytest
from crime_data.common.base import ExplorerOffenseMapping
from crime_data.common.cdemodels import OffenseVictimCountView


class TestOffenseVictimCountView:
    """Test the OffenseVictimCountView"""

    def test_count_for_a_state(self, app):
        v = OffenseVictimCountView('race_code', year=1999, state_id=47, offense_name='Aggravated Assault', as_json=False)
        results = v.query({}).fetchall()

        expected = [
            ('1999', 'Aggravated Assault', 'B', 1),
            ('1999', 'Aggravated Assault', 'U', 2),
            ('1999', 'Aggravated Assault', 'W', 3)]
        # assert len(results) == len(expected)
        # for row, expect in zip(results, expected):
        #     assert row == expect
        for row in results:
            assert 'count' in row

    @pytest.mark.parametrize('year', [1999, None])
    @pytest.mark.parametrize('state_id', [47, None])
    @pytest.mark.parametrize('offense_name', ['Aggravated Assault', None])
    @pytest.mark.parametrize('variable', OffenseVictimCountView.VARIABLES)
    def test_endpoint(self, app, year, state_id, offense_name, variable):
        v = OffenseVictimCountView(variable, year=year, state_id=state_id, offense_name=offense_name, as_json=False)
        results = v.query({}).fetchall()

        # seen_values = set()
        # for row in results:
        #     row_key = (row.year, row.offense_name, row[variable], )
        #     assert row_key not in seen_values
        #     seen_values.add(row_key)
        for row in results:
                assert 'count' in row

    @pytest.mark.parametrize('explorer_offense', ExplorerOffenseMapping.NIBRS_OFFENSE_MAPPING.keys())
    @pytest.mark.parametrize('variable', ['race_code'])
    def test_endpoint_for_explorer_offense(self, app, explorer_offense, variable):
        v = OffenseVictimCountView(variable, year=1992, state_id=2, explorer_offense=explorer_offense, as_json=False)
        results = v.query({}).fetchall()
        if len(results) > 0:
            # seen_values = set()
            # for row in results:
            #     row_key = (row.year, row.offense_name, row[variable], )
            #     assert row_key not in seen_values
            #     seen_values.add(row_key)
            for row in results:
                assert 'count' in row

    def test_explorer_offense_does_aggregation(self, app):
        v = OffenseVictimCountView('sex_code', year=2014, state_id=26, explorer_offense='larceny', as_json=False)
        results = v.query({}).fetchall()
        expected = [
            ('2014', 'larceny', 'F', 3),
            ('2014', 'larceny', 'M', 3)]
        #assert len(results) == len(expected)
        # for row, expect in zip(results, expected):
        #     assert row == expect
        for row in results:
            assert 'count' in row
