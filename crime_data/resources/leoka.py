from webargs.flaskparser import use_args
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache
from sqlalchemy import func

from crime_data.common import cdemodels, marshmallow_schemas, munger
from crime_data.common.base import CdeResource, tuning_page
from crime_data.common.marshmallow_schemas import ArgumentsSchema

class LeokaAssaultNational(CdeResource):
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, variable):
        self.verify_api_key(args)
        if variable == 'assign-dist':
            self.set_schema(marshmallow_schemas.LeokaAssaultAssignDistNational(many=True))
            query = cdemodels.LeokaAssaultAssignDistNational.query
            creator = munger.UIComponentCreator(query.all(),'leoka_assault_by_assign_dist','activity_name')
        elif variable == 'weapon':
            self.set_schema(marshmallow_schemas.LeokaAssaultWeaponNational(many=True))
            query = cdemodels.LeokaAssaultWeaponNational.query
            creator = munger.UIComponentCreator(query.all(),'leoka_assault_by_weapon','')
        elif variable == 'weapon-group':
            self.set_schema(marshmallow_schemas.LeokaAssaultWeaponByGroupNational(many=True))
            query = cdemodels.LeokaAssaultWeaponByGroupNational.query
            creator = munger.UIComponentCreator(query.all(),'leoka_assault_by_weapon_per_group','population_group_desc')
        elif variable == 'weapon-activity':
            self.set_schema(marshmallow_schemas.LeokaAssaultWeaponByActivityNational(many=True))
            query = cdemodels.LeokaAssaultWeaponByActivityNational.query
            creator = munger.UIComponentCreator(query.all(),'leoka_assault_by_weapon_per_activity','activity_name')
        elif variable == 'group':
            self.set_schema(marshmallow_schemas.LeokaAssaultByGroupNational(many=True))
            query = cdemodels.LeokaAssaultByGroupNational.query
            creator = munger.UIComponentCreator(query.all(),'leoka_assault_by_group','activity_name')
        elif variable == 'time':
            self.set_schema(marshmallow_schemas.LeokaAssaultByTimeNational(many=True))
            query = cdemodels.LeokaAssaultByTimeNational.query
            creator = munger.UIComponentCreator(query.all(),'leoka_assault_by_time','')
        elif variable == 'weapon-injury':
            self.set_schema(marshmallow_schemas.LeokaAssaultWeaponInjuryNational(many=True))
            query = cdemodels.LeokaAssaultWeaponInjuryNational.query
            creator = munger.UIComponentCreator(query.all(),'leoka_assault_weapon_injury','')
        else:
            return self.with_metadata([], args)
        ui = creator.munge_set()
        return self.without_metadata(ui, args)

class LeokaAssaultRegional(CdeResource):
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, variable, region_name=None):
        self.verify_api_key(args)
        if variable == 'assign-dist':
            self.set_schema(marshmallow_schemas.LeokaAssaultAssignDistRegional(many=True))
            query = cdemodels.LeokaAssaultAssignDistRegional.get(region_name=region_name)
            creator = munger.UIComponentCreator(query.all(),'leoka_assault_by_assign_dist','activity_name')
        elif variable == 'weapon':
            self.set_schema(marshmallow_schemas.LeokaAssaultWeaponRegional(many=True))
            query = cdemodels.LeokaAssaultWeaponRegional.get(region_name=region_name)
            creator = munger.UIComponentCreator(query.all(),'leoka_assault_by_weapon','')
        elif variable == 'weapon-group':
            self.set_schema(marshmallow_schemas.LeokaAssaultWeaponByGroupRegional(many=True))
            query = cdemodels.LeokaAssaultWeaponByGroupRegional.get(region_name=region_name)
            creator = munger.UIComponentCreator(query.all(),'leoka_assault_by_weapon_per_group','population_group_desc')
        elif variable == 'weapon-activity':
            self.set_schema(marshmallow_schemas.LeokaAssaultWeaponByActivityRegional(many=True))
            query = cdemodels.LeokaAssaultWeaponByActivityRegional.get(region_name=region_name)
            creator = munger.UIComponentCreator(query.all(),'leoka_assault_by_weapon_per_activity','activity_name')
        elif variable == 'group':
            self.set_schema(marshmallow_schemas.LeokaAssaultByGroupRegional(many=True))
            query = cdemodels.LeokaAssaultByGroupRegional.get(region_name=region_name)
            creator = munger.UIComponentCreator(query.all(),'leoka_assault_by_group','activity_name')
        elif variable == 'weapon-injury':
            self.set_schema(marshmallow_schemas.LeokaAssaultWeaponInjuryNational(many=True))
            query = cdemodels.LeokaAssaultWeaponInjuryRegion.get(region_name=region_name)
            creator = munger.UIComponentCreator(query.all(),'leoka_assault_weapon_injury','')
        else:
            return self.with_metadata([], args)
        ui = creator.munge_set()
        return self.without_metadata(ui, args)

