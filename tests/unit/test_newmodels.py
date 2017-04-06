# -*- coding: utf-8 -*-

from crime_data.common.newmodels import (RetaMonthOffenseSubcatSummary,
                                         AgencyAnnualParticipation,
                                         ParticipationRate,
                                         CdeAgency)
import pytest

class TestAgencyAnnualParticipation:
    def test_for_agency_in_nibrs_month(self, app):
        q = AgencyAnnualParticipation.query
        q = q.filter(AgencyAnnualParticipation.data_year == 1991)
        q = q.filter(AgencyAnnualParticipation.agency_id == 191).one()
        assert q.reported == 1
        assert q.months_reported == 2
        assert q.reported_nibrs == 1
        assert q.months_reported_nibrs == 2

    def test_for_agency_not_in_nibrs_month(self, app):
        q = AgencyAnnualParticipation.query
        q = q.filter(AgencyAnnualParticipation.data_year == 2002)
        q = q.filter(AgencyAnnualParticipation.agency_id == 9744).one()
        assert q.reported == 1
        assert q.months_reported == 3
        assert q.reported_nibrs == 0
        assert q.months_reported_nibrs == 0


class TestParticipationRate:
    def test_for_state_in_year(self, app):
        q = ParticipationRate.query
        q = q.filter(ParticipationRate.data_year == 1999)
        q = q.filter(ParticipationRate.state_id == 47).one()
        assert q.data_year == 1999
        assert q.state_id == 47
        assert q.total_agencies == 8
        assert q.reporting_agencies == 5
        assert q.reporting_rate == pytest.approx(0.625)
        assert q.nibrs_reporting_agencies == 3
        assert q.nibrs_reporting_rate == pytest.approx(0.375)


    def test_for_year(self, app):
        q = ParticipationRate.query
        q = q.filter(ParticipationRate.data_year == 1991)
        q = q.filter(ParticipationRate.state_id == None)
        q = q.filter(ParticipationRate.county_id == None).one()

        assert q.data_year == 1991
        assert q.state_id is None
        assert q.total_agencies == 11
        assert q.reporting_agencies == 2
        assert q.reporting_rate == pytest.approx(0.181818182)
        assert q.nibrs_reporting_agencies == 1
        assert q.nibrs_reporting_rate == pytest.approx(0.090909091)
        assert q.total_population == 83769
        assert q.covered_population == 0


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

    def test_find_by_zip(self, app):
        agencies = CdeAgency.find_for_zip('08201')
        assert len(agencies) == 3
        oris = [a.ori for a in agencies]
        assert sorted(oris) == sorted(['AL0040000', 'AL0040100', 'AL0040200'])

class TestArsonAdditionsToRetaMonthOffenseSubcatSummary:
    def test_arson_fields_for_state_month_year(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == 'Arson')
        q = q.filter(RetaMonthOffenseSubcatSummary.year == 1984)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == 1)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'VA')
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
        q = q.filter(RetaMonthOffenseSubcatSummary.year == 1984)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'VA')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_subcat_code == None).one()
        assert q.reported == 10
        assert q.unfounded == 5
        assert q.actual == 5
        assert q.cleared == 0
        assert q.juvenile_cleared == 0

    def test_arson_fields_for_state(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == 'Arson')
        q = q.filter(RetaMonthOffenseSubcatSummary.month == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'VA')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_subcat_code == None).one()
        assert q.reported == 235
        assert q.unfounded == 33
        assert q.actual == 202
        assert q.cleared == 32
        assert q.juvenile_cleared == 12

    def test_arson_fields_for_arson_total(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == 'Arson')
        q = q.filter(RetaMonthOffenseSubcatSummary.month == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_subcat_code == None).one()
        assert q.reported == 4033
        assert q.unfounded == 482
        assert q.actual == 3551
        assert q.cleared == 608
        assert q.juvenile_cleared == 215

    def test_arson_fields_for_state_month_year(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == 'Arson')
        q = q.filter(RetaMonthOffenseSubcatSummary.year == 1984)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == 1)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'VA')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_subcat_code == None).one()
        assert q.reported == 7
        assert q.unfounded == 4
        assert q.actual == 3
        assert q.cleared == 0
        assert q.juvenile_cleared == 0

    # Test it is adding counts to Classification
    def test_classification_for_month_and_year_and_state(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_category == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == 2014)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == 1)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'AK').one()
        assert q.reported == 12
        assert q.unfounded == 1
        assert q.actual == 11
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
        assert q.reported == 12
        assert q.unfounded == 1
        assert q.actual == 11
        assert q.cleared == 3
        assert q.juvenile_cleared == 1

    def test_classification_for_month_and_year_and_other_state(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_category == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == 2014)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == 1)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'PA').one()
        assert q.reported == 0
        assert q.unfounded == 0
        assert q.actual == 0
        assert q.cleared == 0
        assert q.juvenile_cleared == 0

    def test_classification_for_month_and_state(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_category == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == 1)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'AK').one()
        assert q.reported == 19
        assert q.unfounded == 1
        assert q.actual == 18
        assert q.cleared == 4
        assert q.juvenile_cleared == 1

    def test_classification_for_year_and_state(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_category == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == 2014)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'AK').one()
        assert q.reported == 12
        assert q.unfounded == 1
        assert q.actual == 11
        assert q.cleared == 3
        assert q.juvenile_cleared == 1

    def test_classification_for_state(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_category == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == 'AK').one()
        assert q.reported == 27
        assert q.unfounded == 4
        assert q.actual == 23
        assert q.cleared == 7
        assert q.juvenile_cleared == 2

    def test_classification_for_year(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_category == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == 2014).one()
        assert q.reported == 12
        assert q.unfounded == 1
        assert q.actual == 11
        assert q.cleared == 3
        assert q.juvenile_cleared == 1

    def test_classification_overall(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.month == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_category == None).one()
        assert q.reported == 4112
        assert q.unfounded == 482
        assert q.actual == 3630
        assert q.cleared == 610
        assert q.juvenile_cleared == 215
