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
    def get(self, args, ori=None, crime=None):
        self.verify_api_key(args)
        offenses=args.get('offenses', None)
        print('offenses'+offenses)
        query = cdemodels.NIBRSAgencyVictimDenormCount.get(ori=ori,crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSAgencyVictimDenormSex(CdeResource):
    schema = marshmallow_schemas.NIBRSAgencyVictimDenormSexSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSAgencyVictimDenormSex.get(ori=ori,crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSAgencyVictimDenormRace(CdeResource):
    schema = marshmallow_schemas.NIBRSAgencyVictimDenormRaceSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSAgencyVictimDenormRace.get(ori=ori,crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSAgencyVictimDenormEthnicity(CdeResource):
    schema = marshmallow_schemas.NIBRSAgencyVictimDenormEthnicitySchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSAgencyVictimDenormEthnicity.get(ori=ori,crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSAgencyVictimDenormAge(CdeResource):
    schema = marshmallow_schemas.NIBRSAgencyVictimDenormAgeSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSAgencyVictimDenormAge.get(ori=ori,crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSAgencyVictimDenormLocation(CdeResource):
    schema = marshmallow_schemas.NIBRSAgencyVictimDenormLocationSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSAgencyVictimDenormLocation.get(ori=ori,crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSAgencyOffenderDenormCount(CdeResource):
    schema = marshmallow_schemas.NIBRSAgencyOffenderDenormCountSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSAgencyOffenderDenormCount.get(ori=ori,crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSAgencyOffenderDenormSex(CdeResource):
    schema = marshmallow_schemas.NIBRSAgencyOffenderDenormSexSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSAgencyOffenderDenormSex.get(ori=ori,crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSAgencyOffenderDenormRace(CdeResource):
    schema = marshmallow_schemas.NIBRSAgencyOffenderDenormRaceSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSAgencyOffenderDenormRace.get(ori=ori,crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSAgencyOffenderDenormEthnicity(CdeResource):
    schema = marshmallow_schemas.NIBRSAgencyOffenderDenormEthnicitySchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSAgencyOffenderDenormEthnicity.get(ori=ori,crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSAgencyOffenderDenormAge(CdeResource):
    schema = marshmallow_schemas.NIBRSAgencyOffenderDenormAgeSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSAgencyOffenderDenormAge.get(ori=ori, crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSNationalVictimDenormCount(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalVictimDenormCountSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalVictimDenormCount.get(crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSNationalVictimDenormSex(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalVictimDenormSexSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalVictimDenormSex.get(crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSNationalVictimDenormRace(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalVictimDenormRaceSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalVictimDenormRace.get(crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSNationalVictimDenormEthnicity(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalVictimDenormEthnicitySchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalVictimDenormEthnicity.get(crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSNationalVictimDenormAge(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalVictimDenormAgeSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalVictimDenormAge.get(crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSNationalVictimDenormLocation(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalVictimDenormLocationSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalVictimDenormLocation.get(crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSNationalOffenderDenormCount(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalOffenderDenormCountSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalOffenderDenormCount.get(crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSNationalOffenderDenormSex(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalOffenderDenormSexSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalOffenderDenormSex.get(crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSNationalOffenderDenormRace(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalOffenderDenormRaceSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalOffenderDenormRace.get(crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSNationalOffenderDenormEthnicity(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalOffenderDenormEthnicitySchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalOffenderDenormEthnicity.get(crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSNationalOffenderDenormAge(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalOffenderDenormAgeSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalOffenderDenormAge.get(crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSStateVictimDenormCount(CdeResource):
    schema = marshmallow_schemas.NIBRSStateVictimDenormCountSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateVictimDenormCount.get(state_abbr=state_abbr, crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSStateVictimDenormSex(CdeResource):
    schema = marshmallow_schemas.NIBRSStateVictimDenormSexSchema(many=True)
    @use_args(marshmallow_schemas.ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateVictimDenormSex.get(state_abbr=state_abbr, crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSStateVictimDenormRace(CdeResource):
    schema = marshmallow_schemas.NIBRSStateVictimDenormRaceSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateVictimDenormRace.get(state_abbr=state_abbr, crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSStateVictimDenormEthnicity(CdeResource):
    schema = marshmallow_schemas.NIBRSStateVictimDenormEthnicitySchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateVictimDenormEthnicity.get(state_abbr=state_abbr,crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSStateVictimDenormAge(CdeResource):
    schema = marshmallow_schemas.NIBRSStateVictimDenormAgeSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateVictimDenormAge.get(state_abbr=state_abbr,crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSStateVictimDenormLocation(CdeResource):
    schema = marshmallow_schemas.NIBRSStateVictimDenormLocationSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateVictimDenormLocation.get(state_abbr=state_abbr,crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSStateOffenderDenormCount(CdeResource):
    schema = marshmallow_schemas.NIBRSStateOffenderDenormCountSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateOffenderDenormCount.get(state_abbr=state_abbr,crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSStateOffenderDenormSex(CdeResource):
    schema = marshmallow_schemas.NIBRSStateOffenderDenormSexSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateOffenderDenormSex.get(state_abbr=state_abbr,crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSStateOffenderDenormRace(CdeResource):
    schema = marshmallow_schemas.NIBRSStateOffenderDenormRaceSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateOffenderDenormRace.get(state_abbr=state_abbr,crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSStateOffenderDenormEthnicity(CdeResource):
    schema = marshmallow_schemas.NIBRSStateOffenderDenormEthnicitySchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateOffenderDenormEthnicity.get(state_abbr=state_abbr,crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSStateOffenderDenormAge(CdeResource):
    schema = marshmallow_schemas.NIBRSStateOffenderDenormAgeSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateOffenderDenormAge.get(state_abbr=state_abbr,crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSNationalOffenseCount(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalOffenseCountSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalOffenseCount.get(crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSAgencyOffenseCount(CdeResource):
    schema = marshmallow_schemas.NIBRSAgencyOffenseCountSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSAgencyOffenseCount.get(ori=ori,crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSStateOffenseCount(CdeResource):
    schema = marshmallow_schemas.NIBRSStateOffenseCountSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateOffenseCount.get(state_abbr=state_abbr,crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSStateDenormVictimOffenderRelationship(CdeResource):
    schema = marshmallow_schemas.NIBRSStateDenormVictimOffenderRelationshipSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, state_abbr=None, crime=None):
        self.verify_api_key(args)
        query = cdemodels.NIBRSStateDenormVictimOffenderRelationship.get(state_abbr=state_abbr,crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSNationalDenormVictimOffenderRelationship(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalDenormVictimOffenderRelationshipSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args):
        self.verify_api_key(args)
        query = cdemodels.NIBRSNationalDenormVictimOffenderRelationship.get(crime=get_offenses(crime))
        return self.with_metadata(query,args)

class NIBRSAgencyDenormVictimOffenderRelationship(CdeResource):
    schema = marshmallow_schemas.NIBRSNationalDenormVictimOffenderRelationshipSchema(many=True)
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, ori=None, crime=None):
        self.ver.pyy_api_key(args)
        query = cdemodels.NIBRSAgencyDenormVictimOffenderRelationship.get(ori=ori,crime=get_offenses(crime))
        return self.with_metadata(query,args)


def get_offenses(offense):
    if offense == 'aggravated-assault':
        return ['Aggravated Assault']
    elif offense == 'burglary':
     return ['Burglary/Breaking & Entering']
    elif offense == 'larceny':
      return [
        'Not Specified',
        'Theft of Motor Vehicle Parts or Accessories',
        'Pocket-picking',
        'Theft From Motor Vehicle',
        'Purse-snatching',
        'Shoplifting',
        'All Other Larceny',
        'Theft From Building',
        'Theft From Coin-Operated Machine or Device',
      ]
    elif offense == 'motor-vehicle-theft':
      return ['Motor Vehicle Theft']
    elif offense == 'homicide':
      return ['Murder and Nonnegligent Manslaughter']
    elif offense == 'rape':
      return ['Rape', 'Sexual Assault With An Object', 'Sodomy']
    elif offense == 'robbery':
      return ['Robbery']
    elif offense == 'arson':
      return ['Arson']
    return
