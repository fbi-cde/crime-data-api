import datetime
from decimal import Decimal

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

    OPERATION = func.sum
    seed_label = None
    seed_agg = func.sum

    def _sql_name(self, readable_name):
        return self.COL_NAME_MAP.get(readable_name, readable_name)

    def _col(self, readable_name):
        for tbl in self.tables:
            try:
                result = getattr(tbl, self._sql_name(readable_name))
                return result
            except AttributeError:
                pass  # keep looking
        raise AttributeError()

    def _add_column(self, readable_name, operation=None):
        col = self._col(readable_name)
        if operation:
            col = operation(col)
        self.qry = self.qry.add_columns(label(readable_name, col))

    def _base_query(self):
        tbl = self.tables[0]
        col = getattr(tbl, self.seed_col)
        lbl = self.seed_label or self.seed_col
        labelled = label(lbl, self.seed_agg(col))
        return db.session.query(labelled)

    def _can_aggregate(self, col_name, aggregate):
        col = self._col(col_name)
        types = [c.type.python_type for c in col.prop.columns]
        if types in ([int, ], [float, ], [Decimal, ]):
            return True
        if (types in ([datetime.datetime, ], [datetime.date, ]) and
                aggregate in (func.min, func.max)):
            return True
        return False

    def __init__(self, aggregated=None, grouped=None):
        if grouped in (['none', None]):
            grouped = []
        aggregated = aggregated or []
        self.qry = self._base_query()
        for tbl in self.tables[1:]:
            self.qry = self.qry.join(tbl)
        for col in aggregated:
            if not isinstance(col, str):
                (col, operation) = col
            else:
                operation = self.OPERATION
            if self._can_aggregate(col, operation):
                self._add_column(col, operation)
            else:
                grouped.append(col)
        for col_name in grouped:
            self._add_column(col_name)
            col = self._col(col_name)
            self.qry = self.qry.group_by(col).order_by(col)

    def paginate(self, page, per_page):
        paginated = self.qry.limit(per_page).offset((page - 1) * per_page)
        return Pagination(self.qry,
                          page=page,
                          per_page=per_page,
                          total=self.qry.count(),
                          items=paginated)


class RetaMonthQuery(QueryWithAggregates):

    COL_NAME_MAP = {'year': 'data_year',
                    'state': 'state_abbr',
                    'offense': 'offense_subcat_name'}
    tables = [models.RetaMonth, CdeRefAgency, models.RefState,
              models.RetaMonthOffenseSubcat, models.RetaOffenseSubcat]
    seed_col = 'total_actual_count'
