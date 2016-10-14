import os


def add_standard_arguments(parser):
    """Add arguments supported by all endpoints."""
    parser.add_argument('page', type=int, default=1)
    parser.add_argument('page_size', type=int, default=10)
    if os.getenv('VCAP_APPLICATION'):
        parser.add_argument('api_key',
                            required=True,
                            help='Get from Catherine')


def verify_api_key(args):
    if os.getenv('VCAP_APPLICATION'):
        if args['api_key'] != os.getenv('API_KEY'):
            raise Exception('Ask Catherine for API key')
