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
    '''''
    Extends models.NibrsIncident.
    '''''

    # Maps API filter to DB column name.
    FILTER_COLUMN_MAP = {'state': 'state_abbr', 'offense': 'offense_subcat_name'}

    def get_nibrs_incident_by_ori(ori = None, filters = None, page= 1, per_page= 10):
        '''''
        Returns Query for Incident counts by Agency/ORI.
        '''''

        query = (CdeNibrsIncident
            .query
            .with_entities(
                func.count(CdeNibrsIncident.incident_id), 
                CdeRefAgency.ori, 
                CdeRefAgency.agency_id
            )
            .outerjoin(CdeRefAgency)
            .group_by(CdeRefAgency.ori, CdeRefAgency.agency_id)
        )

        if ori:
            query = query.filter(CdeRefAgency.ori==ori)

        # Apply all filters
        # for filter in filters:
        #     query = query.filter(getattr())

        # query = query.paginate(page, per_page)

        return query

