import pytest
from crime_data.common.newmodels import CdeAgency

class TestCdeAgencies:
    def test_basic_ref_agency_fields(self, app):
        a = CdeAgency.query.filter(CdeAgency.agency_id == 22330).one()
        assert a is not None
        assert a.ori == 'CA0280400'
        assert a.legacy_ori == 'CA0280400'
        assert a.agency_name == 'Yountville'
        assert a.agency_type_id == 99
        assert a.agency_type_name == 'Unknown'
        assert a.state_id == 6
        assert a.state_abbr == 'CA'
        assert a.city_id is None
        assert a.agency_status == 'A'
        assert a.submitting_agency_id == 23357
        assert a.submitting_sai == 'CAUCR0001'
        assert a.submitting_name == 'Department of Justice Criminal Justice Statistics Center'
        assert a.submitting_state_abbr == 'CA'
        assert a.dormant_year == 1983

    def test_agency_covering(self, app):
        a = CdeAgency.query.filter(CdeAgency.agency_id == 17398).one()
        assert a is not None
        assert a.current_year == 2014
        assert a.covered_by_id == 17439
        assert a.covered_by_ori == 'RIRSP0500'
        assert a.covered_by_name == 'State Police: Lincoln'
        assert a.months_reported == 0
        assert a.nibrs_months_reported == 0

    def test_current_year_and_population(self, app):
        a = CdeAgency.query.filter(CdeAgency.agency_id == 17385).one()
        assert a is not None
        assert a.current_year == 2014
        assert a.population == 35053
        assert a.suburban_area_flag == 'Y'
        assert a.population_group_code == '4'
        assert a.population_group_desc == 'Cities from 25,000 thru 49,999'
        assert a.months_reported == 12
        assert a.nibrs_months_reported == 12

    def test_city_association(self, app):
        a = CdeAgency.query.filter(CdeAgency.agency_id == 12223).one()
        assert a is not None
        assert a.city_id == 6690
        assert a.city_name == 'Barrington'
        assert a.state_id == 35
        assert a.state_abbr == 'NJ'

    def test_staffing_association(self, app):
        a = CdeAgency.query.filter(CdeAgency.agency_id == 2820).one()
        assert a is not None
        assert a.staffing_year == 1990
        assert a.total_officers == 116
        assert a.total_civilians == 169

    def test_core_city_flag(self, app):
        a = CdeAgency.query.filter(CdeAgency.agency_id == 17407).one()
        assert a is not None
        assert a.core_city_flag == 'Y'

    def test_primary_county(self, app):
        a = CdeAgency.query.filter(CdeAgency.agency_id == 17382).one()
        assert a.primary_county_id == 2402
        assert a.primary_county == 'Bristol'
        assert a.primary_county_fips == '44001'

    def test_county_name_append(self, app):
        a = CdeAgency.query.filter(CdeAgency.ori == 'CA0190000').one()
        assert a.agency_name == 'Los Angeles County'

    def test_county_not_appended_to_other_agency_type(self, app):
        a = CdeAgency.query.filter(CdeAgency.ori == 'CA0194200').one()
        assert a.agency_name == 'Los Angeles'

    def test_revised_rape_start_not_set(self, app):
        a = CdeAgency.query.filter(CdeAgency.agency_id == 17382).one()
        assert a is not None
        assert a.revised_rape_start == 2013

    def test_revised_rape_start_not_set(self, app):
        a = CdeAgency.query.filter(CdeAgency.agency_id == 17427).one()
        assert a is not None
        assert a.revised_rape_start is None

    def test_agency_has_unmapped_county(self, app):
        a = CdeAgency.query.filter(CdeAgency.ori == 'RIRSP0000').one()
        assert a is not None
        assert a.primary_county_id is not None
        assert a.primary_county is None
        assert a.primary_county_fips is None
