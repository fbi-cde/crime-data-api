from crime_data.common import models
from crime_data.extensions import db
from sqlalchemy import func

session = db.session

class CdeRefAgency(models.RefAgency):
    pass

class CdeNibrsMonth(models.NibrsMonth):
    pass

class CdeNibrsOffense(models.NibrsOffense):
    pass

class CdeNibrsIncident(models.NibrsIncident):

    def get_nibrs_incident_by_ori(ori = None, filters = None):
        '''''
        Returns Query for Incident counts by Agency/ORI.
        '''''

        query = (session
            .query(
                func.count(CdeNibrsIncident.incident_id), 
                CdeRefAgency.ori, 
                CdeRefAgency.agency_id
            )
            .join(CdeRefAgency)
            .group_by(CdeRefAgency.ori, CdeRefAgency.agency_id)
        )

        if ori:
            query = query.filter(CdeRefAgency.ori==ori)

        # Apply all filters
        # .....

        counts = query.all()

        return query

