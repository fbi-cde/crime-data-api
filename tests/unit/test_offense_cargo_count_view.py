import pytest
from crime_data.common.base import ExplorerOffenseMapping
from crime_data.common.cdemodels import OffenseCargoTheftCountView


class TestOffenseCargoTheftCountView:
    """Test the OffenseCargoTheftCountView"""

    def test_count_for_a_state(self, app):
        v = OffenseCargoTheftCountView('prop_desc_name', year=2013, state_id=47, offense_name='Robbery')
        results = v.query({}).fetchall()
        expected = [
            ('2013', 'Robbery', 'Consumable Goods', 1, '3220', '0'),
            ('2013', 'Robbery', 'Negotiable Instruments', 1, '560', '0')
        ]
        assert len(results) > 0
        # assert len(results) == len(expected)
        # for row, expect in zip(results, expected):
        #     assert row == expect

    @pytest.mark.parametrize('year', [2013, None])
    @pytest.mark.parametrize('state_id', [47, None])
    @pytest.mark.parametrize('offense_name', ['Robbery', None])
    @pytest.mark.parametrize('variable', OffenseCargoTheftCountView.VARIABLES)
    def test_endpoint(self, app, year, state_id, offense_name, variable):
        v = OffenseCargoTheftCountView(variable, year=year, state_id=state_id, offense_name=offense_name)
        results = v.query({}).fetchall()
        seen_values = set()
        # for row in results:
        #     row_key = (row.year, row.offense_name, row[variable], )
        #     assert row_key not in seen_values
        #     seen_values.add(row_key)
        for row in results:
            assert 'count' in row

    @pytest.mark.parametrize('explorer_offense', ExplorerOffenseMapping.NIBRS_OFFENSE_MAPPING.keys())
    @pytest.mark.parametrize('variable', OffenseCargoTheftCountView.VARIABLES)
    def test_endpoint_for_explorer_offense(self, app, explorer_offense, variable):
        v = OffenseCargoTheftCountView(variable, year=1992, state_id=2, explorer_offense=explorer_offense)
        results = v.query({}).fetchall()
        if len(results) > 0:
            seen_values = set()
            # for row in results:
            #     row_key = (row.year, row.offense_name, row[variable], )
            #     assert row_key not in seen_values
            #     seen_values.add(row_key)
            for row in results:
                assert 'count' in row

    def test_explorer_offense_does_aggregation(self, app):
        v = OffenseCargoTheftCountView('prop_desc_name', year=2014, state_id=26, explorer_offense='larceny')
        results = v.query({}).fetchall()
        expected = [
            ('2014', 'larceny', 'Bicycles', 1, '85', '0'),
            ('2014', 'larceny', 'Computer Hard/ Software', 3, '2800', '0'),
            ('2014', 'larceny', 'Consumable Goods', 2, '71', '0'),
            ('2014', 'larceny', 'Jewelry/ Precious Metals', 1, '12678', '7039'),
            ('2014', 'larceny', 'Merchandise', 2, '92', '0'),
            ('2014', 'larceny', 'Money', 4, '545', '5'),
            ('2014', 'larceny', 'Other', 1, '4401', '4000'),
            ('2014', 'larceny', 'Photographic/ Optical Equipment', 1, '400', '0'),
            ('2014', 'larceny', 'Portable Electronic Communications', 3, '502', '0'),
            ('2014', 'larceny', 'Tools', 1, '420', '0'),
            ('2014', 'larceny', 'Vehicle Parts', 1, '300', '0')]
        assert len(results) > 0
        # assert len(results) == len(expected)
        # for row, expect in zip(results, expected):
        #     assert row == expect
