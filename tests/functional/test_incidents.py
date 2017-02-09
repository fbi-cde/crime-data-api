# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import dateutil
import pytest
from crime_data.common.newmodels import NibrsIncidentRepresentation
from crime_data.common.models import db


class TestTuningPage:
    def test_tuning_page_exists(self, testapp):
        res = testapp.get('/incidents/?tuning=1')
        assert res.status_code == 200
        assert b'<!DOCTYPE html>' in res.body


class TestIncidentsEndpoint:
    def test_incidents_endpoint_exists(self, testapp):
        res = testapp.get('/incidents/')
        assert res.status_code == 200

    def test_incidents_endpoint_includes_metadata(self, testapp):
        res = testapp.get('/incidents/')
        assert 'pagination' in res.json

    def test_incidents_endpoint_returns_incidents(self, testapp):
        res = testapp.get('/incidents/')
        assert len(res.json['results']) > 0
        assert 'incident_id' in res.json['results'][0]

    def test_incidents_endpoint_includes_offenses(self, testapp):
        res = testapp.get('/incidents/')
        for incident in res.json['results']:
            assert 'offenses' in incident
            if incident['offenses'] is not None:
                for offense in incident['offenses']:
                    assert 'offense_type' in offense
                    assert 'offense_name' in offense['offense_type']

    def test_incidents_endpoint_includes_ori(self, testapp):
        res = testapp.get('/incidents/')
        for incident in res.json['results']:
            assert 'agency' in incident
            assert 'ori' in incident['agency']

    @pytest.mark.xfail
    def test_incidents_endpoint_includes_counties(self, testapp):
        res = testapp.get('/incidents/')
        for incident in res.json['results']:
            agency = incident['agency']
            assert 'counties' in agency

    def test_incidents_endpoint_includes_locations(self, testapp):
        res = testapp.get('/incidents/')
        for incident in res.json['results']:
            assert 'offenses' in incident
            if incident['offenses'] is not None:
                for offense in incident['offenses']:
                    assert 'location' in offense
                    assert 'location_name' in offense['location']

    def test_incidents_endpoint_filters_offense_code(self, testapp):
        res = testapp.get('/incidents/?offense_code=35A')
        for incident in res.json['results']:
            assert 'offenses' in incident
            hits = [o for o in incident['offenses']
                    if o['offense_type']['offense_code'] == '35A']
            assert len(hits) > 0

    def test_incidents_endpoint_filters_method_entry_code(self, testapp):
        res = testapp.get('/incidents/?method_entry_code=N')
        for incident in res.json['results']:
            assert 'offenses' in incident
            hits = [o for o in incident['offenses']
                    if o['method_entry_code'] == 'N']
            assert len(hits) > 0

    def test_incidents_endpoint_filters_offense_code_plus_method_entry_code(
            self, testapp):
        res = testapp.get('/incidents/?offense_code=220&method_entry_code=F')
        for incident in res.json['results']:
            assert 'offenses' in incident
            hits = [o for o in incident['offenses']
                    if o['offense_type']['offense_code'] == '220' and o[
                        'method_entry_code'] == 'F']
            assert len(hits) > 0

    def test_incidents_endpoint_filters_location_code(self, testapp):
        res = testapp.get('/incidents/?location_code=22')
        for incident in res.json['results']:
            assert 'offenses' in incident
            if incident['offenses'] is not None:
                hits = [o for o in incident['offenses']
                        if o['location']['location_code'] == '22']
                assert len(hits) > 0

    def test_incidents_endpoint_filters_location_code_plus_offense_code(
            self, testapp):
        res = testapp.get('/incidents/?location_code=22&offense_code=13C')
        for incident in res.json['results']:
            assert 'offenses' in incident
            hits = [o for o in incident['offenses']
                    if o['location']['location_code'] == '22'
                    if o['offense_type']['offense_code'] == '13C']
            assert len(hits) > 0

    @pytest.mark.xfail  # TODO
    def test_incidents_endpoint_filters_offense_name_case_insensitive(
            self, testapp):
        res0 = testapp.get('/incidents/?offense_name=Intimidation')
        assert len(res0.json['results']) > 0
        res1 = testapp.get('/incidents/?offense_name=intimidation')
        assert len(res1.json['results']) == len(res0.json)

    @pytest.mark.xfail  # TODO
    def test_incidents_endpoint_filters_null_method_entry_code(self,
                                                               testapp):
        res = testapp.get('/incidents/?method_entry_code=None')
        assert len(res.json['results']) > 0
        for incident in res.json['results']:
            assert 'offenses' in incident
            hits = [o for o in incident['offenses']
                    if o['method_entry_code'] == 'F']
            assert len(hits) > 0

    def test_instances_endpoint_bad_filter_400s(self, testapp):
        res = testapp.get('/incidents/?llamas=angry', expect_errors=True)
        assert res.status_code == 400
        assert res.json['message'] == 'field llamas not found'

    def test_incidents_endpoint_filter_names_case_insensitive(self, testapp):
        res0 = testapp.get('/incidents/?Incident_Hour=22')
        assert res0.json['pagination']['count'] > 0
        res1 = testapp.get('/incidents/?incident_hour=22')
        assert res0.json['pagination']['count'] == res1.json['pagination']['count']

    def test_incidents_endpoint_filters_incident_hour(self, testapp):
        res = testapp.get('/incidents/?incident_hour=22')
        assert len(res.json['results']) > 0
        for incident in res.json['results']:
            assert incident['incident_hour'] == 22

    def test_incidents_endpoint_filters_incident_hour_greater_than(self, testapp):
        res = testapp.get('/incidents/?incident_hour>16')
        assert len(res.json['results']) > 0
        for incident in res.json['results']:
            assert incident['incident_hour'] > 16

    def test_incidents_endpoint_filters_location_name(self, testapp):
        res = testapp.get('/incidents/?location_name=Parking+Lot/Garage')
        assert len(res.json['results']) > 0
        for incident in res.json['results']:
            assert len(incident['offenses']) > 0
            hits = [o for o in incident['offenses'] if o['location']['location_name'] == 'Parking Lot/Garage']
            assert len(hits) > 0

    def test_incidents_endpoint_filters_victim_race_code(self, testapp):
        res = testapp.get('/incidents/?victim.race_code=B')
        assert len(res.json['results']) > 0
        for incident in res.json['results']:
            assert len(incident['victims']) > 0
            race_codes = [v['race_code'] for v in incident['victims']]
            assert 'B' in race_codes

    def test_incidents_endpoint_filters_victim_sex_code(self, testapp):
        res = testapp.get('/incidents/?victim.sex_code=F')
        assert len(res.json['results']) > 0
        for incident in res.json['results']:
            assert len(incident['victims']) > 0
            hits = [v for v in incident['victims'] if v['sex_code'] == 'F']
            assert len(hits) > 0

    def test_incidents_endpoint_filters_offender_age_num(self, testapp):
        res = testapp.get('/incidents/?offender.age_num>30')
        assert len(res.json['results']) > 0
        for incident in res.json['results']:
            assert len(incident['offenders']) > 0
            hits = [o for o in incident['offenders'] if o['age_num'] > 30]
            assert len(hits) > 0

    def test_incidents_endpoint_filters_arrestee_resident_code(self, testapp):
        res = testapp.get('/incidents/?arrestee.resident_code!=R')
        assert len(res.json['results']) > 0
        for incident in res.json['results']:
            assert len(incident['arrestees']) > 0
            hits = [a for a in incident['arrestees'] if a['resident_code'] != 'R']
            assert len(hits) > 0

    @pytest.mark.xfail
    def test_incidents_endpoint_filters_incident_date(self, testapp):
        res = testapp.get('/incidents/?incident_date>2014-06-01&incident_date<2014-06-30')
        assert len(res.json['results']) > 0
        for incident in res.json['results']:
            dt = dateutil.parser.parse(incident['incident_date'])
            assert dt > dateutil.parser.parse('2014-06-01T00:00+00:00')
            assert dt <= dateutil.parser.parse('2014-07-01T00:00+00:00')

    @pytest.mark.xfail
    def test_incidents_endpoint_filters_on_multiple_values(self, testapp):
        res = testapp.get('/incidents/?victim.race_code=A,I,P')
        assert len(res.json['results']) > 0
        for incident in res.json['results']:
            races = [v['race']['race_code'] for v in incident['victims']]
            assert ('A' in races) or ('I' in races) or ('P' in races)

    # # TODO: escaped commas
    @pytest.mark.xfail
    def test_incidents_endpoint_filters_on_multiple_values_with_brackets(self, testapp):
        res = testapp.get('/incidents/?victim.race_code={A,I,P}')
        assert len(res.json['results']) > 0
        for incident in res.json['results']:
            races = [v['race']['race_code'] for v in incident['victims']]
            assert ('A' in races) or ('I' in races) or ('P' in races)

    def test_incidents_endpoint_filter_with_spaces(self, testapp):
        for category_name in ('Larceny/Theft Offenses', 'Larceny/Theft+Offenses', 'Larceny/Theft%20Offenses'):
            res = testapp.get('/incidents/?offense_category_name=' + category_name)
            assert len(res.json['results']) > 0
            for incident in res.json['results']:
                offense_names = [o['offense_type']['offense_category_name'] for o in incident['offenses']]
                assert ('Larceny/Theft Offenses') in offense_names

    def test_incidents_endpoint_filter_with_parens(self, testapp):
        for population_family_desc in ('City (1-7)', 'City+(1-7)'):
            res = testapp.get('/incidents/?population_family_desc=' + population_family_desc)
            assert len(res.json['results']) > 0
            for incident in res.json['results']:
                assert incident['agency']['population_family']['population_family_desc'] == 'City (1-7)'

    def test_incidents_endpoint_filter_state(self, testapp):
        results = testapp.get('/incidents/?state=oh')
        for incident in results.json['results']:
            assert incident['agency']['state']['state_abbr'] == 'OH'

    @pytest.mark.xfail
    def test_incidents_endpoint_filter_county(self, testapp):
        results = testapp.get('/incidents/?county=warren')
        for incident in results.json['results']:
            county_names = [c['county_name'].lower() for c in incident['agency']['counties']]
            assert 'warren' in county_names

    # End filter tests

    @pytest.mark.xfail  # TODO
    def test_incidents_endpoint_filters_for_nulls(self, testapp):
        pass

    @pytest.mark.xfail   #TODO: this has messed up the paginator
    def test_incidents_paginate(self, testapp):
        page1 = testapp.get('/incidents/?page=1')
        page2 = testapp.get('/incidents/?page=2')
        assert len(page1.json['results']) == 10
        assert len(page2.json['results']) == 10
        assert page2.json['results'][0] not in page1.json['results']

    def test_incidents_pagination_data_in_metadata(self, testapp):
        page = testapp.get('/incidents/?page=3&per_page=7')
        assert page.json['pagination']['page'] == 3
        assert page.json['pagination']['per_page'] == 7
        assert 'count' in page.json['pagination']
        assert 'pages' in page.json['pagination']
        assert page.json['pagination']['pages'] > 1

    @pytest.mark.xfail  # TODO
    def test_incidents_pagination_beyond_end_fails_gracefully(self, testapp):
        page = testapp.get('/incidents/?state=DE&page=100000&per_page=1000')
        assert False

    @pytest.mark.xfail   #TODO: this has messed up the paginator
    def test_incidents_page_size(self, testapp):
        res = testapp.get('/incidents/?per_page=5')
        assert len(res.json['results']) == 5

    def _single_incident_id(self, testapp):
        res = testapp.get('/incidents/')
        return res.json['results'][0]['incident_id']

    def test_incidents_endpoint_single_record_works(self, testapp):
        id_no = self._single_incident_id(testapp)
        res = testapp.get('/incidents/{}/'.format(id_no))
        assert res.status_code == 200