class LeokaAssaultState(CdeResource):
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, variable, state_abbr=None):
        self.verify_api_key(args)
        if variable == 'assign-dist':
            self.set_schema(marshmallow_schemas.LeokaAssaultAssignDistState(many=True))
            query = cdemodels.LeokaAssaultAssignDistState.get(state_abbr=state_abbr)
            creator = munger.UIComponentCreator(query.all(),'leoka_assault_by_assign_dist','activity_name')
        elif variable == 'weapon':
            self.set_schema(marshmallow_schemas.LeokaAssaultWeaponState(many=True))
            query = cdemodels.LeokaAssaultWeaponState.get(state_abbr=state_abbr)
            creator = munger.UIComponentCreator(query.all(),'leoka_assault_by_weapon','')
        elif variable == 'weapon-group':
            self.set_schema(marshmallow_schemas.LeokaAssaultWeaponByGroupState(many=True))
            query = cdemodels.LeokaAssaultWeaponByGroupState.get(state_abbr=state_abbr)
            creator = munger.UIComponentCreator(query.all(),'leoka_assault_by_weapon_per_group','population_group_desc')
        elif variable == 'weapon-activity':
            self.set_schema(marshmallow_schemas.LeokaAssaultWeaponByActivityState(many=True))
            query = cdemodels.LeokaAssaultWeaponByActivityState.get(state_abbr=state_abbr)
            creator = munger.UIComponentCreator(query.all(),'leoka_assault_by_weapon_per_activity','activity_name')
        elif variable == 'group':
            self.set_schema(marshmallow_schemas.LeokaAssaultByGroupState(many=True))
            query = cdemodels.LeokaAssaultByGroupState.get(state_abbr=state_abbr)
            creator = munger.UIComponentCreator(query.all(),'leoka_assault_by_group','activity_name')
        elif variable == 'weapon-injury':
            self.set_schema(marshmallow_schemas.LeokaAssaultWeaponInjuryNational(many=True))
            query = cdemodels.LeokaAssaultWeaponInjuryState.get(state_abbr=state_abbr)
            creator = munger.UIComponentCreator(query.all(),'leoka_assault_weapon_injury','')
        else:
            return self.with_metadata([], args)
        ui = creator.munge_set()
        return self.without_metadata(ui, args)

class LeokaAssaultAgency(CdeResource):
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, variable, ori=None):
        self.verify_api_key(args)
        if variable == 'assign-dist':
            self.set_schema(marshmallow_schemas.LeokaAssaultAssignDistAgency(many=True))
            query = cdemodels.LeokaAssaultAssignDistAgency.get(ori=ori)
            creator = munger.UIComponentCreator(query.all(),'leoka_assault_by_assign_dist','activity_name')
        elif variable == 'weapon-activity':
            self.set_schema(marshmallow_schemas.LeokaAssaultWeaponByActivityAgency(many=True))
            query = cdemodels.LeokaAssaultWeaponByActivityAgency.get(ori=ori)
            creator = munger.UIComponentCreator(query.all(),'leoka_assault_by_weapon_per_activity','activity_name')
        elif variable == 'weapon':
            self.set_schema(marshmallow_schemas.LeokaAssaultWeaponAgency(many=True))
            query = cdemodels.LeokaAssaultWeaponAgency.get(ori=ori)
            creator = munger.UIComponentCreator(query.all(),'leoka_assault_by_weapon')
        else:
            return self.with_metadata([], args)
        ui = creator.munge_set()
        return self.without_metadata(ui, args)
