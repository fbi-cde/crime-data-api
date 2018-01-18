from webargs.flaskparser import use_args
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache
from sqlalchemy import func

from crime_data.common import cdemodels, marshmallow_schemas
from crime_data.common.base import CdeResource, tuning_page
from crime_data.common.marshmallow_schemas import ArgumentsSchema


class PoliceEmploymentDataAgency(CdeResource):
    schema = marshmallow_schemas.PoliceEmploymentDataAgencySchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.PoliceEmploymentDataAgency.get(state_abbr=state_abbr,ori=ori)
        return self.with_metadata(query,args)

class LeokaAssaultByGroupNational(CdeResource):
    schema = marshmallow_schemas.LeokaAssaultByGroupNational(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args,):
        self.verify_api_key(args)
        query = cdemodels.LeokaAssaultByGroupNational.query
        return self.with_metadata(query,args)
