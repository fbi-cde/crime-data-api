# -*- coding: utf-8 -*-


class TestIncidentsUnit:
    def test_incidents_list(self):
        from crime_data.resources.incidents import IncidentsList
        assert IncidentsList()

    def test_incidents_count(self):
        from crime_data.resources.incidents import IncidentsCount
        assert IncidentsCount()