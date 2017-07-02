import pytest
from crime_data.common.base import ExplorerOffenseMapping
from crime_data.common.cdemodels import OffenseCargoTheftCountView


class TestOffenseCargoTheftCountView:
    """Test the OffenseCargoTheftCountView"""

    def test_count_for_a_state(self, app):
        v = OffenseCargoTheftCountView('prop_desc_name', year=2014, state_id=44, offense_name='Robbery', as_json=False)
        results = v.query({}).fetchall()
        assert len(results) > 0
        seen_values = set()
        for row in results:
            row_key = (row.year, row['prop_desc_name'], )
            assert row_key not in seen_values
            seen_values.add(row_key)


    @pytest.mark.parametrize('year', [2014, None])
    @pytest.mark.parametrize('state_id', [44, None])
    @pytest.mark.parametrize('offense_name', ['Robbery', None])
    @pytest.mark.parametrize('variable', OffenseCargoTheftCountView.VARIABLES)
    def test_endpoint(self, app, year, state_id, offense_name, variable):
        v = OffenseCargoTheftCountView(variable, year=year, state_id=state_id, offense_name=offense_name, as_json=False)
        results = v.query({}).fetchall()
        seen_values = set()
        for row in results:
            assert 'count' in row
#            row_key = (row.year, row[variable], )
#            assert row_key not in seen_values
#            seen_values.add(row_key)


    @pytest.mark.parametrize('explorer_offense', ExplorerOffenseMapping.NIBRS_OFFENSE_MAPPING.keys())
    @pytest.mark.parametrize('variable', OffenseCargoTheftCountView.VARIABLES)
    def test_endpoint_for_explorer_offense(self, app, explorer_offense, variable):
        v = OffenseCargoTheftCountView(variable, year=1992, state_id=2, explorer_offense=explorer_offense, as_json=False)
        results = v.query({}).fetchall()
        if len(results) > 0:
            seen_values = set()
            for row in results:
                row_key = (row.year, row[variable], )
 #               assert row_key not in seen_values
 #               seen_values.add(row_key)
 #               assert 'count' in row

    def test_explorer_offense_does_aggregation(self, app):
        v = OffenseCargoTheftCountView('prop_desc_name', year=2014, state_id=44, explorer_offense='larceny', as_json=False)
        results = v.query({}).fetchall()

        assert len(results) > 0
        seen_values = set()
        for row in results:
            row_key = (row.year, row['prop_desc_name'], )
 #           assert 'count' in row
 #           assert row_key not in seen_values
 #           seen_values.add(row_key)
