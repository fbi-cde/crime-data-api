from flask.ext.sqlalchemy import Pagination
from sqlalchemy import func
from sqlalchemy.sql import label

from crime_data.common import models
from crime_data.extensions import db
from sqlalchemy import func, and_

session = db.session

class CdeRefState(models.RefState):
    pass

class CdeRefCity(models.RefCity):
    pass

class CdeRetaOffense(models.RetaOffense):
    pass
    
class CdeRetaMonthOffenseSubcat(models.RetaMonthOffenseSubcat):
    pass

class CdeRetaOffenseSubcat(models.RetaOffenseSubcat):
    pass

class CdeRefAgency(models.RefAgency):
    pass

class CdeNibrsEthnicity(models.NibrsEthnicity):
    pass

class CdeNibrsVictim(models.NibrsVictim):
    pass

class CdeNibrsOffender(models.NibrsOffender):
    pass

class CdeNibrsMonth(models.NibrsMonth):
    pass


class CdeNibrsOffense(models.NibrsOffense):
    pass

class CdeNibrsLocationType(models.NibrsLocationType):
    pass

class CdeNibrsIncident(models.NibrsIncident):
    '''''
    Extends models.NibrsIncident.
    '''''

    @staticmethod
    def __get_fields(agg_fields, fields):
        requested_fields = []
        for field in fields:
            if field in CdeNibrsIncident.get_filter_map():
                requested_fields.append(CdeNibrsIncident.get_filter_map()[field])
        
        requested_fields += agg_fields
        return requested_fields

    @staticmethod
    def __apply_filters(query, filters):
        for filter,value in filters.items():
            if filter in CdeNibrsIncident.get_filter_map():
                query = query.filter(CdeNibrsIncident.get_filter_map()[filter] == value)
        return query

    @staticmethod
    def __apply_group_by(query, group_bys):
        for group in group_bys:
            if group in CdeNibrsIncident.get_filter_map():
                query = query.group_by(CdeNibrsIncident.get_filter_map()[group]).order_by(CdeNibrsIncident.get_filter_map()[group])
        return query


    # Maps API filter to DB column name.
    @staticmethod
    def get_filter_map():
        return {'state': CdeRefState.state_abbr,
        'city': CdeRefCity.city_name,
        'month':CdeNibrsMonth.month_num,
        'year':CdeNibrsMonth.data_year,
        'ori': CdeRefAgency.ori,
        'offense_location': CdeNibrsLocationType.location_name,
        'victim_ethnicity': CdeNibrsEthnicity.ethnicity_name.label('victim_ethnicity'),
        'offender_ethnicity': CdeNibrsEthnicity.ethnicity_name.label('offender_ethnicity') }

    @staticmethod
    def get_nibrs_incident_by_ori(ori = None, filters = None, by = None):
        '''''
        Returns Query for RETA counts by Agency/ORI - Monthly Sums.
        '''''

        agg_fields = [
            func.count(CdeNibrsIncident.incident_id).label('incident_count')
        ]

        fields = CdeNibrsIncident.__get_fields(agg_fields, by)

        # Base Query
        query = CdeNibrsIncident.query

        # Get ONE ORI.
        # if ori:
        #     query = query.filter(CdeRefAgency.ori==ori)
        
        # Apply JOINS.
        query = (query
             .join(CdeNibrsOffense)
             .join(CdeNibrsLocationType)
             .outerjoin(CdeNibrsMonth)
             .outerjoin(CdeRefAgency)
             .outerjoin(CdeRefCity)
             .outerjoin(CdeRefState)
             )

        if 'victim_ethnicity' in by or 'offender_ethnicity' in by:
            if 'victim_ethnicity' in by:
                query = (query.outerjoin(CdeNibrsVictim))
            if 'offender_ethnicity' in by:
                query = (query.outerjoin(CdeNibrsOffender))
            query = query.outerjoin(CdeNibrsEthnicity)

        # Apply field selections.
        query = query.with_entities(*fields)

        # Apply group by.
        query = CdeNibrsIncident.__apply_group_by(query, by)

        # Apply all filters
        query = CdeNibrsIncident.__apply_filters(query, filters)

        return query


