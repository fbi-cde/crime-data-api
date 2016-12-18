import json
import math
import os
import random
from decimal import Decimal
from functools import wraps

import sqltap
from flask import make_response, request
from flask_apispec.views import MethodResource
from flask_restful import abort, current_app
# import celery
from flask_sqlalchemy import SignallingSession, SQLAlchemy
from sqlalchemy import func, or_

from crime_data.extensions import db

session = db.session


COUNT_QUERY_THRESHOLD = 1000

def tuning_page(f):
    @wraps(f)
    def decorated_get(*args, **kwargs):
        if 'tuning' in args[1] and args[1]['tuning']:
            if not current_app.config['DEBUG']:
                abort(403, message="`DEBUG` must be on for tuning page")
            profiler = sqltap.start()
            result = f(*args, **kwargs)
            profiler.stop()
            stats = profiler.collect()
            return make_response(sqltap.report(stats, 'tuning.html'))
        result = f(*args, **kwargs)
        return result

    return decorated_get


def tuning_page_kwargs(f):
    @wraps(f)
    def decorated_get(*args, **kwargs):
        if 'tuning' in kwargs and kwargs['tuning']:
            if not current_app.config['DEBUG']:
                abort(403, message="`DEBUG` must be on for tuning page")
            profiler = sqltap.start()
            result = f(*args, **kwargs)
            profiler.stop()
            stats = profiler.collect()
            return make_response(sqltap.report(stats, 'tuning.html'))
        result = f(*args, **kwargs)
        return result

    return decorated_get


class RoutingSession(SignallingSession):
    """Route requests to database leader or follower as appropriate.
    Based on http://techspot.zzzeek.org/2012/01/11/django-style-database-routers-in-sqlalchemy/
    """

    @property
    def followers(self):
        return self.app.config['SQLALCHEMY_FOLLOWERS']

    @property
    def follower_tasks(self):
        return self.app.config['SQLALCHEMY_FOLLOWER_TASKS']

    @property
    def restrict_follower_traffic_to_tasks(self):
        return self.app.config['SQLALCHEMY_RESTRICT_FOLLOWER_TRAFFIC_TO_TASKS']

    @property
    def use_follower(self):
        # Check for read operations and configured followers.
        use_follower = (not self._flushing and self.followers)

        # Optionally restrict traffic to followers for only supported tasks.
        # if use_follower and self.restrict_follower_traffic_to_tasks:
        #     use_follower = (
        #         celery.current_task and
        #         celery.current_task.name in self.follower_tasks
        #     )

        return use_follower

    def get_bind(self, mapper=None, clause=None):
        if self.use_follower:
            return random.choice(self.followers)

        return super().get_bind(mapper=mapper, clause=clause)


class QueryTraits(object):
    @classmethod
    def get_fields(cls, agg_fields, fields):
        """Builds the query's SELECT clause.
        Returns list of fields.
        """
        requested_fields = []
        for field in fields:
            if field in cls.get_filter_map():
                requested_fields.append(cls.get_filter_map()[field])

        requested_fields += agg_fields
        return requested_fields

    @classmethod
    def apply_group_by(cls, query, group_bys):
        """ Builds the query's GROUP BY clause.
        For Aggregations, the group by clause will
        contain all output fields. Returns query object.
        """
        for group in group_bys:
            if group in cls.get_filter_map():
                query = (query.group_by(cls.get_filter_map()[group])
                         .order_by(cls.get_filter_map()[group]))
        return query

    @classmethod
    def apply_filters(cls, query, filters, parsed):
        """ Apply All query filters.
        Returns query object.
        """

        def _is_string(col):
            return issubclass(col.type.python_type, str)

        # Apply any inequality filters.
        for (col_name, comparitor, values) in filters:
            if col_name in cls.get_filter_map():
                col = cls.get_filter_map()[col_name]
                if _is_string(col):
                    col = func.lower(col)
                    values = [val.lower() for val in values]
                    query = query.filter(
                        or_(col.ilike('%' + val + '%') for val in values))
                else:
                    operation = getattr(col, comparitor)
                    query = query.filter(or_(operation(val) for val in values))

        # Apply all other filters.
        for filter, value in parsed.items():
            if filter in cls.get_filter_map():
                col = cls.get_filter_map()[filter]
                query = query.filter(col.ilike('%' + value + '%'))

        return query


