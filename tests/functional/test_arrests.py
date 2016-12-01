# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import dateutil
import pytest


class TestTuningPage:
    def test_tuning_page_exists(self, user, testapp):
        res = testapp.get('/arrests/race/?tuning=1')
        assert res.status_code == 200
        assert b'<!DOCTYPE html>' in res.body


class TestArrestsCountByRaceEndpoint:
    def test_arrests_count_exists(self, testapp):
        res = testapp.get('/arrests/race/')
        assert res.status_code == 200

    def test_incidents_endpoint_includes_metadata(self, user, testapp):
        res = testapp.get('/arrests/race/')
        assert 'pagination' in res.json

    def test_arrests_count_returns_counts(self, testapp):
        res = testapp.get('/arrests/race/')
        assert isinstance(res.json['results'], list)
        assert 'arrest_count' in res.json['results'][0]

    def test_arrests_count_groups_by_year_by_default(self, testapp):
        res = testapp.get('/arrests/race/')
        years = [row['year'] for row in res.json['results']]
        assert len(years) == len(set(years))

    def test_arrests_count_groups_by_ori(self, testapp):
        res = testapp.get('/arrests/race/?by=ori')
        oris = [row['ori'] for row in res.json['results']]
        assert len(oris) == len(set(oris))

    def test_arrests_count_groups_by_race(self, testapp):
        res = testapp.get('/arrests/race/?by=race')
        uniques = [row['race'] for row in res.json['results']]
        assert len(uniques) == len(set(uniques))

    def test_arrests_count_groups_by_ori_any_year(self, testapp):
        res = testapp.get('/arrests/race/?by=ori,year')
        rows = [(row['year'], row['ori']) for row in res.json['results']]
        assert len(rows) == len(set(rows))

    def test_arrests_count_groups_by_state(self, testapp):
        res = testapp.get('/arrests/race/?by=state')
        rows = [row['state'] for row in res.json['results']]
        assert len(rows) == len(set(rows))

    def test_arrests_count_groups_by_offense(self, testapp):
        res = testapp.get('/arrests/race/?by=offense')
        rows = [row['offense'] for row in res.json['results']]
        assert len(rows) == len(set(rows))

    def test_arrests_count_sorts_by_state(self, testapp):
        res = testapp.get('/arrests/race/?by=state')
        state_names = [r['state'] for r in res.json['results']]
        assert state_names == sorted(state_names)

    def test_arrests_count_filters_on_subcategory(self, testapp):
        res = testapp.get(
            '/arrests/race/?by=year,offense_subcat_code&offense_subcat_code=ASR_HOM'
        )
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_subcat_code'] == 'ASR_HOM'

    def test_arrests_count_filters_on_race(self, testapp):
        res = testapp.get('/arrests/race/?by=year,race&race=A')
        assert res.json['results']
        for row in res.json['results']:
            assert row['race'] == 'A'

    def test_arrests_count_filters_on_category(self, testapp):
        res = testapp.get(
            '/arrests/race/?by=year,offense_cat_name&offense_cat_name=Robbery')
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_cat_name'] == 'Robbery'

    def test_arrests_count_filters_on_city(self, testapp):
        res = testapp.get('/arrests/race/?by=city&city=dayton')
        assert res.json['results']
        for row in res.json['results']:
            assert row['city'] == 'Dayton'

    def test_arrests_count_bad_filter_400s(self, testapp):
        res = testapp.get('/arrests/race/?llamas=angry', expect_errors=True)
        assert res.status_code == 400

    def test_arrests_count_bad_group_by_400s(self, testapp):
        res = testapp.get('/arrests/race/?by=llamas', expect_errors=True)
        assert res.status_code == 400

    def test_arrests_count_filter_names_case_insensitive(self, testapp):
        res = testapp.get(
            '/arrests/race/?by=year,offense_cat_name&offense_cat_name=Robbery')
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_cat_name'] == 'Robbery'

    def test_arrests_count_filter_values_case_insensitive(self, testapp):
        res = testapp.get(
            '/arrests/race/?by=year,offense_cat_name&offense_cat_name=RobBeRY')
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_cat_name'] == 'Robbery'

    def test_arrests_count_equality_filter_by_number(self, testapp):
        res = testapp.get('/arrests/race/?by=year,month&month=10')
        assert res.json['results']
        for row in res.json['results']:
            assert row['month'] == 10

    def test_arrests_count_equality_filter_by_multiple_number(self, testapp):
        res = testapp.get('/arrests/race/?by=year,month&month=8,10')
        assert res.json['results']
        for row in res.json['results']:
            assert row['month'] in (8, 10)

    def test_arrests_count_filters_by_greater_than(self, testapp):
        res = testapp.get('/arrests/race/?by=year,month&month>6')
        assert res.json['results']
        for row in res.json['results']:
            assert row['month'] > 6

    def test_arrests_count_filters_by_less_than_or_equal_to(self, testapp):
        res = testapp.get('/arrests/race/?by=year,month&month<=3')
        assert res.json['results']
        for row in res.json['results']:
            assert row['month'] <= 3

    def test_arrests_count_filters_by_less_than_or_equal_to(self, testapp):
        res = testapp.get(
            '/arrests/race/?by=year,offense_cat_name&offense_cat_name!=Robbery&per_page=100'
        )
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_cat_name'] != 'Robbery'

    def test_arrests_count_simplified_field_name_is_equivalent(self, testapp):
        res = testapp.get('/arrests/race/?by=data_year,state_abbr')
        simplified_res = testapp.get('/arrests/race/?by=year,state')
        assert res.json['results'] == simplified_res.json['results']

    def test_arrests_count_reports_simplified_field_name(self, testapp):
        res = testapp.get('/arrests/race/?by=data_year,state')
        assert res.json['results']
        for row in res.json['results']:
            assert 'year' in row
            assert 'state' in row

    def test_arrests_count_juvenile_results_sum_properly(self, testapp):
        res = testapp.get('/arrests/race/?race=W&juvenile=Y&year=2013')
        juveniles = res.json['results'][0]['arrest_count']
        res = testapp.get('/arrests/race/?race=W&juvenile=N&year=2013')
        nonjuveniles = res.json['results'][0]['arrest_count']
        res = testapp.get('/arrests/race/?race=W&year=2013')
        total = res.json['results'][0]['arrest_count']
        assert juveniles + nonjuveniles == total


