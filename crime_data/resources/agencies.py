import sqlalchemy as sa
# from flask_apispec import doc

# from webservices import args
# from webservices import docs
# from webservices import utils
# from webservices import schemas
# from webservices import exceptions
from crime_data.common import models
#from webservices.common.views import ApiResource
from flask_restful import Resource

class AgenciesList(Resource):
    def get(self):
        return {'hello': 'world'}