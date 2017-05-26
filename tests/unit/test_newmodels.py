# -*- coding: utf-8 -*-

from crime_data.common.newmodels import (RetaMonthOffenseSubcatSummary,
                                         AgencyParticipation,
                                         ParticipationRate,
                                         CdeAgency)
import pytest

## Check these tests
class TestAgencyParticipation:
    def test_for_agency_not_reporting(self, app):
        q = AgencyParticipation.query
        q = q.filter(AgencyParticipation.year == 2014)
        q = q.filter(AgencyParticipation.agency_id == 17380).one()
        assert q.reported == 0
        assert q.months_reported == 0
        assert q.nibrs_reported == 0
        assert q.nibrs_months_reported == 0

    def test_for_agency_covered_by_another(self, app):
        q = AgencyParticipation.query
        q = q.filter(AgencyParticipation.year == 2014)
        q = q.filter(AgencyParticipation.agency_id == 17391).one()
        assert q.reported == 0
        assert q.months_reported == 0
        assert q.nibrs_reported == 0
        assert q.nibrs_months_reported == 0
        assert q.covered == 1
        assert q.participated == 1
        assert q.nibrs_participated == 1

    def test_for_agency_in_nibrs_month(self, app):
        q = AgencyParticipation.query
        q = q.filter(AgencyParticipation.year == 2014)
        q = q.filter(AgencyParticipation.agency_id == 17381).one()
        assert q.reported == 1
        assert q.months_reported == 12
        assert q.nibrs_reported == 1
        assert q.nibrs_months_reported == 12

    def test_for_agency_not_in_nibrs_month(self, app):
        q = AgencyParticipation.query
        q = q.filter(AgencyParticipation.year == 2014)
        q = q.filter(AgencyParticipation.agency_id == 17427).one()
        assert q.reported == 1
        assert q.months_reported == 12
        assert q.nibrs_reported == 0
        assert q.nibrs_months_reported == 0


class TestParticipationRate:
    def test_for_state_in_year(self, app):
        q = ParticipationRate.query
        q = q.filter(ParticipationRate.year == 2014)
        q = q.filter(ParticipationRate.state_id == 44).one()
        assert q.year == 2014
        assert q.state_id == 44
        assert q.total_agencies == 62
        assert q.participating_agencies == 54
        assert q.participation_rate == pytest.approx(0.870967742)
        assert q.nibrs_participating_agencies == 52
        assert q.nibrs_participation_rate == pytest.approx(0.838709677)

    def test_for_county_in_year(self, app):
        pass
        q = ParticipationRate.query
        q = q.filter(ParticipationRate.year == 2014)
        q = q.filter(ParticipationRate.state_id == 44).one()
        assert q.year == 2014
        assert q.state_id == 44
        assert q.total_agencies == 62
        assert q.participating_agencies == 54
        assert q.participation_rate == pytest.approx(0.870967742)
        assert q.nibrs_participating_agencies == 52
        assert q.nibrs_participation_rate == pytest.approx(0.838709677)

    def test_for_year(self, app):
        q = ParticipationRate.query
        q = q.filter(ParticipationRate.year == 2014)
        q = q.filter(ParticipationRate.state_id == None)
        q = q.filter(ParticipationRate.county_id == None).one()
        assert q.year == 2014
        assert q.state_id is None
        assert q.total_agencies == 64
        assert q.participating_agencies == 54
        assert q.participation_rate == pytest.approx(0.84375)
        assert q.nibrs_participating_agencies == 52
        assert q.nibrs_participation_rate == pytest.approx(0.8125)
        assert q.total_population == 12142430
        assert q.participating_population == 1055173


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

class TestRetaMonthOffenseSubcatSummary:
    def test_year_rollup(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_code == 'SUM_HOM')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_category == 'Homicide')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_subcat == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == 2014)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == None).one()
        assert q.agencies == 49
        assert q.reported == 26
        assert q.unfounded == 0
        assert q.actual == 26
        assert q.cleared == 9
        assert q.juvenile_cleared == 1

    def test_year_month_rollup(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_code == 'SUM_HOM')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_category == 'Homicide')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_subcat == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == 2014)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == 11)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == None).one()
        assert q.agencies == 49
        assert q.reported == 2
        assert q.unfounded == 0
        assert q.actual == 2
        assert q.cleared == 1
        assert q.juvenile_cleared == 0

    def test_state_offense_rollup(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_code == 'SUM_HOM')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_category == 'Homicide')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_subcat == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == 2014)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == 11)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'RI').one()
        assert q.agencies == 49
        assert q.reported == 2
        assert q.unfounded == 0
        assert q.actual == 2
        assert q.cleared == 1
        assert q.juvenile_cleared == 0

    def test_state_offense_no_month_rollup(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_code == 'SUM_HOM')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_category == 'Homicide')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_subcat == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == 2014)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'RI').one()
        assert q.agencies == 49
        assert q.reported == 26
        assert q.unfounded == 0
        assert q.actual == 26
        assert q.cleared == 9
        assert q.juvenile_cleared == 1

    def test_classification_for_month_and_year_and_state(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_category == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == 2014)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == 1)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'RI').one()
        assert q.agencies == 49
        assert q.reported == 555
        assert q.unfounded == 0
        assert q.actual == 555
        assert q.cleared == 48
        assert q.juvenile_cleared == 6

    def test_arson_fields_for_state_month_year(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == 'Arson')
        q = q.filter(RetaMonthOffenseSubcatSummary.year == 2014)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == 1)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'RI')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_subcat_code == None).one()
        assert q.reported == 6
        assert q.unfounded == 0
        assert q.actual == 6
        assert q.cleared == 3
        assert q.juvenile_cleared == 1

    def test_arson_fields_for_state_year(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == 'Arson')
        q = q.filter(RetaMonthOffenseSubcatSummary.year == 2014)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'RI')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_subcat_code == None).one()
        assert q.reported == 159
        assert q.unfounded == 0
        assert q.actual == 159
        assert q.cleared == 42
        assert q.juvenile_cleared == 22

    def test_arson_fields_for_state(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == 'Arson')
        q = q.filter(RetaMonthOffenseSubcatSummary.month == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'RI')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_subcat_code == None).one()
        assert q.agencies == 49
        assert q.reported == 159
        assert q.unfounded == 0
        assert q.actual == 159
        assert q.cleared == 42
        assert q.juvenile_cleared == 22

    def test_arson_fields_for_arson_total(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == 'Arson')
        q = q.filter(RetaMonthOffenseSubcatSummary.month == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_subcat_code == None).one()
        assert q.reported == 159
        assert q.unfounded == 0
        assert q.actual == 159
        assert q.cleared == 42
        assert q.juvenile_cleared == 22

    def test_arson_fields_for_state_month_year(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == 'Arson')
        q = q.filter(RetaMonthOffenseSubcatSummary.year == 2014)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == 1)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'RI')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_subcat_code == None).one()
        assert q.reported == 6
        assert q.unfounded == 0
        assert q.actual == 6
        assert q.cleared == 3
        assert q.juvenile_cleared == 1

    def test_classification_for_month_and_year(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_category == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == 2014)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == 1)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == None).one()
        assert q.reported == 555
        assert q.unfounded == 0
        assert q.actual == 555
        assert q.cleared == 48
        assert q.juvenile_cleared == 6

    def test_classification_for_month_and_state(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_category == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == 1)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'RI').one()
        assert q.reported == 555
        assert q.unfounded == 0
        assert q.actual == 555
        assert q.cleared == 48
        assert q.juvenile_cleared == 6
