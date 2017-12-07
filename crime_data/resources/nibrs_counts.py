from webargs.flaskparser import use_args
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache
from sqlalchemy import func

from crime_data.common import cdemodels, marshmallow_schemas
from crime_data.common.base import CdeResource, tuning_page
from crime_data.common.marshmallow_schemas import ArgumentsSchema


class NIBRSAgencyVictimDenormCount(CdeResource):
    schema = marshmallow_schemas.NIBRSAgencyVictimDenormCountSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSAgencyVictimDenormCount.get(ori=ori)
        return self.with_metadata(query,args)

class NIBRSAgencyVictimDenormSex(CdeResource):
    schema = marshmallow_schemas.NIBRSAgencyVictimDenormSexSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSAgencyVictimDenormSex.get(ori=ori)
        return self.with_metadata(query,args)

class NIBRSAgencyVictimDenormRace(CdeResource):
    schema = marshmallow_schemas.NIBRSAgencyVictimDenormRaceSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSAgencyVictimDenormRace.get(ori=ori)
        return self.with_metadata(query,args)

class NIBRSAgencyVictimDenormEthnicity(CdeResource):
    schema = marshmallow_schemas.NIBRSAgencyVictimDenormEthnicitySchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSAgencyVictimDenormEthnicity.get(ori=ori)
        return self.with_metadata(query,args)

class NIBRSAgencyVictimDenormAge(CdeResource):
    schema = marshmallow_schemas.NIBRSAgencyVictimDenormAgeSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSAgencyVictimDenormAge.get(ori=ori)
        return self.with_metadata(query,args)

class NIBRSAgencyVictimDenormLocation(CdeResource):
    schema = marshmallow_schemas.NIBRSAgencyVictimDenormLocationSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSAgencyVictimDenormLocation.get(ori=ori)
        return self.with_metadata(query,args)

class NIBRSAgencyOffenderDenormCount(CdeResource):
    schema = marshmallow_schemas.NIBRSAgencyOffenderDenormCountSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSAgencyOffenderDenormCount.get(ori=ori)
        return self.with_metadata(query,args)

class NIBRSAgencyOffenderDenormSex(CdeResource):
    schema = marshmallow_schemas.NIBRSAgencyOffenderDenormSexSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSAgencyOffenderDenormSex.get(ori=ori)
        return self.with_metadata(query,args)

class NIBRSAgencyOffenderDenormRace(CdeResource):
    schema = marshmallow_schemas.NIBRSAgencyOffenderDenormRaceSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSAgencyOffenderDenormRace.get(ori=ori)
        return self.with_metadata(query,args)

class NIBRSAgencyOffenderDenormEthnicity(CdeResource):
    schema = marshmallow_schemas.NIBRSAgencyOffenderDenormEthnicitySchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSAgencyOffenderDenormEthnicity.get(ori=ori)
        return self.with_metadata(query,args)

class NIBRSAgencyOffenderDenormAge(CdeResource):
    schema = marshmallow_schemas.NIBRSAgencyOffenderDenormAgeSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSAgencyOffenderDenormAge.get(ori=ori)
        return self.with_metadata(query,args)

class NIBRSNationalVictimDenormCount(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalVictimDenormCountSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalVictimDenormCount.query
        return self.with_metadata(query,args)

class NIBRSNationalVictimDenormSex(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalVictimDenormSexSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalVictimDenormSex.query
        return self.with_metadata(query,args)

class NIBRSNationalVictimDenormRace(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalVictimDenormRaceSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalVictimDenormRace.query
        return self.with_metadata(query,args)

class NIBRSNationalVictimDenormEthnicity(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalVictimDenormEthnicitySchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalVictimDenormEthnicity.query
        return self.with_metadata(query,args)

class NIBRSNationalVictimDenormAge(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalVictimDenormAgeSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalVictimDenormAge.query
        return self.with_metadata(query,args)

class NIBRSNationalVictimDenormLocation(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalVictimDenormLocationSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalVictimDenormLocation.query
        return self.with_metadata(query,args)

class NIBRSNationalOffenderDenormCount(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalOffenderDenormCountSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalOffenderDenormCount.query
        return self.with_metadata(query,args)

class NIBRSNationalOffenderDenormSex(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalOffenderDenormSexSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalOffenderDenormSex.query
        return self.with_metadata(query,args)

class NIBRSNationalOffenderDenormRace(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalOffenderDenormRaceSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalOffenderDenormRace.query
        return self.with_metadata(query,args)

class NIBRSNationalOffenderDenormEthnicity(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalOffenderDenormEthnicitySchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalOffenderDenormEthnicity.query
        return self.with_metadata(query,args)

class NIBRSNationalOffenderDenormAge(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalOffenderDenormAgeSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalOffenderDenormAge.query
        return self.with_metadata(query,args)

class NIBRSStateVictimDenormCount(CdeResource):
    schema = marshmallow_schemas.NIBRSStateVictimDenormCountSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateVictimDenormCount.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class NIBRSStateVictimDenormSex(CdeResource):
    schema = marshmallow_schemas.NIBRSStateVictimDenormSexSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateVictimDenormSex.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class NIBRSStateVictimDenormRace(CdeResource):
    schema = marshmallow_schemas.NIBRSStateVictimDenormRaceSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateVictimDenormRace.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class NIBRSStateVictimDenormEthnicity(CdeResource):
    schema = marshmallow_schemas.NIBRSStateVictimDenormEthnicitySchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateVictimDenormEthnicity.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class NIBRSStateVictimDenormAge(CdeResource):
    schema = marshmallow_schemas.NIBRSStateVictimDenormAgeSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateVictimDenormAge.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class NIBRSStateVictimDenormLocation(CdeResource):
    schema = marshmallow_schemas.NIBRSStateVictimDenormLocationSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateVictimDenormLocation.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class NIBRSStateOffenderDenormCount(CdeResource):
    schema = marshmallow_schemas.NIBRSStateOffenderDenormCountSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateOffenderDenormCount.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class NIBRSStateOffenderDenormSex(CdeResource):
    schema = marshmallow_schemas.NIBRSStateOffenderDenormSexSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateOffenderDenormSex.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class NIBRSStateOffenderDenormRace(CdeResource):
    schema = marshmallow_schemas.NIBRSStateOffenderDenormRaceSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateOffenderDenormRace.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class NIBRSStateOffenderDenormEthnicity(CdeResource):
    schema = marshmallow_schemas.NIBRSStateOffenderDenormEthnicitySchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateOffenderDenormEthnicity.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)

class NIBRSStateOffenderDenormAge(CdeResource):
    schema = marshmallow_schemas.NIBRSStateOffenderDenormAgeSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateOffenderDenormAge.get(state_abbr=state_abbr)
        return self.with_metadata(query,args)