class Fields(object):
    @staticmethod
    def get_db_column_names():
        return {'year': 'data_year',
             'month': 'month_num',
             'agency_name': 'ucr_agency_name',
             'state': 'state_abbr',
             'city': 'city_name',
             'county': 'county_name',
             'tribe': 'tribe_name',
             'offense': 'offense_name',
             'offense_subcat': 'offense_subcat_name',
             'offense_category': 'offense_category_name',
             # except in ASR it's offense_cat_name
             'race': 'race_code',
             'ethnicity': 'ethnicity_code',
             'juvenile': 'juvenile_flag',
             'age': 'age_range_code',
             'sex': 'age_sex',
             'subclass': 'subclass_code',
             'subcategory': 'subcategory_code'
            }


    @staticmethod
    def get_simplified_column_names():
        return {v: k for (k, v) in Fields.get_db_column_names().items()}


class RoutingSQLAlchemy(SQLAlchemy):
    def create_session(self, options):
        return RoutingSession(self, **options)


class CdeResource(MethodResource):
    __abstract__ = True
    schema = None
    # Enable fast counting.
    fast_count = False

    OPERATORS = {
        '!=': '__ne__',
        '>=': '__ge__',
        '<=': '__le__',
        '>': '__gt__',
        '<': '__le__',
        '==': '__eq__',
    }

    is_groupable = False

    def _get(self, args):
        # TODO: apply "fields" arg

        self.verify_api_key(args)
        filters = self.filters(args)
        qry = self.tables.filtered(filters)
        if self.is_groupable:
            group_columns = [c.strip() for c in args['by'].split(',')]
            qry = self.tables.group_by(qry, group_columns)
        aggregate_many = False

        if args['aggregate_many'] == 'true':
            aggregate_many = True

        if args['output'] == 'csv':
            output = make_response(self.output_serialize(
                self.with_metadata(qry, args), self.schema, 'csv', aggregate_many))
            output.headers[
                "Content-Disposition"] = "attachment; filename=incidents.csv"
            output.headers["Content-type"] = "text/csv"
            return output
        return self.with_metadata(qry, args)

    def _serialize_dict(self, data, accumulator={}, path=None, aggregate_many = False):
        """ Recursively serializes a nested dict
        into a flat dict. Replaces lists with their
        length as an integer of any lists in nested dict.
        """

        # is_list_iter is false if not iterating over list.
        is_list_iter = False
        if isinstance(data, list):
            iterator = enumerate(data)
            # True if currently serializing list of dicts.
            is_list_iter = True
        if isinstance(data, dict):
            iterator = data.items()


        key_path = "" # The full attribute path.

        for k,v in iterator:
            # Append path ie: offense _ {key}
            if path:
                if is_list_iter:
                    # Indicates an object in a list.
                    # ie. offenses_0, offenses_1
                    key_path = path + '_' + str(k)
                else:
                    # Indicates an attribute of an object.
                    # ie. offenses_0.crime_name,
                    # victims.victim_1.location.location_name
                    key_path = path + '.' + str(k)
            else:
                key_path = k

            if isinstance(v, dict):
                # For dicts, the key path is preserved completely.
                self._serialize_dict(v, accumulator, key_path)
            elif isinstance(v, list):
                # For lists, the key path is shortened to
                # the list's index key: offenses, arrestees, etc.
                if self.aggregate_many:
                    accumulator[key_path] = len(v)
                else:
                    self._serialize_dict(v, accumulator, k)
            else:
                # Base case: No more nesting => Value.
                accumulator[key_path] = v

        return accumulator

    def output_serialize(self, data, schema=None, format='csv', aggregate_many = False):
        """ Parses results.
        Either outputs JSON, or CSV.
        """
        if format is 'json':
            return data
        if format is 'csv':
            self.aggregate_many = aggregate_many

            import csv
            from io import StringIO

            # create the csv writer object
            si = StringIO()
            csvwriter = csv.writer(si)
            to_csv = []

            # Serialize Data to flattened list of dicts.
            for d in data['results']:
                to_csv.append(self._serialize_dict(d, {}))

            # Fill in any missing keys.
            empty = dict.fromkeys(set().union(*to_csv), "")
            to_csv = [dict(empty, **d) for d in to_csv]

            # Generate CSV.
            # TODO: Sort by columns.
            count = 0
            for cs in to_csv:
                if count == 0:
                    header = cs.keys()
                    csvwriter.writerow(list(header))
                    count += 1
                csvwriter.writerow(list(cs.values()))
            return si.getvalue().strip('\r\n')

    def _jsonable(self, val):
        if isinstance(val, Decimal):
            return eval(str(val))
        elif hasattr(val, '__pow__'):  # is numeric
            return val
        return str(val)

    def _serialize(self, data):
        """Avoid JSON serialization errors
        by converting values in list of dicts
        into strings.

        Many resources will override this with more specific ways to serialize.
        """
        if self.schema:
            return self.schema.dump(data).data
        else:
            return [{k: self._jsonable(d[k])
                     for k in d} for d in (r._asdict() for r in data)]

    def _serialize_from_representation(self, data):
        """Get from cache in an associated `representation` record"""

        return [i.representation.representation for i in data]

    def _as_dict(self, fieldTuple, res):
        return dict(zip(fieldTuple, res))

    def _compile_query(self, query):
        """
        Gets String representation of an SQLAlchemy query.
        """
        from sqlalchemy.sql import compiler
        from psycopg2.extensions import adapt as sqlescape
        # or use the appropiate escape function from your db driver
        dialect = query.session.bind.dialect
        statement = query.statement
        comp = compiler.SQLCompiler(dialect, statement)
        comp.compile()
        enc = dialect.encoding
        params = {}
        for k,v in comp.params.items():
            params[k] = sqlescape(v)
        return (comp.string % params)

    def with_metadata(self, results, args):
        """Paginates results and wraps them in metadata."""

        paginated = results.limit(args['per_page']).offset(
            (args['page'] - 1) * args['per_page'])
        if hasattr(paginated, 'data'):
            paginated = paginated.data

        count = 0

        try:
            if self.fast_count:
                from sqlalchemy import select
                count_est_query = select([func.count_estimate(self._compile_query(results))])
                count_est_query_results = session.execute(count_est_query).fetchall()
                count = count_est_query_results[0][0]
                if count < COUNT_QUERY_THRESHOLD:
                    # If the count is less than
                    count = results.count()
        except Exception as count_exception:
            # Fallback to counting results with extra query.
            current_app.logger.warning('Failed to fast_count rows:')
            current_app.logger.warning(str(count_exception))
            current_app.logger.warning('Falling back to full count')
            session.rollback()
            count = results.count()

        serialized = self._serialize(paginated)

        return {
            'results': serialized,
            'pagination': {
                'count': count,
                'page': args['page'],
                'pages': math.ceil(count / args['per_page']),
                'per_page': args['per_page'],
            },
        }

    def as_csv_response(self, results, filename, args):
        """Returns the data as a CSV"""
        output = make_response(self.output_serialize(
            self.with_metadata(results, args), self.schema))
        output.headers[
            'Content-Disposition'] = 'attachment; filename={0}.csv'.format(
                filename)
        output.headers['Content-type'] = 'text/csv'
        return output

    def verify_api_key(self, args):
        if os.getenv('VCAP_SERVICES'):
            service_env = json.loads(os.getenv('VCAP_SERVICES'))
            cups_name = 'crime-data-api-creds'
            creds = [
                u['credentials'] for u in service_env['user-provided']
                if 'credentials' in u
            ]
            key = creds[0]['API_KEY']
            if args.get('api_key') != key:
                abort(401, message='Use correct `api_key` argument')

    def _parse_inequality_operator(self, k, v):
        """
        Returns (key, value, comparitor)
        """
        if v:
            for sign in ('!', '>', '<'):
                if k.endswith(sign) and v:
                    return (k[:-1], sign + '=', v)
            return (k, '==', v)
        else:
            for sign in ('>', '<'):
                if sign in k:
                    (new_k, new_v) = k.split(sign, 1)
                    return (new_k, sign, new_v)
            return (k, '==', True)

    def _split_values(self, val_string):
        val_string = val_string.strip('{} \t')
        values = val_string.split(',')
        return [v.strip() for v in values]

    def filters(self, parsed):
        """Yields `(key, comparitor, (values))` from `request.args`.

        `parsed` is automatically filled by the Marshmalow schema.

        `comparitor` may be '__eq__', '__gt__', '__le__', etc."""

        for (k, v) in request.args.items():
            if k in parsed:
                continue
            (k, op, v) = self._parse_inequality_operator(k, v)
            v = self._split_values(v)
            yield (k.lower(), self.OPERATORS[op], v)


db = RoutingSQLAlchemy()


class BaseModel(db.Model):
    __abstract__ = True
    idx = db.Column(db.Integer, primary_key=True)
