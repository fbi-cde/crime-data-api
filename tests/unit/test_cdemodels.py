# -*- coding: utf-8 -*-

from crime_data.common.base import ExplorerOffenseMapping
from crime_data.common.cdemodels import (CdeRefState,
                                         CdeRefCounty,
                                         CdeRefAgencyCounty,
                                         OffenseCountView,
                                         OffenderCountView,
                                         VictimCountView,
                                         CargoTheftCountView,
                                         HateCrimeCountView,
                                         OffenseByOffenseTypeCountView,
                                         OffenseVictimCountView,
                                         OffenseOffenderCountView,
                                         OffenseCargoTheftCountView,
                                         OffenseHateCrimeCountView)
import pytest
from collections import namedtuple

class TestCdeRefCounty:
    def test_get_by_id(self, testapp):
        s = CdeRefCounty.get(county_id=753).one()
        assert s.county_name == 'Kendall'

    def test_get_by_fips(self, testapp):
        s = CdeRefCounty.get(fips='06075').one()
        assert s.county_name == 'San Francisco'

    def test_get_by_name(self, testapp):
        s = CdeRefCounty.get(name='San FrANCIsco').one()
        assert s.county_name == 'San Francisco'

    def test_num_agencies(self, app):
        """Using the test data in the ref_agencies table"""

        county = CdeRefCounty.get(county_id=2402).one()
        assert county.total_agencies == 5

    def test_population(self, app):
        """Using the test data in the ref_county_population table"""

        county = CdeRefCounty.get(county_id=2402).one()
        assert county.total_population == 49251

    def test_unspecified_county(self, app):
        """Special 'unspecified counties' should not have a FIPS"""

        county = CdeRefCounty.get(county_id=3311).one()
        assert county.fips is None

    # Not sure we need this
    # def test_police_officers(self, app):
    #     """Using the test data in the database"""

    #     county = CdeRefCounty.get(county_id=2402).one()
    #     assert county.police_officers_for_year(2014) == 84

    # def test_police_officers_missing_data(self, app):

    #     county = CdeRefCounty.get(county_id=3015).one()
    #     assert county.police_officers_for_year(2021) is None
    #     assert county.police_officers is None


class TestCdeRefAgencyCounty:
    def test_current_year(self, testapp):
        assert CdeRefAgencyCounty.current_year() == 2016


class TestCdeRefState:
    """Test the CdeRefState class"""

    def test_get_by_id(self, testapp):
        s = CdeRefState.get(state_id=12).one()
        assert s.state_name == 'Florida'

    def test_get_by_abbr(self, testapp):
        s = CdeRefState.get(abbr='NE').one()
        assert s.state_name == 'Nebraska'

    def test_get_by_fips(self, testapp):
        s = CdeRefState.get(fips='06075').one()
        assert s.state_name == 'California'

    def test_police_officers(self, app):
        state = CdeRefState.get(abbr='RI').one()
        assert state.police_officers_for_year(2014) == 2497

    def test_participation(self, app):
        test_year = 2014
        state = CdeRefState.get(abbr='RI').one()

        # SELECT distinct rm.agency_id, ra.pub_agency_name
        # FROM reta_month rm
        # JOIN ref_agency ra ON ra.agency_id = rm.agency_id
        # WHERE ra.state_id=44 and rm.data_year=2014
        assert state.total_agencies_for_year(test_year) == 62

        assert state.participating_agencies_for_year(test_year) == 54
        assert state.participation_rate_for_year(test_year) == pytest.approx(0.870967742)

        # select SUM(rac.population)
        # from ref_agency_county rac
        # JOIN ref_county rc ON rac.county_id = rc.county_id
        # WHERE rc.state_id=44 and rac.data_year=2014;
        assert state.total_population_for_year(test_year) == 1061770

        # select SUM(rac.population)::text
        # from ref_agency_county rac
        # WHERE rac.agency_id IN (select rm.agency_id from reta_month rm
        #                         JOIN ref_agency ra ON rm.agency_id=ra.agency_id
        #                         WHERE rm.reported_flag = 'Y'
        #                         AND rm.data_year=rac.data_year
        #                         AND rm.data_year=2014 and ra.state_id=44)
        assert state.participating_population_for_year(test_year) == 1055173

    def test_participation_cache_is_not_global(self, app):
        test_year = 1960
        state1 = CdeRefState.get(abbr='NY').one()
        state2 = CdeRefState.get(abbr='DE').one()
        assert state1 != state2
        assert state1.state_id != state2.state_id
        p1 = state1.total_population_for_year(test_year)
        p2 = state2.total_population_for_year(test_year)
        assert p1 != p2


