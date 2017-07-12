import pytest
from crime_data.common.cdemodels import CdeRefState
from decimal import Decimal

class TestCdeRefState:
    """Test the CdeRefState class"""

    def test_get_by_id(self, testapp):
        s = CdeRefState.get(state_id=44).one()
        assert s.state_name == 'Rhode Island'

    def test_get_by_abbr(self, testapp):
        s = CdeRefState.get(abbr='ri').one()
        assert s.state_name == 'Rhode Island'

    def test_police_officers(self, app):
        state = CdeRefState.get(abbr='RI').one()
        assert state.police_officers == 2497

    def test_participation(self, app):
        test_year = 2014
        state = CdeRefState.get(abbr='RI').one()

        # SELECT distinct rm.agency_id, ra.pub_agency_name
        # FROM reta_month rm
        # JOIN ref_agency ra ON ra.agency_id = rm.agency_id
        # WHERE ra.state_id=44 and rm.data_year=2014
        assert state.total_agencies == 62

        assert state.participating_agencies == 54
        assert state.participation_pct == Decimal('87.10')

        # select SUM(rac.population)
        # from ref_agency_county rac
        # JOIN ref_county rc ON rac.county_id = rc.county_id
        # WHERE rc.state_id=44 and rac.data_year=2014;
        assert state.total_population == 1061770

        # select SUM(rac.population)::text
        # from ref_agency_county rac
        # WHERE rac.agency_id IN (select rm.agency_id from reta_month rm
        #                         JOIN ref_agency ra ON rm.agency_id=ra.agency_id
        #                         WHERE rm.reported_flag = 'Y'
        #                         AND rm.data_year=rac.data_year
        #                         AND rm.data_year=2014 and ra.state_id=44)
        assert state.participating_population == 1055173