class TestIncidentsCountEndpoint:
    def test_instances_count_exists(self, testapp):
        res = testapp.get('/incidents/count/')
        assert res.status_code == 200

    def test_incidents_count_endpoint_includes_metadata(self, testapp):
        res = testapp.get('/incidents/count/')
        assert 'pagination' in res.json

    def test_instances_count_returns_counts(self, testapp):
        res = testapp.get('/incidents/count/')
        assert isinstance(res.json['results'], list)
        assert 'actual' in res.json['results'][0]

    def test_instances_count_groups_by_year_by_default(self, testapp):
        res = testapp.get('/incidents/count/')
        years = [row['year'] for row in res.json['results']]
        assert len(years) == len(set(years))

    # def test_instances_count_groups_by_ori(self, testapp):
    #     res = testapp.get('/incidents/count/?by=ori')
    #     oris = [row['ori'] for row in res.json['results']]
    #     assert len(oris) == len(set(oris))

    # def test_instances_count_groups_by_ori_any_year(self, testapp):
    #     res = testapp.get('/incidents/count/?by=year')
    #     rows = [(row['year'], row['ori']) for row in res.json['results']]
    #     assert len(rows) == len(set(rows))

    def test_instances_count_groups_by_state(self, testapp):
        res = testapp.get('/incidents/count/?by=state')
        rows = [row['state'] for row in res.json['results']]
        assert len(rows) == len(set(rows))

    def test_instances_count_groups_by_offense(self, testapp):
        res = testapp.get('/incidents/count/?by=offense')
        rows = [row['offense'] for row in res.json['results']]
        assert len(rows) == len(set(rows))

    def test_instances_count_filter_by_explorer_offense(self, testapp):
        res = testapp.get('/incidents/count/?explorer_offense=larceny')
        rows = [row['offense'] for row in res.json['results']]
        assert len(rows) == len(set(rows))

    def test_instances_count_sorts_by_state(self, testapp):
        res = testapp.get('/incidents/count/?by=state')
        state_names = [r['state'] for r in res.json['results']]
        assert state_names == sorted(state_names)

    def test_instances_count_filters_on_subcategory(self, testapp):
        res = testapp.get('/incidents/count/?by=year,offense_subcat_code&offense_subcat_code=SUM_HOM')
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_subcat_code'] == 'SUM_HOM'

    def test_instances_count_filters_on_category(self, testapp):
        res = testapp.get('/incidents/count/?by=year,offense_category&offense_category=Robbery')
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_category'] == 'Robbery'

    # This is an intentional fail. We don't support city counts yet.
    @pytest.mark.xfail
    def test_instances_count_filters_on_city(self, testapp):
        res = testapp.get('/incidents/count/?by=city&city=columbus')
        assert res.json['results']
        for row in res.json['results']:
            assert row['city'] == 'Columbus'

    def test_instances_count_bad_filter_400s(self, testapp):
        res = testapp.get('/incidents/count/?llamas=angry', expect_errors=True)
        assert res.status_code == 400

    def test_instances_count_bad_group_by_400s(self, testapp):
        res = testapp.get('/incidents/count/?by=llamas', expect_errors=True)
        assert res.status_code == 400

    def test_instances_count_filter_names_case_insensitive(self, testapp):
        res = testapp.get('/incidents/count/?by=year,offense_category&offense_category=Robbery')
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_category'] == 'Robbery'

    def test_instances_count_filter_values_case_insensitive(self, testapp):
        res = testapp.get('/incidents/count/?by=year,offense_category&offense_category=RobBeRY')
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_category'] == 'Robbery'

    def test_instances_count_equality_filter_by_number(self, testapp):
        res = testapp.get('/incidents/count/?by=year,month&month=1')
        assert res.json['results']
        for row in res.json['results']:
            assert row['month'] == 1

    def test_instances_count_equality_filter_by_multiple_number(self, testapp):
        res = testapp.get('/incidents/count/?by=year,month&month=8,10')
        assert res.json['results']
        for row in res.json['results']:
            assert row['month'] in (8, 10)

    def test_instances_count_filters_by_greater_than(self, testapp):
        res = testapp.get('/incidents/count/?by=year,month&month>6')
        assert res.json['results']
        for row in res.json['results']:
            assert row['month'] > 6

    def test_instances_count_filters_by_less_than_or_equal_to(self, testapp):
        res = testapp.get('/incidents/count/?by=year,month&month<=3')
        assert res.json['results']
        for row in res.json['results']:
            assert row['month'] <= 3

    def test_instances_count_filters_by_less_than_or_equal_to(self, testapp):
        res = testapp.get('/incidents/count/?by=year,offense_category&offense_category!=Robbery&per_page=100')
        assert res.json['results']
        for row in res.json['results']:
            assert row['offense_category'] != 'Robbery'
    @pytest.mark.xfail
    def test_incidents_null_age_codes(self, testapp):
        res = testapp.get('/incidents/?victim.age_code=99')
        assert res.json['results']
        for row in res.json['results']:
            assert any(victim['age_num'] == 99 for victim in row['victims'])

    def test_incidents_filter_victim_rel(self, testapp):
        res = testapp.get('/incidents/?victim.relationship_code=AQ')
        assert res.json['results']

    def test_incidents_filter_weapon(self, testapp):
        res = testapp.get('/incidents/?offense.weapon_code=40')
        assert res.json['results']

    def test_instances_filter_criminal_act(self, testapp):
        res = testapp.get('/incidents/?offense.criminal_act_code=P')
        assert res.json['results']

    def test_instances_filter_injury(self, testapp):
        res = testapp.get('/incidents/?victim.injury_code=N')
        assert res.json['results']
