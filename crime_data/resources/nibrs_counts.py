from webargs.flaskparser import use_args
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache
from sqlalchemy import func

from crime_data.common import cdemodels, marshmallow_schemas, munger
from crime_data.common.base import CdeResource, tuning_page
from crime_data.common.marshmallow_schemas import ArgumentsSchema

class NIBRSCountNational(CdeResource):
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, variable,queryType, offense_name=None):
        self.verify_api_key(args)
        if queryType == 'victim' and variable == 'count':
            self.set_schema(marshmallow_schemas.NIBRSNationalVictimDenormCountSchema(many=True))
            query = cdemodels.NIBRSNationalVictimDenormCount.get(offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_count','')
        elif queryType == 'victim' and variable == 'sex':
            self.set_schema(marshmallow_schemas.NIBRSNationalVictimDenormSexSchema(many=True))
            query = cdemodels.NIBRSNationalVictimDenormSex.get(offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_sex','')
        elif queryType =='victim' and variable == 'race':
            self.set_schema(marshmallow_schemas.NIBRSNationalVictimDenormRaceSchema(many=True))
            query = cdemodels.NIBRSNationalVictimDenormRace.get(offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_race','')
        elif queryType == 'victim' and variable == 'ethnicity':
            self.set_schema(marshmallow_schemas.NIBRSNationalVictimDenormEthnicitySchema(many=True))
            query = cdemodels.NIBRSNationalVictimDenormEthnicity.get(offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_ethnicity','')
        elif queryType == 'victim' and variable == 'age':
            self.set_schema(marshmallow_schemas.NIBRSNationalVictimDenormAgeSchema(many=True))
            query = cdemodels.NIBRSNationalVictimDenormAge.get(offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_age','')
        elif queryType == 'victim' and variable == 'location':
            self.set_schema(marshmallow_schemas.NIBRSNationalVictimDenormLocationSchema(many=True))
            query = cdemodels.NIBRSNationalVictimDenormLocation.get(offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_location','')
        elif queryType == 'offender' and variable == 'count':
            self.set_schema(marshmallow_schemas.NIBRSNationalOffenderDenormCountSchema(many=True))
            query = cdemodels.NIBRSNationalOffenderDenormCount.get(offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_count','')
        elif queryType == 'offender' and variable == 'sex':
            self.set_schema(marshmallow_schemas.NIBRSNationalOffenderenormSexSchema(many=True))
            query = cdemodels.NIBRSNationalOffenderDenormSex.get(offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_sex','')
        elif queryType == 'offender' and variable == 'race':
            self.set_schema(marshmallow_schemas.NIBRSNationalOffenderDenormRaceSchema(many=True))
            query = cdemodels.NIBRSNationalOffenderDenormRace.get(offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_race','')
        elif queryType == 'offender' and variable == 'ethnicity':
            self.set_schema(marshmallow_schemas.NIBRSNationalOffenderDenormEthnicitySchema(many=True))
            query = cdemodels.NIBRSNationalOffenderDenormEthnicity.get(offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_ethnicity','')
        elif queryType == 'offender' and variable == 'age':
            self.set_schema(marshmallow_schemas.NIBRSNationalOffenderDenormAgeSchema(many=True))
            query = cdemodels.NIBRSNationalOffenderDenormAge.get(offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_age','')
        elif queryType == 'offender' and variable == 'location':
            self.set_schema(marshmallow_schemas.NIBRSNationalVictimDenormLocationSchema(many=True))
            query = cdemodels.NIBRSNationalVictimDenormLocation.get(offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_location','')
        elif queryType == 'offense' and variable == 'count':
            self.set_schema(marshmallow_schemas.NIBRSNationalOffenseCountSchema(many=True))
            query = cdemodels.NIBRSNationalOffenseCount.get(offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_offense_count','')
        elif queryType == 'victim' and variable == 'relationships':
            self.set_schema(marshmallow_schemas.NIBRSNationalDenormVictimOffenderRelationshipSchema(many=True))
            query = cdemodels.NIBRSNationalDenormVictimOffenderRelationship.get(offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_relatiopnship','')
        else:
            return self.with_metadata([], args)
        ui = creator.munge_set()
        return self.without_metadata(ui, args)


class NIBRSCountState(CdeResource):
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, variable,queryType,state_abbr=None, offense_name=None):
        self.verify_api_key(args)
        if queryType == 'victim' and variable == 'count':
            self.set_schema(marshmallow_schemas.NIBRSStateVictimDenormCountSchema(many=True))
            query = cdemodels.NIBRSStateVictimDenormCount.get(state_abbr=state_abbr,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_count','')
        elif queryType == 'victim' and variable == 'sex':
            self.set_schema(marshmallow_schemas.NIBRSStateVictimDenormSexSchema(many=True))
            query = cdemodels.NIBRSStateVictimDenormSex.get(state_abbr=state_abbr,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_sex','')
        elif queryType =='victim' and variable == 'race':
            self.set_schema(marshmallow_schemas.NIBRSStateVictimDenormRaceSchema(many=True))
            query = cdemodels.NIBRSStateVictimDenormRace.get(state_abbr=state_abbr,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_race','')
        elif queryType == 'victim' and variable == 'ethnicity':
            self.set_schema(marshmallow_schemas.NIBRSStateVictimDenormEthnicitySchema(many=True))
            query = cdemodels.NIBRSStateVictimDenormEthnicity.get(state_abbr=state_abbr,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_ethnicity','')
        elif queryType == 'victim' and variable == 'age':
            self.set_schema(marshmallow_schemas.NIBRSStateVictimDenormAgeSchema(many=True))
            query = cdemodels.NIBRSStateVictimDenormAge.get(state_abbr=state_abbr,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_age','')
        elif queryType == 'victim' and variable == 'location':
            self.set_schema(marshmallow_schemas.NIBRSStateVictimDenormLocationSchema(many=True))
            query = cdemodels.NIBRSStateVictimDenormLocation.get(state_abbr=state_abbr,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_location','')
        elif queryType == 'offender' and variable == 'count':
            self.set_schema(marshmallow_schemas.NIBRSStateOffenderDenormCountSchema(many=True))
            query = cdemodels.NIBRSStateOffenderDenormCount.get(state_abbr=state_abbr,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_count','')
        elif queryType == 'offender' and variable == 'sex':
            self.set_schema(marshmallow_schemas.NIBRSStateOffenderDenormSexSchema(many=True))
            query = cdemodels.NIBRSStateOffenderDenormSex.get(state_abbr=state_abbr,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_sex','')
        elif queryType == 'offender' and variable == 'race':
            self.set_schema(marshmallow_schemas.NIBRSStateOffenderDenormRaceSchema(many=True))
            query = cdemodels.NIBRSStateOffenderDenormRace.get(state_abbr=state_abbr,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_race','')
        elif queryType == 'offender' and variable == 'ethnicity':
            self.set_schema(marshmallow_schemas.NIBRSStateOffenderDenormEthnicitySchema(many=True))
            query = cdemodels.NIBRSStateOffenderDenormEthnicity.get(state_abbr=state_abbr,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_ethnicity','')
        elif queryType == 'offender' and variable == 'age':
            self.set_schema(marshmallow_schemas.NIBRSStateOffenderDenormAgeSchema(many=True))
            query = cdemodels.NIBRSStateOffenderDenormAge.get(state_abbr=state_abbr,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_age','')
        elif queryType == 'offender' and variable == 'location':
            self.set_schema(marshmallow_schemas.NIBRSStateVictimDenormLocationSchema(many=True))
            query = cdemodels.NIBRSStateVictimDenormLocation.get(state_abbr=state_abbr,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_location','')
        elif queryType == 'offense' and variable == 'count':
            self.set_schema(marshmallow_schemas.NIBRSStateOffenseCountSchema(many=True))
            query = cdemodels.NIBRSStateOffenseCount.get(state_abbr=state_abbr,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_offense_count','')
        elif queryType == 'victim' and variable == 'relationships':
            self.set_schema(marshmallow_schemas.NIBRSStateDenormVictimOffenderRelationshipSchema(many=True))
            query = cdemodels.NIBRSStateDenormVictimOffenderRelationship.get(state_abbr=state_abbr,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_relatiopnship','')
        else:
            return self.with_metadata([], args)
        ui = creator.munge_set()
        return self.without_metadata(ui, args)

class NIBRSCountAgency(CdeResource):
    @use_args(ArgumentsSchema)
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    def get(self, args, variable,queryType,ori=None, offense_name=None):
        self.verify_api_key(args)
        if queryType == 'victim' and variable == 'count':
            self.set_schema(marshmallow_schemas.NIBRSAgencyVictimDenormCountSchema(many=True))
            query = cdemodels.NIBRSAgencyVictimDenormCount.get(ori=ori,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_count','')
        elif queryType == 'victim' and variable == 'sex':
            self.set_schema(marshmallow_schemas.NIBRSAgencyVictimDenormSexSchema(many=True))
            query = cdemodels.NIBRSAgencyVictimDenormSex.get(ori=ori,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_sex','')
        elif queryType =='victim' and variable == 'race':
            self.set_schema(marshmallow_schemas.NIBRSAgencyVictimDenormRaceSchema(many=True))
            query = cdemodels.NIBRSAgencyVictimDenormRace.get(ori=ori,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_race','')
        elif queryType == 'victim' and variable == 'ethnicity':
            self.set_schema(marshmallow_schemas.NIBRSAgencyVictimDenormEthnicitySchema(many=True))
            query = cdemodels.NIBRSAgencyVictimDenormEthnicity.get(ori=ori,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_ethnicity','')
        elif queryType == 'victim' and variable == 'age':
            self.set_schema(marshmallow_schemas.NIBRSAgencyVictimDenormAgeSchema(many=True))
            query = cdemodels.NIBRSAgencyVictimDenormAge.get(ori=ori,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_age','')
        elif queryType == 'victim' and variable == 'location':
            self.set_schema(marshmallow_schemas.NIBRSAgencyVictimDenormLocationSchema(many=True))
            query = cdemodels.NIBRSAgencyVictimDenormLocation.get(ori=ori,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_location','')
        elif queryType == 'offender' and variable == 'count':
            self.set_schema(marshmallow_schemas.NIBRSAgencyOffenderDenormCountSchema(many=True))
            query = cdemodels.NIBRSAgencyOffenderDenormCount.get(ori=ori,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_count','')
        elif queryType == 'offender' and variable == 'sex':
            self.set_schema(marshmallow_schemas.NIBRSAgencyOffenderenormSexSchema(many=True))
            query = cdemodels.NIBRSAgencyOffenderDenormSex.get(ori=ori,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_sex','')
        elif queryType == 'offender' and variable == 'race':
            self.set_schema(marshmallow_schemas.NIBRSAgencyOffenderDenormRaceSchema(many=True))
            query = cdemodels.NIBRSAgencyOffenderDenormRace.get(ori=ori,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_race','')
        elif queryType == 'offender' and variable == 'ethnicity':
            self.set_schema(marshmallow_schemas.NIBRSAgencyOffenderDenormEthnicitySchema(many=True))
            query = cdemodels.NIBRSAgencyOffenderDenormEthnicity.get(ori=ori,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_ethnicity','')
        elif queryType == 'offender' and variable == 'age':
            self.set_schema(marshmallow_schemas.NIBRSAgencyOffenderDenormAgeSchema(many=True))
            query = cdemodels.NIBRSAgencyOffenderDenormAge.get(ori=ori,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_age','')
        elif queryType == 'offender' and variable == 'location':
            self.set_schema(marshmallow_schemas.NIBRSAgencyVictimDenormLocationSchema(many=True))
            query = cdemodels.NIBRSAgencyVictimDenormLocation.get(ori=ori,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_location','')
        elif queryType == 'offense' and variable == 'count':
            self.set_schema(marshmallow_schemas.NIBRSAgencyOffenseCountSchema(many=True))
            query = cdemodels.NIBRSAgencyOffenseCount.get(ori=ori,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_offense_count','')
        elif queryType == 'victim' and variable == 'relationships':
            self.set_schema(marshmallow_schemas.NIBRSAgencyDenormVictimOffenderRelationshipSchema(many=True))
            query = cdemodels.NIBRSAgencyDenormVictimOffenderRelationship.get(ori=ori,offense_name=get_offenses(offense_name))
            creator = munger.UIComponentCreator(query.all(),'nibrs_relatiopnship','')
        else:
            return self.with_metadata([], args)
        ui = creator.munge_set()
        return self.without_metadata(ui, args)

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
