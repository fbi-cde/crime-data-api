from webargs.flaskparser import use_args
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache

from sqlalchemy import and_
from crime_data.common import newmodels, marshmallow_schemas
from crime_data.common.newmodels import HtAgency, HtSummary
from crime_data.common.base import CdeResource, tuning_page


class HtAgencyList(CdeResource):
    schema = marshmallow_schemas.HtAgencySchema(many=True)
    tables = HtAgency

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args):
        return self._get(args)


class HtStatesList(CdeResource):
    schema = marshmallow_schemas.HtSummarySchema(many=True, exclude=('agency_name', 'ori', ))

    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args):
        self.verify_api_key(args)
        year = args.get('year', None)
        state_abbr = args.get('state_abbr', None)
        counts = HtSummary.grouped_by_state(year=year, state_abbr=state_abbr)
        return self.render_response(counts, args, csv_filename='human_trafficking')
