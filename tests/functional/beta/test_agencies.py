# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""
from flex.core import validate_api_call

class TestAgenciesEndpoint:
    def test_agencies_endpoint_exists(self, testapp, swagger_beta):
        res = testapp.get('/agencies')
        assert res.status_code == 200
        validate_api_call(swagger_beta, raw_request=res.request, raw_response=res)

    def test_agencies_endpoint_returns_agencies(self, testapp, swagger_beta):
        res = testapp.get('/agencies')
        validate_api_call(swagger_beta, raw_request=res.request, raw_response=res)
        assert len(res.json['results']) > 0
        assert 'ori' in res.json['results'][0]
        assert 'city_name' in res.json['results'][0]

    def test_agencies_endpoint_fields_filtering(self, testapp, swagger_beta):
        res = testapp.get('/agencies?fields=ori,agency_name')
        validate_api_call(swagger_beta, raw_request=res.request, raw_response=res)
        assert len(res.json['results']) > 0
        assert 'ori' in res.json['results'][0]
        assert 'agency_name' in res.json['results'][0]
        assert 'city_name' not in res.json['results'][0]

    def _single_ori(self, testapp):
        res = testapp.get('/agencies')
        return res.json['results'][0]['ori']

    def test_agencies_endpoint_single_record_works(self, testapp, swagger_beta):
        id_no = self._single_ori(testapp)
        res = testapp.get('/agencies/{}'.format(id_no))
        assert res.status_code == 200
        validate_api_call(swagger_beta, raw_request=res.request, raw_response=res)

    def test_agencies_paginate(self, testapp, swagger_beta):
        page1 = testapp.get('/agencies?page=1')
        page2 = testapp.get('/agencies?page=2')
        assert len(page1.json['results']) == 10
        assert len(page2.json['results']) == 10
        assert page2.json['results'][0] not in page1.json['results']

    def test_agencies_page_size(self, testapp, swagger_beta):
        res = testapp.get('/agencies?per_page=5')
        validate_api_call(swagger_beta, raw_request=res.request, raw_response=res)
        assert len(res.json['results']) == 5

    def test_agencies_offenses(self, testapp, swagger_beta):
        res = testapp.get('/agencies/count/RI0040200/offenses?explorer_offense=robbery')
        validate_api_call(swagger_beta, raw_request=res.request, raw_response=res)
        assert len(res.json['results']) == 1

        result = res.json['results'][0]
        assert result['ori'] == 'RI0040200'
        assert result['offense_code'] == 'SUM_ROB'
        assert result['offense_name'] == 'Robbery'
        assert result['reported'] == 22
        assert result['actual'] == 22
        assert result['cleared'] == 12
        assert result['juvenile_cleared'] == 1

    def test_agencies_classification(self, testapp, swagger_beta):
        res = testapp.get('/agencies/count/RI0040200/offenses?explorer_offense=property')
        validate_api_call(swagger_beta, raw_request=res.request, raw_response=res)
        assert len(res.json['results']) == 1

        result = res.json['results'][0]
        assert result['ori'] == 'RI0040200'
        assert result['classification'] == 'Property'
        assert result['reported'] == 1595
        assert result['unfounded'] == 0
        assert result['actual'] == 1595
        assert result['cleared'] == 419
        assert result['juvenile_cleared'] == 43

    def test_agencies_arson(self, testapp, swagger_beta):
        res = testapp.get('/agencies/count/RI0010100/offenses?explorer_offense=arson')
        validate_api_call(swagger_beta, raw_request=res.request, raw_response=res)
        assert len(res.json['results']) == 1

        result = res.json['results'][0]
        assert result['pub_agency_name'] == 'Barrington Police Department'
        assert result['ori'] == 'RI0010100'
        assert result['offense_code'] == 'X_ARS'
        assert result['offense_name'] == 'Arson'
        assert result['reported'] == 1
        assert result['actual'] == 1
        assert result['cleared'] == 1
        assert result['juvenile_cleared'] == 0