class TestOffenseCountView:
    """Test the OffenseCountView"""

    def test_offense_count_for_a_state(self, app):
        ocv = OffenseCountView('weapon_name', year=2014, state_id=3)
        results = ocv.query({}).fetchall()

        expected = {'Handgun': 2, 'Firearm': 1, 'Rifle': 1, 'Personal Weapons': 3, 'None': 3, 'Motor Vehicle': 1}
        assert len(results) > 0
        # assert len(results) == len(expected)
        # for row in results:
        #     assert row.count == expected[row.weapon_name]

    def test_offense_count_for_a_state_abbr(self, app):
        ocv = OffenseCountView('weapon_name', year=2014, state_abbr='AR')
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
        ocv = OffenseCountView(variable, year=2014, state_id=3)
        results = ocv.query({}).fetchall()
        assert len(results) > 0

        # test that grouping is working
        seen_values = set()
        for row in results:
            assert row[variable] not in seen_values
            seen_values.add(row[variable])

    @pytest.mark.parametrize('variable', OffenseCountView.VARIABLES)
    def test_offender_count_variables(self, app, variable):
        ocv = OffenseCountView(variable, year=2014)
        results = ocv.query({}).fetchall()
        assert len(results) > 0

        # test that grouping is working
        seen_values = set()
        for row in results:
            assert row[variable] not in seen_values
            seen_values.add(row[variable])


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


class TestVictimCountView:
    """Test the VictimCountView"""

    def test_victim_count_for_a_state(self, app):
        vcv = VictimCountView('offense_name', year=2014, state_id=3)

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
        vcv = VictimCountView(variable, year=2014, state_id=3)
        results = vcv.query({}).fetchall()

        # test that grouping is working
        seen_values = set()
        for row in results:
            assert row[variable] not in seen_values
            seen_values.add(row[variable])
        print(seen_values)

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


class TestHateCrimeCountView:
    """Test the HateCrimeCountView"""

    def test_hate_crime_count_view(self, app):
        hcv = HateCrimeCountView('bias_name', year=2014, state_id=6)
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
        hcv = HateCrimeCountView('bias_name', year=2014)
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


class TestOffenseVictimCountView:
    """Test the OffenseVictimCountView"""

    def test_count_for_a_state(self, app):
        v = OffenseVictimCountView('race_code', year=1999, state_id=47, offense_name='Aggravated Assault')
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
        v = OffenseVictimCountView(variable, year=year, state_id=state_id, offense_name=offense_name)
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
        v = OffenseVictimCountView(variable, year=1992, state_id=2, explorer_offense=explorer_offense)
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
        v = OffenseVictimCountView('sex_code', year=2014, state_id=26, explorer_offense='larceny')
        results = v.query({}).fetchall()
        expected = [
            ('2014', 'larceny', 'F', 3),
            ('2014', 'larceny', 'M', 3)]
        #assert len(results) == len(expected)
        # for row, expect in zip(results, expected):
        #     assert row == expect
        for row in results:
            assert 'count' in row


