from flask.ext.sqlalchemy import Pagination
from sqlalchemy import func
from sqlalchemy.sql import label

from crime_data.common import models
from crime_data.extensions import db

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
    ''' ''

    # Maps API filter to DB column name.
    FILTER_COLUMN_MAP = {'state': 'state_abbr',
                         'offense': 'offense_subcat_name'}

    def get_nibrs_incident_by_ori(ori=None, filters=None):
        '''''
        Returns Query for Incident counts by Agency/ORI.
        ''' ''

        query = (CdeNibrsIncident.query.with_entities(
            label('count', func.count(CdeNibrsIncident.incident_id)),
            CdeRefAgency.ori, CdeRefAgency.agency_id).outerjoin(CdeRefAgency)
                 .group_by(CdeRefAgency.ori, CdeRefAgency.agency_id))

        if ori:
            query = query.filter(CdeRefAgency.ori == ori)

        # TODO: Apply all filters
        # for filter in filters:
        #     query = query.filter()

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
