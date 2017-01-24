# -*- coding: utf-8 -*-

from crime_data.common.models import RefCounty
from crime_data.common.cdemodels import (CdeRefState,
                                         CdeRefCounty,
                                         CdeRefAgencyCounty,
                                         OffenderCountView,
                                         VictimCountView,
                                         CargoTheftCountView,
                                         HateCrimeCountView)
from crime_data.common.marshmallow_schemas import (OFFENDER_COUNT_VARIABLE_ENUM,
                                                   VICTIM_COUNT_VARIABLE_ENUM,
                                                   CARGO_THEFT_COUNT_VARIABLE_ENUM)
import pytest
from collections import namedtuple

class TestCdeRefState:
    def test_get_by_id(self, testapp):
        s = CdeRefState.get(state_id=12).one()
        assert s.state_name == 'Florida'

    def test_get_by_abbr(self, testapp):
        s = CdeRefState.get(abbr='NE').one()
        assert s.state_name == 'Nebraska'

    def test_get_by_fips(self, testapp):
        s = CdeRefState.get(fips='06075').one()
        assert s.state_name == 'California'


class TestCdeRefCounty:
    def test_get_by_id(self, testapp):
        s = CdeRefCounty.get(county_id=753).one()
        assert s.county_name == 'KENDALL'

    def test_get_by_fips(self, testapp):
        s = CdeRefCounty.get(fips='06075').one()
        assert s.county_name == 'SAN FRANCISCO'

        with pytest.raises(ValueError):
            CdeRefCounty.get(fips='6075')

        with pytest.raises(ValueError):
            CdeRefCounty.get(fips=6075)

    def test_get_by_name(self, testapp):
        s = CdeRefCounty.get(name='San Francisco').one()
        assert s.county_name == 'SAN FRANCISCO'

    def test_fips_property(self, testapp):
        state = CdeRefState(state_fips_code='02')
        county = CdeRefCounty(county_fips_code='343', state=state)
        assert county.fips == '02343'

        county = CdeRefCounty(county_fips_code='7', state=state)
        assert county.fips == '02007'

    def test_num_agencies(self, app):
        """Using the test data in the ref_agencies table"""

        county = CdeRefCounty.get(county_id=2271).one()
        assert county.num_agencies_for_year(2014) == 8

    def test_num_agencies_missing_data(self, app):
        """This county is missing current agencies data"""

        county = CdeRefCounty.get(county_id=2271).one()
        assert county.num_agencies is None

    def test_population(self, app):
        """Using the test data in the ref_county_population table"""

        county = CdeRefCounty.get(county_id=74).one()
        assert county.population_for_year(1960) == 24501

    def test_population_missing_data(self, app):
        """This county is missing current population data"""

        county = CdeRefCounty.get(county_id=74).one()
        assert county.population is None

    def test_police_officers(self, app):
        """Using the test data in the database"""

        county = CdeRefCounty.get(county_id=3015).one()
        assert county.police_officers_for_year(1977) == 19

    def test_police_officers_missing_data(self, app):

        county = CdeRefCounty.get(county_id=3015).one()
        assert county.police_officers_for_year(2021) is None
        assert county.police_officers is None


class TestCdeRefAgencyCounty:
    def test_current_year(self, testapp):
        assert CdeRefAgencyCounty.current_year() == 2016


class TestCdeRefState:
    """Test the CdeRefState class"""

    def test_population(self, app):
        state = CdeRefState.get(abbr='WY').one()
        assert state.population_for_year(1984) == 511000

    def test_num_agencies(self, app):
        state = CdeRefState.get(abbr='VA').one()
        assert state.num_agencies == 145

    def test_police_officers(self, app):
        state = CdeRefState.get(abbr='VA').one()
        assert state.police_officers_for_year(2008) == 48


class TestOffenderCountView:
    """Test the OffenderCountView"""

    def test_offender_count_for_a_state(self, app):
        ocv = OffenderCountView('race_code', year=2014, state_id=3)
        results = ocv.query({}).fetchall()

        expected = {'B': 14, 'U': 5, 'W': 4}

        assert len(results) == len(expected)
        for row in results:
            assert row.count == expected[row.race_code]

    def test_offender_count_view_with_offenses(self, app):
        pass

    @pytest.mark.parametrize('variable', OFFENDER_COUNT_VARIABLE_ENUM)
    def test_offender_count_variables(self, app, variable):
        ocv = OffenderCountView(variable, year=2014, state_id=3)
        results = ocv.query({}).fetchall()
        assert len(results) > 0

        # test that grouping is working
        seen_values = set()
        for row in results:
            assert row[variable] not in seen_values
            seen_values.add(row[variable])

    @pytest.mark.parametrize('variable', OFFENDER_COUNT_VARIABLE_ENUM)
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
        assert len(results) == len(expected)
        for row in results:
            assert row.count == expected[row.offense_name]

    def test_victim_count_with_offenses(self, app):
        pass

    @pytest.mark.parametrize('variable', VICTIM_COUNT_VARIABLE_ENUM)
    def test_victim_count_variables(self, app, variable):
        vcv = VictimCountView(variable, year=2014, state_id=3)
        results = vcv.query({}).fetchall()
        assert len(results) > 0

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
        assert len(results) == len(expected)
        for row in results:
            assert row.count == expected[row.prop_desc_name].count
            assert row.stolen_value == expected[row.prop_desc_name].stolen_value
            assert row.recovered_value == expected[row.prop_desc_name].recovered_value

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
        assert len(results) == len(expected)
        for row in results:
            assert row.count == expected[row.victim_type_name].count
            assert row.stolen_value == expected[row.victim_type_name].stolen_value
            assert row.recovered_value == expected[row.victim_type_name].recovered_value

    @pytest.mark.parametrize('variable', CARGO_THEFT_COUNT_VARIABLE_ENUM)
    def test_victim_count_variables(self, app, variable):
        ctcv = CargoTheftCountView(variable, year=2014, state_id=3)
        results = ctcv.query({}).fetchall()
        assert len(results) > 0

        # test that grouping is working
        seen_values = set()
        for row in results:
            assert row[variable] not in seen_values
            seen_values.add(row[variable])
        print(seen_values)


class TestHateCrimeCountView:
    """Test the HateCrimeCountView"""

    def test_hate_crime_count_view(self, app):
        hcv = HateCrimeCountView('bias_name', year=2014, state_id=6)
        results = hcv.query({}).fetchall()
        expected = {
            'Anti-Black or African American': 1,
            'Anti-Female': 1,
            'Anti-Jewish': 1
        }
        for row in results:
            assert row.count == expected[row.bias_name]

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
            assert row.count == expected[row.bias_name]
