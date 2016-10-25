import json
import os

from sqlalchemy import sql
from flask.ext.sqlalchemy import Pagination


def add_standard_arguments(parser):
    """Add arguments supported by all endpoints."""
    parser.add_argument('page', type=int, default=1)
    parser.add_argument('per_page', type=int, default=10)
    if os.getenv('VCAP_APPLICATION'):
        parser.add_argument('api_key',
                            required=True,
                            help='Get from Catherine')


def verify_api_key(args):
    if os.getenv('VCAP_SERVICES'):
        service_env = json.loads(os.getenv('VCAP_SERVICES'))
        cups_name = 'crime-data-api-creds'
        user_provided =service_env['user-provided']
        creds = filter(lambda x: x['name']==cups_name, user_provided).pop()
        key = creds['credentials']['API_KEY']
        if args['api_key'] != key:
            raise Exception('Ask Catherine for API key')


def expand_delimited_items(lst, sep=','):
    new_lst = []
    for itm in lst:
        for subitm in lst.split(sep):
            new_lst.append(subitm.strip())
    return new_lst


def with_metadata(results, args):
    try:
        results = results.paginate(args['page'], args['per_page'])
    except AttributeError:
        page = results.limit(args['per_page']).offset((args['page']-1)*args['per_page'])
        items = [row._asdict() for row in page]
        results = Pagination(results, page=args['page'], per_page=args['per_page'], total=results.count(), 
                             items=items) 
    return {'results': results.items,
            'pagination': {
                'count': results.total,
                'page': results.page,
                'pages': results.pages,
                'per_page': results.per_page,
            }, }


class QueryWithAggregates(object):

    OPERATION = sql.func.sum

    def _add_column(self, readable_name, operation=None):
        sql_name = self.COL_NAME_MAP.get(readable_name, readable_name)
        col = getattr(self.table, sql_name)
        if operation:
            col = operation(col)
        self.qry = self.qry.add_columns(label(readable_name, col))

    def __init__(self, aggregated, grouped):
        self.result = db.session.query()
        for col in aggregated:
            if not isinstance(col, str):
                (col, operation) = col
            else:
                operation = self.OPERATION
            self._add_column(col, operation)
        for col in grouped:
            self._add_column(col)
            self.qry = self.qry.group_by(getattr(self.table, col))

    def __next__(self):
        for row in self.qry:
            return row._asdict()
        raise StopIteration
