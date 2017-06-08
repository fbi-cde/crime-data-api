import pytest
from crime_data.common.cdemodels import CdeRefState

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