class TestArrestsCountByEthnicityEndpoint:
    def test_arrests_count_exists(self, testapp):
        res = testapp.get('/arrests/ethnicity/')
        assert res.status_code == 200

    def test_incidents_endpoint_includes_metadata(self, user, testapp):
        res = testapp.get('/arrests/ethnicity/')
        assert 'pagination' in res.json

    @pytest.mark.xfail  # needs a new test db with ethnicity rows
    def test_arrests_count_returns_counts(self, testapp):
        res = testapp.get('/arrests/ethnicity/')
        assert isinstance(res.json['results'], list)
        assert 'arrest_count' in res.json['results'][0]

    @pytest.mark.xfail  # needs a new test db with ethnicity rows
    def test_arrests_count_groups_by_year_by_default(self, testapp):
        res = testapp.get('/arrests/ethnicity/')
        years = [row['year'] for row in res.json['results']]
        assert len(years) == len(set(years))

    @pytest.mark.xfail  # needs a new test db with ethnicity rows
    def test_arrests_count_groups_by_ori(self, testapp):
        res = testapp.get('/arrests/ethnicity/?by=ori')
        oris = [row['ori'] for row in res.json['results']]
        assert len(oris) == len(set(oris))

    @pytest.mark.xfail  # needs a new test db with ethnicity rows
    def test_arrests_count_groups_by_ethnicity(self, testapp):
        res = testapp.get('/arrests/ethnicity/?by=ethnicity')
        uniques = [row['ethnicity'] for row in res.json['results']]
        assert len(uniques) == len(set(uniques))

    @pytest.mark.xfail  # needs a new test db with ethnicity rows
    def test_arrests_count_groups_by_ori_any_year(self, testapp):
        res = testapp.get('/arrests/ethnicity/?by=ori,year')
        rows = [(row['year'], row['ori']) for row in res.json['results']]
        assert len(rows) == len(set(rows))

    @pytest.mark.xfail  # needs a new test db with ethnicity rows
    def test_arrests_count_groups_by_state(self, testapp):
        res = testapp.get('/arrests/ethnicity/?by=state')
        rows = [row['state'] for row in res.json['results']]
        assert len(rows) == len(set(rows))

    @pytest.mark.xfail  # needs a new test db with ethnicity rows
    def test_arrests_count_groups_by_offense(self, testapp):
        res = testapp.get('/arrests/ethnicity/?by=offense')
        rows = [row['offense'] for row in res.json['results']]
        assert len(rows) == len(set(rows))

    @pytest.mark.xfail  # needs a new test db with ethnicity rows
    def test_arrests_count_sorts_by_state(self, testapp):
        res = testapp.get('/arrests/ethnicity/?by=state')
        state_names = [r['state'] for r in res.json['results']]
        assert state_names == sorted(state_names)

    @pytest.mark.xfail  # needs a new test db with ethnicity rows
    def test_arrests_count_filters_on_subcategory(self, testapp):
        res = testapp.get(
            '/arrests/ethnicity/?by=year,offense_subcat_code&offense_subcat_code=ASR_HOM'
        )
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_subcat_code'] == 'ASR_HOM'

    @pytest.mark.xfail  # needs a new test db with ethnicity rows
    def test_arrests_count_filters_on_ethnicity(self, testapp):
        res = testapp.get(
            '/arrests/ethnicity/?by=year,ethnicity&ethnicity=UNK')
        assert res.json['results']
        for row in res.json['results']:
            assert row['ethnicity'] == 'UNK'

    @pytest.mark.xfail  # needs a new test db with ethnicity rows
    def test_arrests_count_filters_on_category(self, testapp):
        res = testapp.get(
            '/arrests/ethnicity/?by=year,offense_cat_name&offense_cat_name=Robbery'
        )
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_cat_name'] == 'Robbery'

    @pytest.mark.xfail  # needs a new test db with ethnicity rows
    def test_arrests_count_filters_on_city(self, testapp):
        res = testapp.get('/arrests/ethnicity/?by=city&city=dayton')
        assert res.json['results']
        for row in res.json['results']:
            assert row['city'] == 'Dayton'

    @pytest.mark.xfail  # needs a new test db with ethnicity rows
    def test_arrests_count_bad_filter_400s(self, testapp):
        res = testapp.get('/arrests/ethnicity/?llamas=angry',
                          expect_errors=True)
        assert res.status_code == 400

    @pytest.mark.xfail  # needs a new test db with ethnicity rows
    def test_arrests_count_bad_group_by_400s(self, testapp):
        res = testapp.get('/arrests/ethnicity/?by=llamas', expect_errors=True)
        assert res.status_code == 400

    @pytest.mark.xfail  # needs a new test db with ethnicity rows
    def test_arrests_count_filter_names_case_insensitive(self, testapp):
        res = testapp.get(
            '/arrests/ethnicity/?by=year,offense_cat_name&offense_cat_name=Robbery'
        )
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_cat_name'] == 'Robbery'

    @pytest.mark.xfail  # needs a new test db with ethnicity rows
    def test_arrests_count_filter_values_case_insensitive(self, testapp):
        res = testapp.get(
            '/arrests/ethnicity/?by=year,offense_cat_name&offense_cat_name=RobBeRY'
        )
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_cat_name'] == 'Robbery'

    @pytest.mark.xfail  # needs a new test db with ethnicity rows
    def test_arrests_count_equality_filter_by_number(self, testapp):
        res = testapp.get('/arrests/ethnicity/?by=year,month&month=10')
        assert res.json['results']
        for row in res.json['results']:
            assert row['month'] == 10

    @pytest.mark.xfail  # needs a new test db with ethnicity rows
    def test_arrests_count_equality_filter_by_multiple_number(self, testapp):
        res = testapp.get('/arrests/ethnicity/?by=year,month&month=8,10')
        assert res.json['results']
        for row in res.json['results']:
            assert row['month'] in (8, 10)

    @pytest.mark.xfail  # needs a new test db with ethnicity rows
    def test_arrests_count_filters_by_greater_than(self, testapp):
        res = testapp.get('/arrests/ethnicity/?by=year,month&month>6')
        assert res.json['results']
        for row in res.json['results']:
            assert row['month'] > 6

    @pytest.mark.xfail  # needs a new test db with ethnicity rows
    def test_arrests_count_filters_by_less_than_or_equal_to(self, testapp):
        res = testapp.get('/arrests/ethnicity/?by=year,month&month<=3')
        assert res.json['results']
        for row in res.json['results']:
            assert row['month'] <= 3

    @pytest.mark.xfail  # needs a new test db with ethnicity rows
    def test_arrests_count_filters_by_less_than_or_equal_to(self, testapp):
        res = testapp.get(
            '/arrests/ethnicity/?by=year,offense_cat_name&offense_cat_name!=Robbery&per_page=100'
        )
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_cat_name'] != 'Robbery'

    @pytest.mark.xfail  # needs a new test db with ethnicity rows
    def test_arrests_count_simplified_field_name_is_equivalent(self, testapp):
        res = testapp.get('/arrests/ethnicity/?by=data_year,state_abbr')
        simplified_res = testapp.get('/arrests/ethnicity/?by=year,state')
        assert res.json['results'] == simplified_res.json['results']

    @pytest.mark.xfail  # needs a new test db with ethnicity rows
    def test_arrests_count_reports_simplified_field_name(self, testapp):
        res = testapp.get('/arrests/ethnicity/?by=data_year,state')
        assert res.json['results']
        for row in res.json['results']:
            assert 'year' in row
            assert 'state' in row


