# -*- coding: utf-8 -*-

from crime_data.common.newmodels import (RetaMonthOffenseSubcatSummary,
                                         AgencyAnnualParticipation,
                                         ParticipationRate,
                                         CdeAgency)
import pytest

class TestAgencyAnnualParticipation:
    def test_for_agency_in_nibrs_month(self, app):
        q = AgencyAnnualParticipation.query
        q = q.filter(AgencyAnnualParticipation.data_year == 2014)
        q = q.filter(AgencyAnnualParticipation.agency_id == 17381).one()
        assert q.reported == 1
        assert q.months_reported == 12
        assert q.reported_nibrs == 1
        assert q.months_reported_nibrs == 12

    def test_for_agency_not_in_nibrs_month(self, app):
        q = AgencyAnnualParticipation.query
        q = q.filter(AgencyAnnualParticipation.data_year == 2014)
        q = q.filter(AgencyAnnualParticipation.agency_id == 17427).one()
        assert q.reported == 1
        assert q.months_reported == 12
        assert q.reported_nibrs == 0
        assert q.months_reported_nibrs == 0


class TestParticipationRate:
    def test_for_state_in_year(self, app):
        q = ParticipationRate.query
        q = q.filter(ParticipationRate.data_year == 2014)
        q = q.filter(ParticipationRate.state_id == 44).one()
        assert q.data_year == 2014
        assert q.state_id == 44
        assert q.total_agencies == 56
        assert q.reporting_agencies == 52
        assert q.reporting_rate == pytest.approx(0.928571429)
        assert q.nibrs_reporting_agencies == 50
        assert q.nibrs_reporting_rate == pytest.approx(0.892857143)


    def test_for_year(self, app):
        q = ParticipationRate.query
        q = q.filter(ParticipationRate.data_year == 2014)
        q = q.filter(ParticipationRate.state_id == None)
        q = q.filter(ParticipationRate.county_id == None).one()
        assert q.data_year == 2014
        assert q.state_id is None
        assert q.total_agencies == 58
        assert q.reporting_agencies == 54
        assert q.reporting_rate == pytest.approx(0.931034483)
        assert q.nibrs_reporting_agencies == 50
        assert q.nibrs_reporting_rate == pytest.approx(0.862068966)
        assert q.total_population == 12142430
        assert q.covered_population == 1323169


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
        a = CdeAgency.query.filter(CdeAgency.agency_id == 16487).one()
        assert a is not None
        assert a.current_year == 1984
        assert a.covered_by_id == 16495
        assert a.covered_by_ori == 'PA030SP00'
        assert a.covered_by_name == 'State Police: Greene County'

    def test_current_year_and_population(self, app):
        a = CdeAgency.query.filter(CdeAgency.agency_id == 15909).one()
        assert a is not None
        assert a.current_year == 2013
        assert a.population == 10479
        assert a.suburban_area_flag == 'Y'

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


class TestArsonAdditionsToRetaMonthOffenseSubcatSummary:
    def test_arson_fields_for_state_month_year(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == 'Arson')
        q = q.filter(RetaMonthOffenseSubcatSummary.year == 2014)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == 1)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'RI')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_subcat_code == None).one()
        assert q.reported == 7
        assert q.unfounded == 4
        assert q.actual == 3
        assert q.cleared == 0
        assert q.juvenile_cleared == 0

    def test_arson_fields_for_state_year(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == 'Arson')
        q = q.filter(RetaMonthOffenseSubcatSummary.year == 2014)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'RI')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_subcat_code == None).one()
        assert q.reported == 254
        assert q.unfounded == 0
        assert q.actual == 254
        assert q.cleared == 92
        assert q.juvenile_cleared == 44

    def test_arson_fields_for_state(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == 'Arson')
        q = q.filter(RetaMonthOffenseSubcatSummary.month == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'RI')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_subcat_code == None).one()
        assert q.reported == 254
        assert q.unfounded == 0
        assert q.actual == 254
        assert q.cleared == 92
        assert q.juvenile_cleared == 44

    def test_arson_fields_for_arson_total(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == 'Arson')
        q = q.filter(RetaMonthOffenseSubcatSummary.month == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_subcat_code == None).one()
        assert q.reported == 4287
        assert q.unfounded == 482
        assert q.actual == 3805
        assert q.cleared == 700
        assert q.juvenile_cleared == 259

    def test_arson_fields_for_state_month_year(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == 'Arson')
        q = q.filter(RetaMonthOffenseSubcatSummary.year == 2014)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == 1)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'RI')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_subcat_code == None).one()
        assert q.reported == 10
        assert q.unfounded == 0
        assert q.actual == 10
        assert q.cleared == 4
        assert q.juvenile_cleared == 2

    # Test it is adding counts to Classification
    def test_classification_for_month_and_year_and_state(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_category == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == 2014)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == 1)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'RI').one()
        assert q.reported == 484
        assert q.unfounded == 0
        assert q.actual == 484
        assert q.cleared == 47
        assert q.juvenile_cleared == 8

    def test_classification_for_month_and_year(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_category == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == 2014)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == 1)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == None).one()
        assert q.reported == 496
        assert q.unfounded == 1
        assert q.actual == 495
        assert q.cleared == 50
        assert q.juvenile_cleared == 9

    def test_classification_for_month_and_state(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_category == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == 1)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'RI').one()
        assert q.reported == 484
        assert q.unfounded == 0
        assert q.actual == 484
        assert q.cleared == 47
        assert q.juvenile_cleared == 8

    def test_classification_for_year_and_state(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_category == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == 2014)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'RI').one()
        assert q.reported == 5913
        assert q.unfounded == 0
        assert q.actual == 5913
        assert q.cleared == 757
        assert q.juvenile_cleared == 135

    def test_classification_for_state(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_category == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'RI').one()
        assert q.reported == 5913
        assert q.unfounded == 0
        assert q.actual == 5913
        assert q.cleared == 757
        assert q.juvenile_cleared == 135

    def test_classification_for_year(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_category == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == 2014).one()
        assert q.reported == 5925
        assert q.unfounded == 1
        assert q.actual == 5924
        assert q.cleared == 760
        assert q.juvenile_cleared == 136

    def test_classification_overall(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_category == None).one()
        assert q.reported == 10025
        assert q.unfounded == 482
        assert q.actual == 9543
        assert q.cleared == 1367
        assert q.juvenile_cleared == 350
