from crime_data.common.newmodels import (AgencyParticipation, ParticipationRate)
import pytest

class TestAgencyParticipation:
    def test_for_agency_not_reporting(self, app):
        q = AgencyParticipation.query
        q = q.filter(AgencyParticipation.year == 2014)
        q = q.filter(AgencyParticipation.agency_id == 17380).one()
        assert q.reported == 0
        assert q.months_reported == 0
        assert q.nibrs_reported == 0
        assert q.nibrs_months_reported == 0

    def test_for_agency_covered_by_another(self, app):
        q = AgencyParticipation.query
        q = q.filter(AgencyParticipation.year == 2014)
        q = q.filter(AgencyParticipation.agency_id == 17391).one()
        assert q.reported == 0
        assert q.months_reported == 0
        assert q.nibrs_reported == 0
        assert q.nibrs_months_reported == 0
        assert q.covered == 1
        assert q.participated == 1
        assert q.nibrs_participated == 1

    def test_for_agency_in_nibrs_month(self, app):
        q = AgencyParticipation.query
        q = q.filter(AgencyParticipation.year == 2014)
        q = q.filter(AgencyParticipation.agency_id == 17381).one()
        assert q.reported == 1
        assert q.months_reported == 12
        assert q.nibrs_reported == 1
        assert q.nibrs_months_reported == 12

    def test_for_agency_not_in_nibrs_month(self, app):
        q = AgencyParticipation.query
        q = q.filter(AgencyParticipation.year == 2014)
        q = q.filter(AgencyParticipation.agency_id == 17427).one()
        assert q.reported == 1
        assert q.months_reported == 12
        assert q.nibrs_reported == 0
        assert q.nibrs_months_reported == 0


class TestParticipationRate:
    def test_for_state_in_year(self, app):
        q = ParticipationRate.query
        q = q.filter(ParticipationRate.year == 2014)
        q = q.filter(ParticipationRate.state_id == 44).one()
        assert q.year == 2014
        assert q.state_id == 44
        assert q.total_agencies == 62
        assert q.participating_agencies == 54
        assert q.participation_rate == pytest.approx(0.870967742)
        assert q.nibrs_participating_agencies == 52
        assert q.nibrs_participation_rate == pytest.approx(0.838709677)

    def test_for_county_in_year(self, app):
        pass
        q = ParticipationRate.query
        q = q.filter(ParticipationRate.year == 2014)
        q = q.filter(ParticipationRate.state_id == 44).one()
        assert q.year == 2014
        assert q.state_id == 44
        assert q.total_agencies == 62
        assert q.participating_agencies == 54
        assert q.participation_rate == pytest.approx(0.870967742)
        assert q.nibrs_participating_agencies == 52
        assert q.nibrs_participation_rate == pytest.approx(0.838709677)

    def test_for_year(self, app):
        q = ParticipationRate.query
        q = q.filter(ParticipationRate.year == 2014)
        q = q.filter(ParticipationRate.state_id == None)
        q = q.filter(ParticipationRate.county_id == None).one()
        assert q.year == 2014
        assert q.state_id is None
        assert q.total_agencies == 64
        assert q.participating_agencies == 54
        assert q.participation_rate == pytest.approx(0.84375)
        assert q.nibrs_participating_agencies == 52
        assert q.nibrs_participation_rate == pytest.approx(0.8125)
        assert q.total_population == 12142430
        assert q.participating_population == 1055173
