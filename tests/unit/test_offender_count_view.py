import pytest
from crime_data.common.cdemodels import OffenderCountView

class TestOffenderCountView:
    """Test the OffenderCountView"""

    def test_offender_count_for_a_state(self, app):
        ocv = OffenderCountView('race_code', year=2014, state_id=3)
        results = ocv.query({}).fetchall()

        expected = {'B': 14, 'U': 5, 'W': 4}
        assert len(results) > 0
        # assert len(results) == len(expected)
        # for row in results:
        #     assert row.count == expected[row.race_code]

    def test_offender_count_for_a_state_abbr(self, app):
        ocv = OffenderCountView('race_code', year=2014, state_abbr='AR')
        results = ocv.query({}).fetchall()

        expected = {'B': 14, 'U': 5, 'W': 4}
        assert len(results) > 0
        # assert len(results) == len(expected)
        # for row in results:
        #     assert row.count == expected[row.race_code]

    def test_offender_count_view_with_bad_variable(self, app):
        with pytest.raises(ValueError):
            OffenderCountView('foo')

    @pytest.mark.parametrize('variable', OffenderCountView.VARIABLES)
    def test_offender_count_variables(self, app, variable):
        ocv = OffenderCountView(variable, year=2014, state_id=3)
        results = ocv.query({}).fetchall()
        assert len(results) > 0

        # test that grouping is working
        seen_values = set()
        for row in results:
            assert row[variable] not in seen_values
            seen_values.add(row[variable])

    @pytest.mark.parametrize('variable', OffenderCountView.VARIABLES)
    def test_offender_count_variables(self, app, variable):
        ocv = OffenderCountView(variable, year=2014)
        results = ocv.query({}).fetchall()
        assert len(results) > 0

        # test that grouping is working
        seen_values = set()
        for row in results:
            assert row[variable] not in seen_values
            seen_values.add(row[variable])
