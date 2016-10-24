from crime_data.common import models

class cdeRefAgency(models.RefAgency):
    def hello(self):
        print("HEllo world")
        return

class cdeNibrsMonth(models.NibrsMonth):
    pass

class cdeNibrsIncident(models.NibrsIncident):
    pass
    
class cdeNibrsOffense(models.NibrsOffense):
    pass