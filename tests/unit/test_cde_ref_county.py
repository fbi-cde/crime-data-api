from crime_data.common.cdemodels import CdeRefCounty

class TestCdeRefCounty:
    def test_get_by_id(self, testapp):
        s = CdeRefCounty.get(county_id=753).one()
        assert s.county_name == 'Kendall'

    def test_get_by_fips(self, testapp):
        s = CdeRefCounty.get(fips='06075').one()
        assert s.county_name == 'San Francisco'

    def test_get_by_name(self, testapp):
        s = CdeRefCounty.get(name='San FrANCIsco').one()
        assert s.county_name == 'San Francisco'

    def test_num_agencies(self, app):
        """Using the test data in the ref_agencies table"""

        county = CdeRefCounty.get(county_id=2402).one()
        assert county.total_agencies == 5

    def test_population(self, app):
        """Using the test data in the ref_county_population table"""

        county = CdeRefCounty.get(county_id=2402).one()
        assert county.total_population == 49251

    # Not sure we need this
    # def test_police_officers(self, app):
    #     """Using the test data in the database"""

    #     county = CdeRefCounty.get(county_id=2402).one()
    #     assert county.police_officers_for_year(2014) == 84

    # def test_police_officers_missing_data(self, app):

    #     county = CdeRefCounty.get(county_id=3015).one()
    #     assert county.police_officers_for_year(2021) is None
    #     assert county.police_officers is None
