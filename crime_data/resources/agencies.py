from flask_restful import fields, marshal_with, reqparse
from webargs.flaskparser import use_args

from crime_data.common import cdemodels as models
from crime_data.common import marshmallow_schemas
from crime_data.common.base import CdeResource


class AgenciesResource(CdeResource):

    schema = marshmallow_schemas.RefAgencySchema(many=True)


class AgenciesList(AgenciesResource):
    @use_args(marshmallow_schemas.ArgumentsSchema)
    def get(self, args):
        self.verify_api_key(args)
        result = models.CdeRefAgency.query
        return self.with_metadata(result, args)


class AgenciesDetail(AgenciesResource):
    @use_args(marshmallow_schemas.ArgumentsSchema)
    def get(self, args, nbr):
        self.verify_api_key(args)
        agency = models.CdeRefAgency.query.filter_by(ori=nbr)
        return self.with_metadata(agency, args)


class AgenciesNibrsCount(CdeResource):
    @use_args(marshmallow_schemas.ArgumentsSchema)
    def get(self, args, ori=None, filters=None):
        '''''
        Get Incident Count by Agency ID/ORI.
        ''' ''
        self.verify_api_key(args)

        query = models.CdeNibrsIncident.get_nibrs_incident_by_ori(ori, filters)
        return self.with_metadata(query, args)

class AgenciesRetaCount(CdeResource):
    @use_args(marshmallow_schemas.ArgumentsSchema)
    def get(self, args, ori=None, filters=None):
        '''''
        Get Incident Count by Agency ID/ORI.
        '''''
        self.verify_api_key(args)

        query = models.CdeNibrsIncident.get_reta_by_ori(ori, filters)
        result = self.with_metadata(query, args)

        return result

