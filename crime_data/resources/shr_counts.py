from webargs.flaskparser import use_args
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache
from sqlalchemy import func

from crime_data.common import cdemodels, marshmallow_schemas
from crime_data.common.base import CdeResource, tuning_page
from crime_data.common.marshmallow_schemas import ArgumentsSchema

class SHRNationalHomicideVictimSex(CdeResource):
    schema = marshmallow_schemas.SHRNationalHomicideVictimSexSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        query = cdemodels.SHRNationalHomicideVictimSex.query
        return self.with_metadata(query,args)

class SHRNationalHomicideVictimRace(CdeResource):
    schema = marshmallow_schemas.SHRNationalHomicideVictimRaceSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        query = cdemodels.SHRNationalHomicideVictimRace.query
        return self.with_metadata(query,args)

class SHRNationalHomicideVictimEthnicity(CdeResource):
    schema = marshmallow_schemas.SHRNationalHomicideVictimEthnicitySchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        query = cdemodels.SHRNationalHomicideVictimEthnicity.query
        return self.with_metadata(query,args)

class SHRNationalHomicideVictimAge(CdeResource):
    schema = marshmallow_schemas.SHRNationalHomicideVictimAgeSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        query = cdemodels.SHRNationalHomicideVictimAge.query
        return self.with_metadata(query,args)


class SHRNationalHomicideOffenderSex(CdeResource):
    schema = marshmallow_schemas.SHRNationalHomicideOffenderSexSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        query = cdemodels.SHRNationalHomicideOffenderSex.query
        return self.with_metadata(query,args)

class SHRNationalHomicideOffenderRace(CdeResource):
    schema = marshmallow_schemas.SHRNationalHomicideOffenderRaceSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        query = cdemodels.SHRNationalHomicideOffenderRace.query
        return self.with_metadata(query,args)

class SHRNationalHomicideOffenderEthnicity(CdeResource):
    schema = marshmallow_schemas.SHRNationalHomicideOffenderEthnicitySchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        query = cdemodels.SHRNationalHomicideOffenderEthnicity.query
        return self.with_metadata(query,args)

class SHRNationalHomicideOffenderAge(CdeResource):
    schema = marshmallow_schemas.SHRNationalHomicideOffenderAgeSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        query = cdemodels.SHRNationalHomicideOffenderAge.query
        return self.with_metadata(query,args)

class SHRStateHomicideVictimSex(CdeResource):
    schema = marshmallow_schemas.SHRStateHomicideVictimSexSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.SHRStateHomicideVictimSex.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class SHRStateHomicideVictimRace(CdeResource):
    schema = marshmallow_schemas.SHRStateHomicideVictimRaceSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.SHRStateHomicideVictimRace.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class SHRStateHomicideVictimEthnicity(CdeResource):
    schema = marshmallow_schemas.SHRStateHomicideVictimEthnicitySchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.SHRStateHomicideVictimEthnicity.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class SHRStateHomicideVictimAge(CdeResource):
    schema = marshmallow_schemas.SHRStateHomicideVictimAgeSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.SHRStateHomicideVictimAge.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class SHRStateHomicideOffenderSex(CdeResource):
    schema = marshmallow_schemas.SHRStateHomicideOffenderSexSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.SHRStateHomicideOffenderSex.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class SHRStateHomicideOffenderRace(CdeResource):
    schema = marshmallow_schemas.SHRStateHomicideOffenderRaceSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.SHRStateHomicideOffenderRace.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class SHRStateHomicideOffenderEthnicity(CdeResource):
    schema = marshmallow_schemas.SHRStateHomicideOffenderEthnicitySchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.SHRStateHomicideOffenderEthnicity.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class SHRStateHomicideOffenderAge(CdeResource):
    schema = marshmallow_schemas.SHRStateHomicideOffenderAgeSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.SHRStateHomicideOffenderAge.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class SHRStateHomicideOffenderCount(CdeResource):
    schema = marshmallow_schemas.SHRStateHomicideOffenderCountSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.SHRStateHomicideOffenderCount.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class SHRStateHomicideVictimCount(CdeResource):
    schema = marshmallow_schemas.SHRStateHomicideVictimCountSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.SHRStateHomicideVictimCount.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class SHRNationalHomicideOffenderCount(CdeResource):
    schema = marshmallow_schemas.SHRNationalHomicideOffenderCountSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.SHRNationalHomicideOffenderCount.query
        return self.with_metadata(query,args)

class SHRNationalHomicideVictimCount(CdeResource):
    schema = marshmallow_schemas.SHRNationalHomicideVictimCountSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.SHRNationalHomicideVictimCount.query
        return self.with_metadata(query,args)
