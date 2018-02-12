from webargs.flaskparser import use_args
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache
from sqlalchemy import func
from crime_data.common.marshmallow_schemas import ArgumentsSchema
import json
import inspect
import jsonpickle

from crime_data.common import cdemodels, marshmallow_schemas
from crime_data.common.base import CdeResource

class UIComponentCreator(object):
    def __init__(self,results,table_name,key_type):
        self.results=results
        self.table_name = table_name
        self.key_type = key_type

    def munge_set(self):
        self.keys = self.fetchKeys()
        data =[]
        keys = []
        uiObject = UIObject(self.keys[0].ui_component,self.keys[0].ui_text)
        for j in range(len(self.keys)):
            key = self.keys[j].key
            value = 0
            if self.key_type != '':
                for k in range(len(self.results)):
                    d = Key(self.keys[j].key)
                    data_year = self.results[k].data_year
                    keytype = getattr(self.results[k], self.key_type)
                    d.setTypeKey(keytype)
                    d.data_year = data_year
                    for i in range(len(self.results)):
                        if data_year == self.results[i].data_year and keytype ==  getattr(self.results[i], self.key_type):
                            d.value =  d.value + getattr(self.results[i], self.keys[j].column_name)
                    d.value = int(d.value)
                    data.append(d)
                keys.append(key)
            else:
                for k in range(len(self.results)):
                    d = Key(self.keys[j].key)
                    data_year = self.results[k].data_year
                    d.data_year = data_year
                    for i in range(len(self.results)):
                        if data_year == self.results[i].data_year:
                            d.value =  d.value + getattr(self.results[i], self.keys[j].column_name)
                    data.append(d)
                keys.append(key)
        print('munging set:')
        uiObject.keys = keys
        uiObject.data = data
        return uiObject

    def fetchKeys(self):
        schema = marshmallow_schemas.TableKeyMapping(many=True)
        print('table_name:',self.table_name);
        query = cdemodels.TableKeyMapping.get(table_name=self.table_name)
        return query.all()


class Key(object):
        def __init__(self,key):
            self.key = key
            self.value = 0;
            self.data_year = 0;
            self.key_type = ''


        def setTypeKey(self,keytype):
            self.key_type = keytype


class UIObject(object):
    def __init__(self,ui_type,noun):
        self.keys = []
        self.data = [];
        self.ui_type = ui_type;
        self.noun = noun

    def toString(self):
        print('noun:',self.noun,' ui_type:',self.ui_type, 'data:',len(self.data), ' keys:',len(self.keys));


    def toJSON(self):
        return jsonpickle.encode(self, unpicklable=False)
