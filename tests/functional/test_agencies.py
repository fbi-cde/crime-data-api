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
        assert len(res.json) > 0
        assert 'ori' in res.json[0]

    def _single_ori(self, testapp):
        res = testapp.get('/agencies/')
        return res.json[0]['ori']

    def test_agencies_endpoint_single_record_works(self, user, testapp):
        id_no = self._single_ori(testapp)
        res = testapp.get('/agencies/{}/'.format(id_no))
        assert res.status_code == 200

    def test_agencies_paginate(self, user, testapp):
        page1 = testapp.get('/agencies/?page=1')
        page2 = testapp.get('/agencies/?page=2')
        assert len(page1.json) == 10
        assert len(page2.json) == 10
        assert page2.json[0] not in page1.json

    def test_agencies_page_size(self, user, testapp):
        res = testapp.get('/agencies/?page_size=5')
        assert len(res.json) == 5