class TestOffenseOffenderCountView:
    """Test the OffenseOffenderCountView"""

    def test_count_for_a_state(self, app):
        v = OffenseOffenderCountView('race_code', year=2013, state_id=47, offense_name='Aggravated Assault')
        results = v.query({}).fetchall()
        expected = [
            ('2013', 'Aggravated Assault', 'W', 4)
        ]
        # assert len(results) == len(expected)
        # for row, expect in zip(results, expected):
        #     assert row == expect
        for row in results:
            assert 'count' in row

    @pytest.mark.parametrize('year', [2014, None])
    @pytest.mark.parametrize('state_id', [41, None])
    @pytest.mark.parametrize('offense_name', ['Shoplifting', None])
    @pytest.mark.parametrize('variable', OffenseOffenderCountView.VARIABLES)
    def test_endpoint(self, app, year, state_id, offense_name, variable):
        v = OffenseOffenderCountView(variable, year=year, state_id=state_id, offense_name=offense_name)
        results = v.query({}).fetchall()
        assert len(results) > 0

        seen_values = set()
        # for row in results:
        #     row_key = (row.year, row.offense_name, row[variable], )
        #     assert row_key not in seen_values
        #     seen_values.add(row_key)
        for row in results:
            assert 'count' in row

    @pytest.mark.parametrize('explorer_offense', ExplorerOffenseMapping.NIBRS_OFFENSE_MAPPING.keys())
    @pytest.mark.parametrize('variable', OffenseOffenderCountView.VARIABLES)
    def test_endpoint_for_explorer_offense(self, app, explorer_offense, variable):
        v = OffenseOffenderCountView(variable, year=1992, state_id=2, explorer_offense=explorer_offense)
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
        v = OffenseOffenderCountView('sex_code', year=2014, state_id=26, explorer_offense='larceny')
        results = v.query({}).fetchall()
        expected = [
            ('2014', 'larceny', 'F', 1),
            ('2014', 'larceny', 'M', 2)]
        #assert len(results) == len(expected)
        # for row, expect in zip(results, expected):
        #     assert row == expect
        for row in results:
            assert 'count' in row


class TestOffenseByOffenseTypeCountView:
    """Test the OffenseByOffenseTypeCountView"""

    def test_count_for_a_state(self, app):
        v = OffenseByOffenseTypeCountView('weapon_name', year=1999, state_id=47, offense_name='Aggravated Assault')
        results = v.query({}).fetchall()

        expected = [
            ('1999', 'Aggravated Assault', 'Blunt Object', 1),
            ('1999', 'Aggravated Assault', 'Motor Vehicle', 1),
            ('1999', 'Aggravated Assault', 'Other', 2),
            ('1999', 'Aggravated Assault', 'Personal Weapons', 1),
            ('1999', 'Aggravated Assault', 'Unknown', 1)]

        # assert len(results) == len(expected)
        # for row, expect in zip(results, expected):
        #     assert row == expect
        for row in results:
            assert 'count' in row

    @pytest.mark.parametrize('year', [1999, None])
    @pytest.mark.parametrize('state_id', [47, None])
    @pytest.mark.parametrize('offense_name', ['Aggravated Assault', None])
    @pytest.mark.parametrize('variable', OffenseByOffenseTypeCountView.VARIABLES)
    def test_endpoint(self, app, year, state_id, offense_name, variable):
        v = OffenseByOffenseTypeCountView(variable, year=year, state_id=state_id, offense_name=offense_name)
        results = v.query({}).fetchall()
        seen_values = set()
        # for row in results:
        #     row_key = (row.year, row.offense_name, row[variable], )
        #     assert row_key not in seen_values
        #     seen_values.add(row_key)
        for row in results:
            assert 'count' in row

    @pytest.mark.parametrize('explorer_offense', ExplorerOffenseMapping.NIBRS_OFFENSE_MAPPING.keys())
    @pytest.mark.parametrize('variable', ['location_name'])
    def test_endpoint_for_explorer_offense(self, app, explorer_offense, variable):
        v = OffenseByOffenseTypeCountView(variable, year=1992, state_id=2, explorer_offense=explorer_offense)
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
        v = OffenseVictimCountView('sex_code', year=2014, state_id=26, explorer_offense='larceny')
        results = v.query({}).fetchall()
        expected = [
            ('2014', 'larceny', 'F', 3),
            ('2014', 'larceny', 'M', 3)]
        # assert len(results) == len(expected)
        # for row, expect in zip(results, expected):
        #     assert row == expect
        for row in results:
            assert 'count' in row


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
