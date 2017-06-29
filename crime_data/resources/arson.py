from webargs.flaskparser import use_args
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache
from sqlalchemy import func

from crime_data.common import cdemodels, marshmallow_schemas
from crime_data.common.base import CdeResource, tuning_page
from crime_data.common.newmodels import ArsonSummary


class ArsonStateCounts(CdeResource):
    """Return the arson counts for a state"""
    schema = marshmallow_schemas.ArsonSummarySchema(many=True,
                                                    exclude=('subcategory_code', 'subcategory_name',))
    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = ArsonSummary.query

        if state_abbr is None:
            query = query.filter(ArsonSummary.state_abbr == None)
        else:
            query = query.filter(func.lower(ArsonSummary.state_abbr) == func.lower(state_abbr))

        query = query.filter(ArsonSummary.ori == None)
        query = query.filter(ArsonSummary.year != None)
        query = query.filter(ArsonSummary.subcategory_code == None)
        query = query.order_by(ArsonSummary.year)
        return self.with_metadata(query, args)
