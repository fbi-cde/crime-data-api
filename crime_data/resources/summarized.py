from webargs.flaskparser import use_args
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache
from sqlalchemy import func

from crime_data.common import cdemodels, marshmallow_schemas
from crime_data.common.base import CdeResource, tuning_page
from crime_data.common.marshmallow_schemas import ArgumentsSchema

class SummarizedData(CdeResource):
    schema = marshmallow_schemas.SummarizedDataSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None, state_abbr=None,region_name=None):
        self.verify_api_key(args)
        query = cdemodels.SummarizedData(state_abbr=state_abbr,ori=ori,region_name=region_name).query
        if state_abbr is not None:
            query = query.filter(func.lower(cdemodels.SummarizedData.state_abbr) == func.lower(state_abbr))
        elif region_name is not None:
            query = query.filter(func.lower(cdemodels.SummarizedData.region_name) == func.lower(region_name))
        elif ori is not None:
            query = query.filter(func.lower(cdemodels.SummarizedData.ori) == func.lower(ori))

        return self._serialize(query)
