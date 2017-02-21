# -*- coding: utf-8 -*-

from crime_data.common.newmodels import RetaMonthOffenseSubcatSummary
import pytest


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
        assert q.reported == 255
        assert q.unfounded == 33
        assert q.actual == 222
        assert q.cleared == 34
        assert q.juvenile_cleared == 14

    def test_arson_fields_for_arson_total(self, app):
        q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == 'Arson')
        q = q.filter(RetaMonthOffenseSubcatSummary.month == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_subcat_code == None).one()
        assert q.reported == 4293
        assert q.unfounded == 482
        assert q.actual == 3811
        assert q.cleared == 625
        assert q.juvenile_cleared == 221

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
        assert q.reported == 4372
        assert q.unfounded == 482
        assert q.actual == 3890
        assert q.cleared == 626
        assert q.juvenile_cleared == 221
