from webargs.flaskparser import use_args
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache
from sqlalchemy import func

from crime_data.common import cdemodels, marshmallow_schemas
from crime_data.common.base import CdeResource

class UIComponentCreator(object):
    def __init__(self,results,component,title):
        self.results=results
        self.UIComponent = component
        self.title = title

    def munge_set(self):
        keys = fetchKeys();
        print('Keys')
        for i in range(len(self.results)):
            print(self.results[i].data_year)

    def fetchKeys(self):
        schema = marshmallow_schemas.TableKeyMapping(many=True)
        @use_args(ArgumentsSchema)
        @cache(max_age=DEFAULT_MAX_AGE, public=True)
        def get(self, args, table=None):
            self.verify_api_key(args)
            query = cdemodels.TableKeyMapping.get(table=table)
            return self.with_metadata(query,args)
