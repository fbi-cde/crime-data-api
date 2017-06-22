import pytest
from crime_data.common.cdemodels import VictimCountView


class TestVictimCountView:
    """Test the VictimCountView"""

    def test_victim_count_for_a_state(self, app):
        vcv = VictimCountView('offense_name', year=2014, state_id=3, as_json=False)

        expected = {
            'Aggravated Assault': 12,
            'All Other Larceny': 5,
            'Burglary/Breaking & Entering': 2,
            'Counterfeiting/Forgery': 1,
            'Murder and Nonnegligent Manslaughter': 1,
            'Robbery': 1,
            'Shoplifting': 1,
            'Simple Assault': 5,
            'Theft From Motor Vehicle': 1
        }

        results = vcv.query({}).fetchall()
        assert len(results) > 0
        # assert len(results) == len(expected)
        # for row in results:
        #     assert row.count == expected[row.offense_name]

    def test_victim_count_with_offenses(self, app):
        pass

    @pytest.mark.parametrize('variable', VictimCountView.VARIABLES)
    def test_victim_count_variables(self, app, variable):
        vcv = VictimCountView(variable, year=2014, state_id=3, as_json=False)
        results = vcv.query({}).fetchall()

        # test that grouping is working
        seen_values = set()
        for row in results:
            assert row[variable] not in seen_values
            seen_values.add(row[variable])
        print(seen_values)