class TestArrestsCountByAgeSexEndpoint:
    def test_arrests_count_exists(self, testapp):
        res = testapp.get('/arrests/age_sex/')
        assert res.status_code == 200

    def test_incidents_endpoint_includes_metadata(self, user, testapp):
        res = testapp.get('/arrests/age_sex/')
        assert 'pagination' in res.json

    def test_arrests_count_returns_counts(self, testapp):
        res = testapp.get('/arrests/age_sex/')
        assert isinstance(res.json['results'], list)
        assert 'arrest_count' in res.json['results'][0]

    def test_arrests_count_groups_by_year_by_default(self, testapp):
        res = testapp.get('/arrests/age_sex/')
        years = [row['year'] for row in res.json['results']]
        assert len(years) == len(set(years))

    def test_arrests_count_groups_by_ori(self, testapp):
        res = testapp.get('/arrests/age_sex/?by=ori')
        oris = [row['ori'] for row in res.json['results']]
        assert len(oris) == len(set(oris))

    def test_arrests_count_groups_by_age_sex(self, testapp):
        res = testapp.get('/arrests/age_sex/?by=age_sex')
        uniques = [row['sex'] for row in res.json['results']]
        assert len(uniques) == len(set(uniques))

    def test_arrests_count_groups_by_ori_any_year(self, testapp):
        res = testapp.get('/arrests/age_sex/?by=ori,year')
        rows = [(row['year'], row['ori']) for row in res.json['results']]
        assert len(rows) == len(set(rows))

    def test_arrests_count_groups_by_state(self, testapp):
        res = testapp.get('/arrests/age_sex/?by=state')
        rows = [row['state'] for row in res.json['results']]
        assert len(rows) == len(set(rows))

    def test_arrests_count_groups_by_offense(self, testapp):
        res = testapp.get('/arrests/age_sex/?by=offense')
        rows = [row['offense'] for row in res.json['results']]
        assert len(rows) == len(set(rows))

    def test_arrests_count_sorts_by_state(self, testapp):
        res = testapp.get('/arrests/age_sex/?by=state')
        state_names = [r['state'] for r in res.json['results']]
        assert state_names == sorted(state_names)

    def test_arrests_count_filters_on_subcategory(self, testapp):
        res = testapp.get(
            '/arrests/age_sex/?by=year,offense_subcat_code&offense_subcat_code=ASR_HOM'
        )
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_subcat_code'] == 'ASR_HOM'

    def test_arrests_count_filters_on_sex(self, testapp):
        res = testapp.get('/arrests/age_sex/?by=year,sex&sex=F')
        assert res.json['results']
        for row in res.json['results']:
            assert row['sex'] == 'F'

    def test_arrests_count_filters_on_category(self, testapp):
        res = testapp.get(
            '/arrests/age_sex/?by=year,offense_cat_name&offense_cat_name=Robbery'
        )
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_cat_name'] == 'Robbery'

    def test_arrests_count_filters_on_city(self, testapp):
        res = testapp.get('/arrests/age_sex/?by=city&city=dayton')
        assert res.json['results']
        for row in res.json['results']:
            assert row['city'] == 'Dayton'

    def test_arrests_count_bad_filter_400s(self, testapp):
        res = testapp.get('/arrests/age_sex/?llamas=angry', expect_errors=True)
        assert res.status_code == 400

    def test_arrests_count_bad_group_by_400s(self, testapp):
        res = testapp.get('/arrests/age_sex/?by=llamas', expect_errors=True)
        assert res.status_code == 400

    def test_arrests_count_filter_names_case_insensitive(self, testapp):
        res = testapp.get(
            '/arrests/age_sex/?by=year,offense_cat_name&offense_cat_name=Robbery'
        )
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_cat_name'] == 'Robbery'

    def test_arrests_count_filter_values_case_insensitive(self, testapp):
        res = testapp.get(
            '/arrests/age_sex/?by=year,offense_cat_name&offense_cat_name=RobBeRY'
        )
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_cat_name'] == 'Robbery'

    def test_arrests_count_equality_filter_by_number(self, testapp):
        res = testapp.get('/arrests/age_sex/?by=year,month&month=10')
        assert res.json['results']
        for row in res.json['results']:
            assert row['month'] == 10

    def test_arrests_count_equality_filter_by_multiple_number(self, testapp):
        res = testapp.get('/arrests/age_sex/?by=year,month&month=8,10')
        assert res.json['results']
        for row in res.json['results']:
            assert row['month'] in (8, 10)

    def test_arrests_count_filters_by_greater_than(self, testapp):
        res = testapp.get('/arrests/age_sex/?by=year,month&month>6')
        assert res.json['results']
        for row in res.json['results']:
            assert row['month'] > 6

    def test_arrests_count_filters_by_less_than_or_equal_to(self, testapp):
        res = testapp.get('/arrests/age_sex/?by=year,month&month<=3')
        assert res.json['results']
        for row in res.json['results']:
            assert row['month'] <= 3

    def test_arrests_count_filters_by_less_than_or_equal_to(self, testapp):
        res = testapp.get(
            '/arrests/age_sex/?by=year,offense_cat_name&offense_cat_name!=Robbery&per_page=100'
        )
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_cat_name'] != 'Robbery'

    def test_arrests_count_simplified_field_name_is_equivalent(self, testapp):
        res = testapp.get('/arrests/age_sex/?by=data_year,state_abbr')
        simplified_res = testapp.get('/arrests/age_sex/?by=year,state')
        assert res.json['results'] == simplified_res.json['results']

    def test_arrests_count_reports_simplified_field_name(self, testapp):
        res = testapp.get('/arrests/age_sex/?by=data_year,state')
        assert res.json['results']
        for row in res.json['results']:
            assert 'year' in row
            assert 'state' in row
