import re

from flask import jsonify
from webargs.flaskparser import use_args
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache
from sqlalchemy import func

from crime_data.common import cdemodels, models, newmodels
from crime_data.common.newmodels import CdeAgency
from crime_data.common import marshmallow_schemas
from crime_data.common.base import CdeResource, tuning_page
from crime_data.common.marshmallow_schemas import (AgencySchema,
                                                   ArgumentsSchema)


class AgenciesList(CdeResource):
    schema = marshmallow_schemas.AgencySchema(many=True)
    tables = CdeAgency

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        return self._get(args)


class AgenciesDetail(CdeResource):
    schema = marshmallow_schemas.AgencySchema()
    @use_args(marshmallow_schemas.ApiKeySchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori):
        self.verify_api_key(args)
        agency = CdeAgency.query.filter(CdeAgency.ori == ori).one()
        return jsonify(self.schema.dump(agency).data)


class Agencies(CdeResource):
    schema = marshmallow_schemas.AgenciesSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.Agencies(state_abbr=state_abbr,ori=ori).query
        if state_abbr is not None:
            query = query.filter(func.lower(cdemodels.Agencies.state_abbr) == func.lower(state_abbr))
        elif ori is not None:
            query = query.filter(func.lower(cdemodels.Agencies.ori) == func.lower(ori))

        return self._serialize(query)
