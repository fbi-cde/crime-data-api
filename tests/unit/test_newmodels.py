# -*- coding: utf-8 -*-

from crime_data.common.newmodels import (RetaMonthOffenseSubcatSummary,
                                         AgencyAnnualParticipation,
                                         ParticipationRate)
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
        q = q.filter(ParticipationRate.data_year == 1991)
        q = q.filter(ParticipationRate.state_id == 2).one()
        assert q.data_year == 1991
        assert q.state_id == 2
        assert q.total_agencies == 1
        assert q.reporting_agencies == 1
        assert q.reporting_rate == 1
        assert q.nibrs_reporting_agencies == 1
        assert q.nibrs_reporting_rate == 1
        assert q.total_population == 80007
        assert q.covered_population == 0


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