class CdeRetaMonth(models.RetaMonth):

    @staticmethod
    def __get_fields(agg_fields, fields):
        requested_fields = []
        for field in fields:
            if field in CdeRetaMonth.get_filter_map():
                requested_fields.append(CdeRetaMonth.get_filter_map()[field])
        
        requested_fields += agg_fields
        return requested_fields

    @staticmethod
    def __apply_filters(query, filters):
        for filter,value in filters.items():
            if filter in CdeRetaMonth.get_filter_map():
                query = query.filter(CdeRetaMonth.get_filter_map()[filter] == value)
        return query

    @staticmethod
    def __apply_group_by(query, group_bys):
        for group in group_bys:
            if group in CdeRetaMonth.get_filter_map():
                query = query.group_by(CdeRetaMonth.get_filter_map()[group]).order_by(CdeRetaMonth.get_filter_map()[group])
        return query


    # Maps API filter to DB column name.
    @staticmethod
    def get_filter_map():
        return {'state': CdeRefState.state_abbr, 
        'offense': CdeRetaOffense.offense_name,
        'ori': CdeRefAgency.ori,
        'subcategory': CdeRetaOffenseSubcat.offense_subcat_name,
        'agency_name': CdeRefAgency.pub_agency_name, # Assuming Public Agency Name is the best one.
        'city': CdeRefCity.city_name,
        'year': CdeRetaMonth.data_year,
        'month': CdeRetaMonth.month_num }

    @staticmethod
    def get_reta_by_ori(ori = None, filters = None, by = None):
        '''''
        Returns Query for RETA counts by Agency/ORI - Monthly Sums.
        '''''

        agg_fields = [
            func.sum(CdeRetaMonthOffenseSubcat.actual_count).label('actual_count'),
            func.sum(CdeRetaMonthOffenseSubcat.reported_count).label('reported_count'),
            func.sum(CdeRetaMonthOffenseSubcat.unfounded_count).label('unfounded_count'),
            func.sum(CdeRetaMonthOffenseSubcat.cleared_count).label('cleared_count'),
            func.sum(CdeRetaMonthOffenseSubcat.juvenile_cleared_count).label('juvenile_cleared_count'),
        ]

        fields = CdeRetaMonth.__get_fields(agg_fields, by)

        # Base Query
        query = CdeRetaMonth.query

        # Get ONE ORI.
        # if ori:
        #     query = query.filter(CdeRefAgency.ori==ori)
        
        # Apply JOINS.
        query = (query.join(CdeRetaMonthOffenseSubcat)
             .outerjoin(CdeRefAgency)
             .outerjoin(CdeRefCity)
             .outerjoin(CdeRefState)
             .join(CdeRetaOffenseSubcat)
             .join(CdeRetaOffense))
        
        # Apply field selections.
        query = query.with_entities(*fields)

        # Apply group by.
        query = CdeRetaMonth.__apply_group_by(query, by)

        # Apply all filters
        query = CdeRetaMonth.__apply_filters(query, filters)

        return query


class QueryWithAggregates(object):
    def _sql_name(self, readable_name):
        return self.COL_NAME_MAP.get(readable_name, readable_name)

    def _col(self, readable_name, operation=None):
        """Find column named `readable_name` in `self.tables`, return it labelled"""
        for tbl in self.tables:
            try:
                col = getattr(tbl, self._sql_name(readable_name))
            except AttributeError:
                continue
            if operation:
                col = operation(col)
            return label(readable_name, col)
        raise AttributeError()

    def __init__(self, by=None):
        self.qry = self._base_query()
        if by in (['none', None]):
            by = []
        for col_name in by:
            col = self._col(col_name)
            self.qry = self.qry.add_columns(col)
            self.qry = self.qry.group_by(col).order_by(col)

    def paginate(self, page, per_page):
        paginated = self.qry.limit(per_page).offset((page - 1) * per_page)
        return Pagination(self.qry,
                          page=page,
                          per_page=per_page,
                          total=self.qry.count(),
                          items=paginated)


class RetaQuery(QueryWithAggregates):

    COL_NAME_MAP = {'year': 'data_year',
                    'month': 'month_num',
                    'agency_name': 'ucr_agency_name',
                    'state': 'state_abbr',
                    'city': 'city_name',
                    'tribe': 'tribe_name',
                    'offense': 'offense_name',
                    'offense_subcat': 'offense_subcat_name',
                    'offense_category': 'offense_category_name', }
    tables = [models.RetaMonthOffenseSubcat, models.RetaMonth, CdeRefAgency,
              models.RefCity, models.RefState, models.RefTribe,
              models.RetaOffenseSubcat, models.RetaOffense,
              models.RetaOffenseCategory]
    aggregated = ('actual_count',
                  'reported_count',
                  'unfounded_count',
                  'cleared_count',
                  'juvenile_cleared_count', )

    def _base_query(self, operation=func.sum):
        sum_cols = [self._col(c, operation) for c in self.aggregated]
        qry = db.session.query(sum_cols[0])
        for col in sum_cols[1:]:
            qry = qry.add_columns(col)
        qry = qry.join(models.RetaOffenseSubcat).join(models.RetaOffense).join(
            models.RetaOffenseCategory)
        qry = qry.join(models.RetaMonth).join(models.RefAgency).join(
            models.RefCity,
            isouter=True)
        qry = qry.join(models.RefState,
                       models.RefAgency.state_id == models.RefState.state_id,
                       isouter=True)
        qry = qry.join(models.RefTribe,
                       models.RefAgency.tribe_id == models.RefTribe.tribe_id,
                       isouter=True)
        return qry
