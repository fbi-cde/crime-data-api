from crime_data.common import models
from crime_data.extensions import db
from sqlalchemy import func, and_

session = db.session

class CdeRetaMonth(models.RetaMonth):
    pass

class CdeRefState(models.RefState):
    pass

class CdeRetaOffense(models.RetaOffense):
    pass
class CdeRetaMonthOffenseSubcat(models.RetaMonthOffenseSubcat):
    pass

class CdeRetaOffenseSubcat(models.RetaOffenseSubcat):
    pass

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

    def get_nibrs_incident_by_ori(ori = None, filters = None):
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

        # TODO: Apply all filters
        # for filter in filters:
        #     query = query.filter()

        return query

    def get_reta_by_ori(ori = None, filters = None):
        '''''
        Returns Query for RETA counts by Agency/ORI - Monthly Sums.
        '''''

        # Aggregation by: (Year, Month, OffenseSubcategory)
        sums = (CdeRetaMonth
            .query
            .with_entities(
                func.sum(CdeRetaMonth.total_actual_count).label('total_count'), 
                CdeRetaMonth.data_year,
                CdeRetaMonth.month_num,
                CdeRetaMonth.agency_id,
                CdeRetaMonthOffenseSubcat.offense_subcat_id,
            )
            .join(CdeRetaMonthOffenseSubcat, CdeRetaMonth.reta_month_id == CdeRetaMonthOffenseSubcat.reta_month_id)
            .group_by(CdeRetaMonth.agency_id, CdeRetaMonth.data_year, CdeRetaMonth.month_num, CdeRetaMonthOffenseSubcat.offense_subcat_id)
        ).subquery()

        # Get Aggregated data, and attach along all relevent metadata.
        query = (CdeRetaMonthOffenseSubcat
            .query
            .with_entities(
                sums.columns.total_count,
                sums.columns.month_num,
                sums.columns.data_year,
                CdeRefAgency.ori,
                CdeRefAgency.state_id,
                CdeRetaMonthOffenseSubcat.offense_subcat_id,
                CdeRefState.state_abbr,
                CdeRetaOffenseSubcat.offense_subcat_name,
                CdeRetaOffenseSubcat.offense_subcat_code,
                CdeRetaOffense.offense_id,
            )
            .join(CdeRefAgency, sums.columns.agency_id == CdeRefAgency.agency_id)
            .join(CdeRefState, CdeRefAgency.state_id == CdeRefState.state_id)
            .join(CdeRetaOffenseSubcat)
            .join(CdeRetaOffense, CdeRetaOffenseSubcat.offense_id == CdeRetaOffense.offense_id)
        )

        # Get ONE ORI.
        if ori:
            query = query.filter(CdeRefAgency.ori==ori)

        # TODO: Apply all filters
        # for filter in filters:
        #     query = query.filter()

        return query


