import json
import os

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
        creds = [u['credentials']
                 for u in service_env['user-provided'] if 'credentials' in u]
        key = creds[0]['API_KEY']
        if args['api_key'] != key:
            raise Exception('Ask Catherine for API key')


def expand_delimited_items(lst, sep=','):
    new_lst = []
    for itm in lst:
        for subitm in lst.split(sep):
            new_lst.append(subitm.strip())
    return new_lst


def with_metadata(results, args, schema=None):
    try:
        results = results.paginate(args['page'], args['per_page'])
        items = schema.dump(results.items).data
    except AttributeError:
        page = results.limit(args['per_page']).offset((args['page'] - 1) *
                                                      args['per_page'])
        items = [row._asdict() for row in page]
        results = Pagination(results,
                             page=args['page'],
                             per_page=args['per_page'],
                             total=results.count(),
                             items=items)
        items = results.items
    return {'results': items,
            'pagination': {
                'count': results.total,
                'page': results.page,
                'pages': results.pages,
                'per_page': results.per_page,
            }, }


