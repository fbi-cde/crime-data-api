from crime_data.common.lookupmodels import (StateLK, RegionLK)
import pytest

class TestLookup:
    def test_for_state_lookup(self, app):
        q = StateLK.query
        q = q.count()
        assert q == 58

    def test_for_region_lookup(self, app):
        q = RegionLK.query
        q = q.count()
        assert q == 6
