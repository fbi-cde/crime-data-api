# -*- coding: utf-8 -*-

from crime_data.common.cdemodels import CdeRefState, CdeRefCounty
import pytest

class TestCdeRefState:
    def test_get_by_id(self, testapp):
        s = CdeRefState.get(state_id=12).one()
        assert s.state_name == 'Florida'

    def test_get_by_abbr(self, testapp):
        s = CdeRefState.get(abbr='NE').one()
        assert s.state_name == 'Nebraska'

    def test_get_by_fips(self, testapp):
        s = CdeRefState.get(fips='06075').one()
        assert s.state_name == 'California'


class TestCdeRefCounty:
    def test_get_by_id(self, testapp):
        s = CdeRefCounty.get(county_id=123).one()
        assert s.county_name == 'DREW'

    def test_get_by_fips(self, testapp):
        s = CdeRefCounty.get(fips='06075').one()
        assert s.county_name == 'SAN FRANCISCO'

        with pytest.raises(ValueError):
            CdeRefCounty.get(fips='6075')

        with pytest.raises(ValueError):
            CdeRefCounty.get(fips=6075)

    def test_get_by_name(self, testapp):
        s = CdeRefCounty.get(name='San Francisco').one()
        assert s.county_name == 'SAN FRANCISCO'

    def test_fips_property(self, testapp):
        state = CdeRefState(state_fips_code='02')
        county = CdeRefCounty(county_fips_code='343', state=state)
        assert county.fips == '02343'

        county = CdeRefCounty(county_fips_code='7', state=state)
        assert county.fips == '02007'
