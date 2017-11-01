from webargs.flaskparser import use_args
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache
from sqlalchemy import func

from crime_data.common import cdemodels, marshmallow_schemas, lookupmodels
from crime_data.common.base import CdeResource, tuning_page
from crime_data.common.newmodels import ArsonSummary


class ArsonStateCounts(CdeResource):
    """Return the arson counts for a state"""
    schema = marshmallow_schemas.ArsonSummarySchema(many=True,
                                                    exclude=('subcategory_code', 'subcategory_name',))
    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args, state_abbr=None, region_code=None):
        self.verify_api_key(args)
        query = ArsonSummary.query

        if state_abbr is not None:
            query = query.filter(func.lower(ArsonSummary.state_abbr) == func.lower(state_abbr))
        elif region_code is not None:
            states = lookupmodels.StateLK.get(region_code=region_code).all()
            id_arr= []
            [id_arr.append(state.state_abbr) for state in states]
            query = query.filter(ArsonSummary.state_abbr.in_(id_arr))
        else:
            query = query.filter(ArsonSummary.state_abbr == None)


        query = query.filter(ArsonSummary.ori == None)
        query = query.filter(ArsonSummary.year != None)
        query = query.filter(ArsonSummary.subcategory_code == None)
        query = query.order_by(ArsonSummary.year)
        return self.with_metadata(query, args)
