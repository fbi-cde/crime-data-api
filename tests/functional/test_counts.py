# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""

import pytest
from crime_data.common.base import ExplorerOffenseMapping
from flex.core import validate_api_call

class TestCountsEndpoint:
    def test_counts_exists(self, testapp):
        res = testapp.get('/counts')
        assert res.status_code == 200

    def test_counts_matches_swagger(self, testapp, swagger):
        res = testapp.get('/counts')
        # import pdb;pdb.set_trace()
        validate_api_call(swagger, raw_request=res.request, raw_response=res)

    def test_counts_endpoint_includes_metadata(self, testapp):
        res = testapp.get('/counts')
        assert 'pagination' in res.json

    def test_counts_returns_counts(self, testapp):
        res = testapp.get('/counts')
        assert isinstance(res.json['results'], list)
        assert 'actual' in res.json['results'][0]

    def test_counts_groups_by_year_by_default(self, testapp):
        res = testapp.get('/counts')
        years = [row['year'] for row in res.json['results']]
        assert len(years) == len(set(years))

    # def test_counts_groups_by_ori(self, testapp):
    #     res = testapp.get('/counts?by=ori')
    #     oris = [row['ori'] for row in res.json['results']]
    #     assert len(oris) == len(set(oris))

    # def test_counts_groups_by_ori_any_year(self, testapp):
    #     res = testapp.get('/counts?by=year')
    #     rows = [(row['year'], row['ori']) for row in res.json['results']]
    #     assert len(rows) == len(set(rows))

    def test_counts_groups_by_state(self, testapp, swagger):
        res = testapp.get('/counts?by=state')
        rows = [row['state'] for row in res.json['results']]
        assert len(rows) == len(set(rows))
        validate_api_call(swagger, raw_request=res.request, raw_response=res)

    def test_counts_groups_by_offense(self, testapp, swagger):
        res = testapp.get('/counts?by=offense')
        rows = [row['offense'] for row in res.json['results']]
        assert len(rows) == len(set(rows))
        validate_api_call(swagger, raw_request=res.request, raw_response=res)

    @pytest.mark.parametrize('explorer_offense', ExplorerOffenseMapping.RETA_OFFENSE_MAPPING.keys())
    def test_counts_filter_by_explorer_offense(self, testapp, swagger, explorer_offense):
        url = '/counts?explorer_offense={}'.format(explorer_offense)
        res = testapp.get(url)
        assert 'pagination' in res.json
        validate_api_call(swagger, raw_request=res.request, raw_response=res)

    @pytest.mark.parametrize('groupby', ["year", "month", "offense_subcat_code", "offense_code", "offense_category", "classification", "state"])
    def test_counts_grouping(self, swagger, testapp, groupby):
        res = testapp.get('/counts?by={}'.format(groupby))
        group_values = [r[groupby] for r in res.json['results']]
        assert group_values == sorted(group_values)
        validate_api_call(swagger, raw_request=res.request, raw_response=res)

    def test_counts_filters_on_subcategory(self, testapp, swagger):
        res = testapp.get('/counts?by=year,offense_subcat_code&offense_subcat_code=SUM_HOM')
        assert res.json['results']
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        for row in res.json['results']:
            assert row['offense_subcat_code'] == 'SUM_HOM'

    def test_counts_filters_on_category(self, testapp, swagger):
        res = testapp.get('/counts?by=year,offense_category&offense_category=Robbery')
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_category'] == 'Robbery'

    # This is an intentional fail. We don't support city counts yet.
    @pytest.mark.xfail
    def test_counts_filters_on_city(self, testapp):
        res = testapp.get('/counts?by=city&city=columbus')
        assert res.json['results']
        for row in res.json['results']:
            assert row['city'] == 'Columbus'

    def test_counts_bad_filter_400s(self, testapp, swagger):
        res = testapp.get('/counts?llamas=angry', expect_errors=True)
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        assert res.status_code == 400

    def test_counts_bad_group_by_400s(self, testapp, swagger):
        res = testapp.get('/counts?by=llamas', expect_errors=True)
        assert res.status_code == 400
        # validate_api_call(swagger, raw_request=res.request, raw_response=res)

    def test_counts_filter_names_case_insensitive(self, testapp, swagger):
        res = testapp.get('/counts?by=year,offense_category&offense_category=Robbery')
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_category'] == 'Robbery'

    def test_counts_filter_values_case_insensitive(self, testapp, swagger):
        res = testapp.get('/counts?by=year,offense_category&offense_category=RobBeRY')
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_category'] == 'Robbery'

    def test_counts_equality_filter_by_number(self, testapp, swagger):
        res = testapp.get('/counts?by=year,month&month=1')
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        assert res.json['results']
        for row in res.json['results']:
            assert row['month'] == 1

    def test_counts_equality_filter_by_multiple_number(self, testapp, swagger):
        res = testapp.get('/counts?by=year,month&month=8,10')
        validate_api_call(swagger, raw_request=res.request, raw_response=res)
        assert res.json['results']
        for row in res.json['results']:
            assert row['month'] in (8, 10)

    def test_counts_filters_by_greater_than(self, testapp):
        res = testapp.get('/counts?by=year,month&month>6')
        assert res.json['results']
        for row in res.json['results']:
            assert row['month'] > 6

    def test_counts_filters_by_less_than_or_equal_to(self, testapp):
        res = testapp.get('/counts?by=year,month&month<=3')
        assert res.json['results']
        for row in res.json['results']:
            assert row['month'] <= 3

    def test_counts_filters_by_less_than_or_equal_to(self, testapp):
        res = testapp.get('/counts?by=year,offense_category&offense_category!=Robbery&per_page=100')
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_category'] != 'Robbery'
    @pytest.mark.xfail
    def test_incidents_null_age_codes(self, testapp):
        res = testapp.get('/incidents/?victim.age_code=99')
        assert res.json['results']
        for row in res.json['results']:
            assert any(victim['age_num'] == 99 for victim in row['victims'])
