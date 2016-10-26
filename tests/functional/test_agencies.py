# -*- coding: utf-8 -*-
"""Functional tests using WebTest.

See: http://webtest.readthedocs.org/
"""

class TestAgenciesEndpoint:
    def test_agencies_endpoint_exists(self, user, testapp):
        res = testapp.get('/agencies/')
        assert res.status_code == 200

    def test_agencies_endpoint_returns_agencies(self, user, testapp):
        res = testapp.get('/agencies/')
        assert len(res.json['results']) > 0
        assert 'ori' in res.json['results'][0]

    def _single_ori(self, testapp):
        res = testapp.get('/agencies/')
        return res.json['results'][0]['ori']

    def test_agencies_endpoint_single_record_works(self, user, testapp):
        id_no = self._single_ori(testapp)
        res = testapp.get('/agencies/{}/'.format(id_no))
        assert res.status_code == 200

    def test_agencies_paginate(self, user, testapp):
        page1 = testapp.get('/agencies/?page=1')
        page2 = testapp.get('/agencies/?page=2')
        assert len(page1.json['results']) == 10
        assert len(page2.json['results']) == 10
        assert page2.json['results'][0] not in page1.json['results']

    def test_agencies_page_size(self, user, testapp):
        res = testapp.get('/agencies/?per_page=5')
        assert len(res.json['results']) == 5

    def test_agencies_incident_counts_page_size(self, user, testapp):
        res = testapp.get('/agencies/nibrs/count/?per_page=5')
        assert len(res.json['results']) == 5

    def test_agencies_incident_counts_paginate(self, user, testapp):
        page2 = testapp.get('/agencies/nibrs/count/?page=2')
        assert len(page2.json['results']) == 10
        page1 = testapp.get('/agencies/nibrs/count/?page=1')
        assert len(page1.json['results']) == 10
        assert page2.json['results'][0] not in page1.json['results']
