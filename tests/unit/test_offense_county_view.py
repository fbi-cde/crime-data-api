import pytest
from crime_data.common.base import ExplorerOffenseMapping
from crime_data.common.cdemodels import OffenseCountView


class TestOffenseCountView:
    """Test the OffenseCountView"""

    def test_offense_count_for_a_state(self, app):
        ocv = OffenseCountView('weapon_name', year=2014, state_id=3, as_json=False)
        results = ocv.query({}).fetchall()

        expected = {'Handgun': 2, 'Firearm': 1, 'Rifle': 1, 'Personal Weapons': 3, 'None': 3, 'Motor Vehicle': 1}
        assert len(results) > 0
        # assert len(results) == len(expected)
        # for row in results:
        #     assert row.count == expected[row.weapon_name]

    def test_offense_count_for_a_state_abbr(self, app):
        ocv = OffenseCountView('weapon_name', year=2014, state_abbr='AR', as_json=False)
        results = ocv.query({}).fetchall()

        expected = {'Handgun': 2, 'Firearm': 1, 'Rifle': 1, 'Personal Weapons': 3, 'None': 3, 'Motor Vehicle': 1}
        assert len(results) > 0
        # assert len(results) == len(expected)
        # for row in results:
        #     assert row.count == expected[row.weapon_name]

    def test_offense_count_view_with_bad_variable(self, app):
        with pytest.raises(ValueError):
            OffenseCountView('foo')

    @pytest.mark.parametrize('variable', OffenseCountView.VARIABLES)
    def test_offense_count_variables(self, app, variable):
        ocv = OffenseCountView(variable, year=2014, state_id=3, as_json=False)
        results = ocv.query({}).fetchall()
        assert len(results) > 0

        # test that grouping is working
        seen_values = set()
        for row in results:
            assert row[variable] not in seen_values
            seen_values.add(row[variable])

    @pytest.mark.parametrize('variable', OffenseCountView.VARIABLES)
    def test_offender_count_variables(self, app, variable):
        ocv = OffenseCountView(variable, year=2014, as_json=False)
        results = ocv.query({}).fetchall()
        assert len(results) > 0

        # test that grouping is working
        seen_values = set()
        for row in results:
            assert row[variable] not in seen_values
            seen_values.add(row[variable])
