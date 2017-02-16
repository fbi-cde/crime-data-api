# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import dateutil
import pytest


# class TestTuningPage:
#     def test_tuning_page_exists(self, testapp):
#         res = testapp.get('/arson/?tuning=1')
#         assert res.status_code == 200
#         assert b'<!DOCTYPE html>' in res.body


# class TestArsonCountEndpoint:
#     def test_arson_count_exists(self, testapp):
#         res = testapp.get('/arson/')
#         assert res.status_code == 200

#     def test_incidents_endpoint_includes_metadata(self, testapp):
#         res = testapp.get('/arson/')
#         assert 'pagination' in res.json

#     def test_arson_count_returns_counts(self, testapp):
#         res = testapp.get('/arson/')
#         assert isinstance(res.json['results'], list)
#         assert 'reported_count' in res.json['results'][0]

#     def test_arson_count_groups_by_year_by_default(self, testapp):
#         res = testapp.get('/arson/')
#         years = [row['year'] for row in res.json['results']]
#         assert len(years) == len(set(years))

#     def test_arson_count_groups_by_ori(self, testapp):
#         res = testapp.get('/arson/?by=ori')
#         oris = [row['ori'] for row in res.json['results']]
#         assert len(oris) == len(set(oris))

#     def test_arson_count_groups_by_ori_any_year(self, testapp):
#         res = testapp.get('/arson/?by=ori,year')
#         rows = [(row['year'], row['ori']) for row in res.json['results']]
#         assert len(rows) == len(set(rows))

#     def test_arson_count_groups_by_state(self, testapp):
#         res = testapp.get('/arson/?by=state')
#         rows = [row['state'] for row in res.json['results']]
#         assert len(rows) == len(set(rows))

#     def test_arson_count_groups_by_subcategory(self, testapp):
#         res = testapp.get('/arson/?by=subcategory')
#         rows = [row['subcategory'] for row in res.json['results']]
#         assert len(rows) == len(set(rows))

#     def test_arson_count_sorts_by_state(self, testapp):
#         res = testapp.get('/arson/?by=state')
#         state_names = [r['state'] for r in res.json['results']]
#         assert state_names == sorted(state_names)

#     def test_arson_count_filters_on_subcategory(self, testapp):
#         res = testapp.get(
#             '/arson/?by=year,subcategory&subcategory=COM'
#         )
#         assert res.json['results']
#         for row in res.json['results']:
#             assert row['subcategory'] == 'COM'

#     def test_arson_count_filters_on_subclass(self, testapp):
#         res = testapp.get(
#             '/arson/?by=year,subclass_name&subclass_name=Structural')
#         assert res.json['results']
#         for row in res.json['results']:
#             assert row['subclass_name'] == 'Structural'

#     def test_arson_count_filters_on_city(self, testapp):
#         res = testapp.get('/arson/?by=city&city=dayton')
#         assert res.json['results']
#         for row in res.json['results']:
#             assert row['city'] == 'Dayton'

#     def test_arson_count_bad_filter_400s(self, testapp):
#         res = testapp.get('/arson/?llamas=angry', expect_errors=True)
#         assert res.status_code == 400

#     def test_arson_count_bad_group_by_400s(self, testapp):
#         res = testapp.get('/arson/?by=llamas', expect_errors=True)
#         assert res.status_code == 400

#     def test_arson_count_filter_names_case_insensitive(self, testapp):
#         res = testapp.get(
#             '/arson/?by=year,subclass_name&SubClass_Name=Structural')
#         assert res.json['results']
#         for row in res.json['results']:
#             assert row['subclass_name'] == 'Structural'

#     def test_arson_count_filter_values_case_insensitive(self, testapp):
#         res = testapp.get(
#             '/arson/?by=year,subclass_name&subclass_name=sTruCTurAl')
#         assert res.json['results']
#         for row in res.json['results']:
#             assert row['subclass_name'] == 'Structural'

#     def test_arson_count_equality_filter_by_number(self, testapp):
#         res = testapp.get('/arson/?by=year,month&month=1')
#         assert res.status_code == 200
#         assert res.json['results']
#         for row in res.json['results']:
#             assert row['month'] == 1 

#     def test_arson_count_equality_filter_by_multiple_number(self, testapp):
#         res = testapp.get('/arson/?by=year,month&month=1,2')
#         assert res.json['results']
#         for row in res.json['results']:
#             assert row['month'] in (1, 2)

#     def test_arson_count_filters_by_greater_than(self, testapp):
#         res = testapp.get('/arson/?by=year,month&month<6')
#         assert res.json['results']
#         for row in res.json['results']:
#             assert row['month'] < 6

#     def test_arson_count_filters_by_less_than_or_equal_to(self, testapp):
#         res = testapp.get('/arson/?by=year,month&month<=3')
#         assert res.json['results']
#         for row in res.json['results']:
#             assert row['month'] <= 3

#     def test_arson_count_filters_by_inequality(self, testapp):
#         res = testapp.get(
#             '/arson/?by=year,subclass_name&subclass_name!=Structural&per_page=100'
#         )
#         assert res.json['results']
#         for row in res.json['results']:
#             assert row['subclass_name'] != 'Structural'

#     def test_arson_count_simplified_field_name_is_equivalent(self, testapp):
#         res = testapp.get('/arson/?by=data_year,subclass_code')
#         simplified_res = testapp.get('/arson/?by=year,subclass')
#         assert res.json['results'] == simplified_res.json['results']

#     def test_arson_count_reports_simplified_field_name(self, testapp):
#         res = testapp.get('/arson/?by=data_year,subclass')
#         assert res.json['results']
#         for row in res.json['results']:
#             assert 'year' in row
#             assert 'subclass' in row
