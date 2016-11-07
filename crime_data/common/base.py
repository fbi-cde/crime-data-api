import json
import math
import os
import random
from functools import wraps

import sqltap
from flask import make_response, request
from flask_restful import Resource, abort, current_app
# import celery
from flask_sqlalchemy import SignallingSession, SQLAlchemy
from sqlalchemy import func, or_


def tuning_page(f):
    @wraps(f)
    def decorated_get(*args, **kwargs):
        if args[1]['tuning']:
            if not current_app.config['DEBUG']:
                abort(403, message="`DEBUG` must be on for tuning page")
            profiler = sqltap.start()
            result = f(*args, **kwargs)
            profiler.stop()
            stats = profiler.collect()
            return make_response(sqltap.report(stats, 'tuning.html'))
        else:
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
                    query = query.filter(or_(col.ilike('%' + val + '%')
                                             for val in values))
                else:
                    operation = getattr(col, comparitor)
                    query = query.filter(or_(operation(val) for val in values))

        # Apply all other filters.
        for filter, value in parsed.items():
            if filter in cls.get_filter_map():
                col = cls.get_filter_map()[filter]
                query = query.filter(col.ilike('%' + value + '%'))

        return query


class RoutingSQLAlchemy(SQLAlchemy):
    def create_session(self, options):
        return RoutingSession(self, **options)


class CdeResource(Resource):
    __abstract__ = True
    schema = None

    OPERATORS = {'!=': '__ne__',
                 '>=': '__ge__',
                 '<=': '__le__',
                 '>': '__gt__',
                 '<': '__le__',
                 '==': '__eq__', }

    def output_serialize(self, data, schema=None, format='csv'):
        """ Very limited csv parsing of output data.
        Uses Marshmallow schema to determine which fields are nested,
        and stores raw json for these fields.
        """
        if format is 'json':
            return data
        if format is 'csv':

            import flatdict
            import csv
            from io import StringIO

            # create the csv writer object
            si = StringIO()
            csvwriter = csv.writer(si)
            keys = {}

            # These are fields that can contain nested objects and/or lists
            list_fields = []
            for k, v in schema.declared_fields.items():
                if hasattr(v, 'many'):
                    list_fields.append(k)

            to_csv = []

            # Organize Data
            for d in data['results']:
                to_csv_dict = {}
                for base_field in list_fields:
                    to_csv_dict[base_field] = d[base_field]

                flat = flatdict.FlatDict(d)

                for k, v in flat.items():
                    base_field = k.split(':')[0]
                    leaf_field = k.split(':')[-1]
                    if base_field not in list_fields:
                        to_csv_dict[base_field + '.' + leaf_field] = v

                to_csv.append(to_csv_dict)

            count = 0
            for cs in to_csv:
                if count == 0:
                    header = cs.keys()
                    csvwriter.writerow(header)
                    count += 1
                csvwriter.writerow(cs.values())

        return si.getvalue().strip('\r\n')

    def _stringify(self, data):
        """Avoid JSON serialization errors
        by converting values in list of dicts
        into strings."""
        return [{k: (d[k] if hasattr(d[k], '__pow__') else str(d[k]))
                 for k in d} for d in (r._asdict() for r in data)]

    def _as_dict(self, fieldTuple, res):
        return dict(zip(fieldTuple, res))

    def with_metadata(self, results, args):
        """Paginates results and wraps them in metadata."""

        if self.schema:
            paginated = results.distinct().limit(args['per_page']).offset(
                (args['page'] - 1) * args['per_page'])
            if hasattr(paginated, 'data'):
                paginated = paginated.data
            count = results.distinct().count()
            return {'results': self.schema.dump(paginated).data,
                    'pagination': {
                        'count': count,
                        'page': args['page'],
                        'pages': math.ceil(count / args['per_page']),
                        'per_page': args['per_page'],
                    }, }
        else:
            paginated = results.paginate(args['page'], args['per_page'])
            items = self._stringify(paginated.items)
            return {'results': items,
                    'pagination': {
                        'count': paginated.total,
                        'page': paginated.page,
                        'pages': paginated.pages,
                        'per_page': paginated.per_page,
                    }, }

    def verify_api_key(self, args):
        if os.getenv('VCAP_SERVICES'):
            service_env = json.loads(os.getenv('VCAP_SERVICES'))
            cups_name = 'crime-data-api-creds'
            creds = [u['credentials']
                     for u in service_env['user-provided']
                     if 'credentials' in u]
            key = creds[0]['API_KEY']
            if args.get('api_key') != key:
                abort(401, 'Use correct `api_key` argument')

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
        """Yields `(key, comparitor, (values))` from `request.args` not already in `parsed`.

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
