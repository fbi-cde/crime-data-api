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
        assert q.reported == 4290
        assert q.unfounded == 481
        assert q.actual == 3809
        assert q.cleared == 624
        assert q.juvenile_cleared == 220

    def test_arson_fields_for_state_month_year_subcategory(self, app):
      q = RetaMonthOffenseSubcatSummary.query
        q = q.filter(RetaMonthOffenseSubcatSummary.classification == 'Property')
        q = q.filter(RetaMonthOffenseSubcatSummary.offense == 'Arson')
        q = q.filter(RetaMonthOffenseSubcatSummary.month == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.year == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.state == None)
        q = q.filter(RetaMonthOffenseSubcatSummary.offense_subcat_code == None).one()
        assert q.reported == 4290
        assert q.unfounded == 481
        assert q.actual == 3809
        assert q.cleared == 624
        assert q.juvenile_cleared == 220
