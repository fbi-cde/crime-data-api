import pytest
from crime_data.common.base import ExplorerOffenseMapping
from crime_data.common.cdemodels import CargoTheftCountView
from collections import namedtuple


class TestCargoTheftCountView:
    """Test the CargoTheftCountView"""

    def test_cargo_theft_count_for_a_state(self, app):
        ctv = CargoTheftCountView('prop_desc_name', year=2014, state_id=3)

        CtRecord = namedtuple('ct_record', ['count', 'stolen_value', 'recovered_value'])
        expected = {
            'Consumable Goods': CtRecord(1, '466', '0'),
            'Credit/ Debit cards': CtRecord(1, '0', '0'),
            'Money': CtRecord(1, '290', '217'),
            'Other': CtRecord(2, '60', '0'),
            'Purse/ Wallet': CtRecord(1, '20', '0'),
            'Tools': CtRecord(1, '1000', '0')
        }

        results = ctv.query({}).fetchall()
        assert len(results) > 0
        # assert len(results) == len(expected)
        # for row in results:
        #     assert row.count == expected[row.prop_desc_name].count
        #     assert row.stolen_value == expected[row.prop_desc_name].stolen_value
        #     assert row.recovered_value == expected[row.prop_desc_name].recovered_value

    def test_cargo_theft_count_for_nation(self, app):
        ctv = CargoTheftCountView('victim_type_name', year=2014)
        CtRecord = namedtuple('ct_record', ['count', 'stolen_value', 'recovered_value'])
        expected = {
            'Business': CtRecord(63, '7328091', '792831'),
            'Financial Institution': CtRecord(2, '900', '0'),
            'Government': CtRecord(4, '1400', '500'),
            'Individual': CtRecord(80, '861318', '54666'),
            'Society/Public': CtRecord(2, '2200', '0'),
            'Unknown': CtRecord(1, '4894', '0')
        }
        results = ctv.query({}).fetchall()
        assert len(results) > 0
        # assert len(results) == len(expected)
        # for row in results:
        #     assert row.count == expected[row.victim_type_name].count
        #     assert row.stolen_value == expected[row.victim_type_name].stolen_value
        #     assert row.recovered_value == expected[row.victim_type_name].recovered_value

    @pytest.mark.parametrize('variable', CargoTheftCountView.VARIABLES)
    def test_victim_count_variables(self, app, variable):
        ctcv = CargoTheftCountView(variable, year=2014, state_id=3)
        results = ctcv.query({}).fetchall()
        assert len(results) > 0

        # test that grouping is working
        # seen_values = set()
        # for row in results:
        #     assert row[variable] not in seen_values
        #     seen_values.add(row[variable])
        # print(seen_values)
