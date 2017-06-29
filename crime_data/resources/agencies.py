import re

from flask import jsonify
from webargs.flaskparser import use_args
from crime_data.extensions import DEFAULT_MAX_AGE, DEFAULT_SURROGATE_AGE

from crime_data.common import cdemodels, models, newmodels
from crime_data.common.newmodels import CdeAgency
from crime_data.common import marshmallow_schemas
from crime_data.common.base import CdeResource, tuning_page, cache_for
from crime_data.common.marshmallow_schemas import (AgencySchema,
                                                   ArgumentsSchema)


class AgenciesList(CdeResource):
    schema = marshmallow_schemas.AgencySchema(many=True)
    tables = CdeAgency

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache_for(DEFAULT_MAX_AGE, DEFAULT_SURROGATE_AGE)
    def get(self, args):
        return self._get(args)


class AgenciesDetail(CdeResource):
    schema = marshmallow_schemas.AgencySchema()
    @use_args(marshmallow_schemas.ApiKeySchema)
    @cache_for(DEFAULT_MAX_AGE, DEFAULT_SURROGATE_AGE)
    def get(self, args, ori):
        self.verify_api_key(args)
        agency = CdeAgency.query.filter(CdeAgency.ori == ori).one()
        return jsonify(self.schema.dump(agency).data)
