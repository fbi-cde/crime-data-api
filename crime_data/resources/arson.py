from webargs.flaskparser import use_args

from crime_data.common import cdemodels, marshmallow_schemas
from crime_data.common.base import CdeResource, tuning_page


class ArsonCountResource(CdeResource):

    tables = cdemodels.ArsonTableFamily()
    is_groupable = True

    @use_args(marshmallow_schemas.GroupableArgsSchema)
    @tuning_page
    def get(self, args):
        return self._get(args)

""
