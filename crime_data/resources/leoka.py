from webargs.flaskparser import use_args
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache
from sqlalchemy import func

from crime_data.common import cdemodels, marshmallow_schemas
from crime_data.common.base import CdeResource, tuning_page
from crime_data.common.marshmallow_schemas import ArgumentsSchema

class LeokaAssaultByGroupNational(CdeResource):
    schema = marshmallow_schemas.LeokaAssaultByGroupNational(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args,):
        self.verify_api_key(args)
        query = cdemodels.LeokaAssaultByGroupNational.query
        return self.with_metadata(query,args)

class LeokaAssaultByGroupRegional(CdeResource):
    schema = marshmallow_schemas.LeokaAssaultByGroupRegional(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, region_name=None):
        self.verify_api_key(args)
        query = cdemodels.LeokaAssaultByGroupRegional.get(region_name=region_name)
        return self.with_metadata(query,args)

class LeokaAssaultByGroupState(CdeResource):
    schema = marshmallow_schemas.LeokaAssaultByGroupState(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.LeokaAssaultByGroupState.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class LeokaAssaultAssignDistNational(CdeResource):
    schema = marshmallow_schemas.LeokaAssaultAssignDistNational(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args,):
        self.verify_api_key(args)
        query = cdemodels.LeokaAssaultAssignDistNational.query
        return self.with_metadata(query,args)

class LeokaAssaultAssignDistRegional(CdeResource):
    schema = marshmallow_schemas.LeokaAssaultAssignDistRegional(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, region_name=None):
        self.verify_api_key(args)
        query = cdemodels.LeokaAssaultAssignDistRegional.get(region_name=region_name)
        return self.with_metadata(query,args)

class LeokaAssaultAssignDistState(CdeResource):
    schema = marshmallow_schemas.LeokaAssaultAssignDistState(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.LeokaAssaultAssignDistState.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class LeokaAssaultAssignDistAgency(CdeResource):
    schema = marshmallow_schemas.LeokaAssaultAssignDistAgency(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None):
        self.verify_api_key(args)
        query = cdemodels.LeokaAssaultAssignDistAgency.get(ori=ori)
        return self.with_metadata(query,args)

class LeokaAssaultWeaponNational(CdeResource):
    schema = marshmallow_schemas.LeokaAssaultWeaponNational(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args,):
        self.verify_api_key(args)
        query = cdemodels.LeokaAssaultWeaponNational.query
        return self.with_metadata(query,args)

class LeokaAssaultWeaponRegional(CdeResource):
    schema = marshmallow_schemas.LeokaAssaultWeaponRegional(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, region_name=None):
        self.verify_api_key(args)
        query = cdemodels.LeokaAssaultWeaponRegional.get(region_name=region_name)
        return self.with_metadata(query,args)

class LeokaAssaultWeaponState(CdeResource):
    schema = marshmallow_schemas.LeokaAssaultWeaponState(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.LeokaAssaultWeaponState.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class LeokaAssaultWeaponAgency(CdeResource):
    schema = marshmallow_schemas.LeokaAssaultWeaponAgency(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None):
        self.verify_api_key(args)
        query = cdemodels.LeokaAssaultWeaponAgency.get(ori=ori)
        return self.with_metadata(query,args)

class LeokaAssaultWeaponByGroupNational(CdeResource):
    schema = marshmallow_schemas.LeokaAssaultWeaponByGroupNational(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args,):
        self.verify_api_key(args)
        query = cdemodels.LeokaAssaultWeaponByGroupNational.query
        return self.with_metadata(query,args)

class LeokaAssaultWeaponByGroupRegional(CdeResource):
    schema = marshmallow_schemas.LeokaAssaultWeaponByGroupRegional(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, region_name=None):
        self.verify_api_key(args)
        query = cdemodels.LeokaAssaultWeaponByGroupRegional.get(region_name=region_name)
        return self.with_metadata(query,args)

class LeokaAssaultWeaponByGroupState(CdeResource):
    schema = marshmallow_schemas.LeokaAssaultWeaponByGroupState(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.LeokaAssaultWeaponByGroupState.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class LeokaAssaultWeaponByActivityNational(CdeResource):
    schema = marshmallow_schemas.LeokaAssaultWeaponByActivityNational(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args,):
        self.verify_api_key(args)
        query = cdemodels.LeokaAssaultWeaponByActivityNational.query
        return self.with_metadata(query,args)

class LeokaAssaultWeaponByActivityRegional(CdeResource):
    schema = marshmallow_schemas.LeokaAssaultWeaponByActivityRegional(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, region_name=None):
        self.verify_api_key(args)
        query = cdemodels.LeokaAssaultWeaponByActivityRegional.get(region_name=region_name)
        return self.with_metadata(query,args)

class LeokaAssaultWeaponByActivityState(CdeResource):
    schema = marshmallow_schemas.LeokaAssaultWeaponByActivityState(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.LeokaAssaultWeaponByActivityState.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class LeokaAssaultWeaponByActivityAgency(CdeResource):
    schema = marshmallow_schemas.LeokaAssaultWeaponByActivityAgency(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None):
        self.verify_api_key(args)
        query = cdemodels.LeokaAssaultWeaponByActivityAgency.get(ori=ori)
        return self.with_metadata(query,args)
