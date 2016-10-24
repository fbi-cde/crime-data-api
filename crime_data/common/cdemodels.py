from crime_data.common import models

class CdeRefAgency(models.RefAgency):
    def hello(self):
        print("HEllo world")
        return

class CdeNibrsMonth(models.NibrsMonth):
    pass

class CdeNibrsIncident(models.NibrsIncident):
    pass

class CdeNibrsOffense(models.NibrsOffense):
    pass