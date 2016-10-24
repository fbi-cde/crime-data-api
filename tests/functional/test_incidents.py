# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
import pytest


class TestIncidentsEndpoint:
    def test_incidents_endpoint_exists(self, user, testapp):
        res = testapp.get('/incidents/')
        assert res.status_code == 200

    def test_incidents_endpoint_includes_metadata(self, user, testapp):
        res = testapp.get('/incidents/')
        assert 'pagination' in res.json
        
    def test_incidents_endpoint_returns_incidents(self, user, testapp):
        res = testapp.get('/incidents/')
        assert len(res.json['results']) > 0
        assert 'incident_number' in res.json['results'][0]

    def test_incidents_endpoint_includes_offenses(self, user, testapp):
        res = testapp.get('/incidents/')
        for incident in res.json['results']:
            assert 'offenses' in incident
            for offense in incident['offenses']:
                assert 'offense_type' in offense
                assert 'offense_name' in offense['offense_type']

    def test_incidents_endpoint_includes_ori(self, user, testapp):
        res = testapp.get('/incidents/')
        for incident in res.json['results']:
            assert 'agency' in incident
            assert 'ori' in incident['agency']

    def test_incidents_endpoint_includes_locations(self, user, testapp):
        res = testapp.get('/incidents/')
        for incident in res.json['results']:
            assert 'offenses' in incident
            for offense in incident['offenses']:
                assert 'location' in offense
                assert 'location_name' in offense['location']

    def test_incidents_endpoint_filters_offense_code(self, user, testapp):
        res = testapp.get('/incidents/?offense_code=35A')
        for incident in res.json['results']:
            assert 'offenses' in incident
            hits = [o for o in incident['offenses']
                    if o['offense_type']['offense_code'] == '35A']
            assert len(hits) > 0

    def test_incidents_endpoint_filters_method_entry_code(self, user, testapp):
        res = testapp.get('/incidents/?method_entry_code=N')
        for incident in res.json['results']:
            assert 'offenses' in incident
            hits = [o for o in incident['offenses']
                    if o['method_entry_code'] == 'N']
            assert len(hits) > 0

    def test_incidents_endpoint_filters_offense_code_plus_method_entry_code(
            self, user, testapp):
        res = testapp.get('/incidents/?offense_code=220&method_entry_code=F')
        for incident in res.json['results']:
            assert 'offenses' in incident
            hits = [o for o in incident['offenses']
                    if o['offense_type']['offense_code'] == '220' and o[
                        'method_entry_code'] == 'F']
            assert len(hits) > 0

    def test_incidents_endpoint_filters_location_code(self, user, testapp):
        res = testapp.get('/incidents/?location_code=22')
        for incident in res.json['results']:
            assert 'offenses' in incident
            hits = [o for o in incident['offenses']
                    if o['location']['location_code'] == '22']
            assert len(hits) > 0

    def test_incidents_endpoint_filters_location_code_plus_offense_code(
            self, user, testapp):
        res = testapp.get('/incidents/?location_code=22&offense_code=13C')
        for incident in res.json['results']:
            assert 'offenses' in incident
            hits = [o for o in incident['offenses']
                    if o['location']['location_code'] == '22'
                    if o['offense_type']['offense_code'] == '13C']
            assert len(hits) > 0

    @pytest.mark.xfail  # TODO
    def test_incidents_endpoint_filters_offense_name_case_insensitive(
            self, user, testapp):
        res0 = testapp.get('/incidents/?offense_name=Intimidation')
        assert len(res0.json['results']) > 0
        res1 = testapp.get('/incidents/?offense_name=intimidation')
        assert len(res1.json['results']) == len(res0.json)

    @pytest.mark.xfail  # TODO
    def test_incidents_endpoint_filters_null_method_entry_code(self, user,
                                                               testapp):
        res = testapp.get('/incidents/?method_entry_code=None')
        assert len(res.json['results']) > 0
        for incident in res.json['results']:
            assert 'offenses' in incident
            hits = [o for o in incident['offenses']
                    if o['method_entry_code'] == 'F']
            assert len(hits) > 0

    def test_incidents_endpoint_filters_incident_hour(self, user, testapp):
        res = testapp.get('/incidents/?incident_hour=22')
        assert len(res.json['results']) > 0
        for incident in res.json['results']:
            assert incident['incident_hour'] == 22

    def test_incidents_paginate(self, user, testapp):
        page1 = testapp.get('/incidents/?page=1')
        page2 = testapp.get('/incidents/?page=2')
        assert len(page1.json['results']) == 10
        assert len(page2.json['results']) == 10
        assert page2.json['results'][0] not in page1.json['results']
        
    def test_incidents_pagination_data_in_metadata(self, user, testapp):
        page = testapp.get('/incidents/?page=3&per_page=7')
        assert page.json['pagination']['page'] == 3 
        assert page.json['pagination']['per_page'] == 7 
        assert 'count' in page.json['pagination'] 
        assert 'pages' in page.json['pagination'] 
        assert page.json['pagination']['pages'] > 1 

    @pytest.mark.xfail  # TODO 
    def test_incidents_pagination_beyond_end_fails_gracefully(self, user, testapp):
        page = testapp.get('/incidents/?state=DE&page=100000&per_page=1000')
        assert False 
   
    def test_incidents_page_size(self, user, testapp):
        res = testapp.get('/incidents/?per_page=5')
        assert len(res.json['results']) == 5

    def _single_incident_number(self, testapp):
        res = testapp.get('/incidents/')
        return res.json['results'][0]['incident_number']

    def test_incidents_endpoint_single_record_works(self, user, testapp):
        id_no = self._single_incident_number(testapp)
        res = testapp.get('/incidents/{}/'.format(id_no))
        assert res.status_code == 200


class TestIncidentsCountEndpoint:
    def test_instances_count_exists(self, testapp):
        res = testapp.get('/incidents/count/')
        assert res.status_code == 200

    def test_instances_count_returns_counts(self, testapp):
        res = testapp.get('/incidents/count/')
        assert isinstance(res.json, list)
        assert 'total_actual_count' in res.json[0]

    def test_instances_count_groups_by_year_by_default(self, testapp):
        res = testapp.get('/incidents/count/')
        years = [row['year'] for row in res.json]
        assert len(years) == len(set(years))

    def test_instances_count_groups_by_agency_id(self, testapp):
        res = testapp.get('/incidents/count/?by=agency_id')
        agency_ids = [row['agency_id'] for row in res.json]
        assert len(agency_ids) == len(set(agency_ids))

    def test_instances_count_groups_by_agency_id_any_year(self, testapp):
        res = testapp.get('/incidents/count/?by=agency_id,year')
        rows = [(row['year'], row['agency_id']) for row in res.json]
        assert len(rows) == len(set(rows))

    def test_instances_count_groups_by_state(self, testapp):
        res = testapp.get('/incidents/count/?by=state')
        rows = [row['state'] for row in res.json]
        assert len(rows) == len(set(rows))

    def test_instances_count_groups_by_offense(self, testapp):
        res = testapp.get('/incidents/count/?by=offense')
        rows = [row['offense'] for row in res.json]
        assert len(rows) == len(set(rows))

    def test_instances_count_shows_fields_in_month(self, testapp):
        res = testapp.get('/incidents/count/?fields=leoka_felony')
        for row in res.json:
            assert 'leoka_felony' in row

    def test_instances_count_sorts_by_state(self, testapp):
        res = testapp.get('/incidents/count/?by=state')
        state_names = [r['state'] for r in res.json]
        assert state_names == sorted(state_names)
