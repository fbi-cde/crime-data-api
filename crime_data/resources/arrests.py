from webargs.flaskparser import use_args
import flask_apispec as swagger
from crime_data.extensions import DEFAULT_MAX_AGE
from flask.ext.cachecontrol import cache

from crime_data.common import cdemodels, marshmallow_schemas
from crime_data.common.base import CdeResource, tuning_page


class ArrestsCountResource(CdeResource):

    is_groupable = True

    @use_args(marshmallow_schemas.GroupableArgsSchema)
    @swagger.use_kwargs(marshmallow_schemas.GroupableArgsSchema, apply=False, locations=['query'])
    @swagger.doc(tags=['arrests'],
                 description='Returns counts of arrests. These can be grouped further with the by column.')
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args):
        return self._get(args)


class ArrestsCountByRace(ArrestsCountResource):

    tables = cdemodels.ArrestsByRaceTableFamily()

    @use_args(marshmallow_schemas.GroupableArgsSchema)
    @swagger.use_kwargs(marshmallow_schemas.GroupableArgsSchema, apply=False, locations=['query'])
    @swagger.doc(tags=['arrests'],
                 description='Returns counts of arrests. These can be grouped further with the by column.')
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args):
        return self._get(args)


class ArrestsCountByEthnicity(ArrestsCountResource):

    tables = cdemodels.ArrestsByEthnicityTableFamily()

    @use_args(marshmallow_schemas.GroupableArgsSchema)
    @swagger.use_kwargs(marshmallow_schemas.GroupableArgsSchema, apply=False, locations=['query'])
    @swagger.doc(tags=['arrests'],
                 description='Returns counts of arrests. These can be grouped further with the by column.')
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args):
        return self._get(args)


class ArrestsCountByAgeSex(ArrestsCountResource):

    tables = cdemodels.ArrestsByAgeSexTableFamily()

    @use_args(marshmallow_schemas.GroupableArgsSchema)
    @swagger.use_kwargs(marshmallow_schemas.GroupableArgsSchema, apply=False, locations=['query'])
    @swagger.doc(tags=['arrests'],
                 description='Returns counts of arrests. These can be grouped further with the by column.')
    @cache(max_age=DEFAULT_MAX_AGE, public=True)
    @tuning_page
    def get(self, args):
        return self._get(args)



"""
Big (?) problem here: whole different set of classification codes
for different domains.

# select offense_subcat_code, offense_subcat_name from reta_offense_subcat order by offense_subcat_code;
;
 offense_subcat_code |          offense_subcat_name
---------------------+---------------------------------------
 SUM_ASS_CUT         | Assault - Knife or Cutting Instrument
 SUM_ASS_GUN         | Assault - Firearm
 SUM_ASS_HFF         | Assault - Hands, Fists, Feet
 SUM_ASS_NS          | Assault - Not Specified
 SUM_ASS_OTH         | Assault - Other Dangerous Weapon
 SUM_ASS_SMP         | Simple Assault
 SUM_BRG_AFE         | Burglary - Attempted Forcible Entry
 SUM_BRG_FEO         | Burglary - Forcible Entry
 SUM_BRG_NS          | Burglary - Not Specified
 SUM_BRG_UEO         | Burglary - No Force
 SUM_HOM             | Murder and Nonnegligent Homicide
 SUM_HT_NS           | Human Trafficking - Not Specified
 SUM_HT_SEX          | Commercial Sex Acts
 SUM_HT_SRV          | Involuntary Servitude
 SUM_LAR_TFT         | Larceny - Theft
 SUM_MAN             | Manslaughter by Negligence
 SUM_MTR_ATO         | Auto Theft
 SUM_MTR_NS          | Motor Vehicle Theft - Not Specified
 SUM_MTR_OTH         | Other Vehicle Theft
 SUM_MTR_TRK         | Truck and Bus Theft
 SUM_ROB_CUT         | Robbery - Knife or Cutting Instrument
 SUM_ROB_GUN         | Robbery - Firearm
 SUM_ROB_HFF         | Robbery - Hands, Fists, Feet
 SUM_ROB_NS          | Robbery - Not Specified
 SUM_ROB_OTH         | Robbery - Other Dangerous Weapon
 SUM_RPE_ATT         | Attempted Rape
 SUM_RPE_ATT_LEG     | Attempted Rape
 SUM_RPE_FRC         | Rape
 SUM_RPE_FRC_LEG     | Rape
 SUM_RPE_NS          | Rape - Not Specified
 SUM_RPE_NS_LEG      | Rape - Not Specified
 SUM_UNKNOWN         | Not Specified
(32 rows)


# select offense_subcat_code, offense_subcat_name from asr_offense_subcat order by offense_subcat_code;
 offense_subcat_code |                            offense_subcat_name
---------------------+----------------------------------------------------------------------------
 ASR_ARSON           | Arson
 ASR_AST             | Aggravated Assault
 ASR_AST_SMP         | Simple Assault
 ASR_BRG             | Burglary - Breaking or Entering
 ASR_CUR             | Curfew and Loitering Law Violations
 ASR_DIS             | Disorderly Conduct
 ASR_DRG             | Drug Abuse Violations - Not Specified
 ASR_DRG_MAN         | Drug Sale/Manufacturing - Not Specified
 ASR_DRG_MAN_CKE     | Drug Sale/Manufacturing - Opium or Cocaine or Their Derivatives
 ASR_DRG_MAN_MAR     | Drug Sale/Manufacturing - Marijuana
 ASR_DRG_MAN_OTH     | Drug Sale/Manufacturing - Other - Dangerous Nonnarcotic Drugs
 ASR_DRG_MAN_SYN     | Drug Sale/Manufacturing - Synthetic Narcotics
 ASR_DRG_POS         | Drug Possession - Not Specified
 ASR_DRG_POS_CKE     | Drug Possession - Opium or Cocaine or Their Derivatives
 ASR_DRG_POS_MAR     | Drug Possession - Marijuana
 ASR_DRG_POS_OTH     | Drug Possession - Other - Dangerous Nonnarcotic Drugs
 ASR_DRG_POS_SYN     | Drug Possession - Synthetic Narcotics
 ASR_DRK             | Drunkenness
 ASR_DUI             | Driving Under the Influence
 ASR_EMB             | Embezzlement
 ASR_FAM             | Offenses Against the Family and Children
 ASR_FOR             | Forgery and Counterfeiting
 ASR_FRD             | Fraud
 ASR_GAM             | Gambling - Not Specified
 ASR_GAM_BK          | Gambling - Bookmaking (Horse and Sport Book)
 ASR_GAM_LOT         | Gambling - Numbers and Lottery
 ASR_GAM_OTH         | Gambling - All Other Gambling
 ASR_HOM             | Murder and Nonnegligent Manslaughter
 ASR_HT_SEX          | Human Trafficking - Commercial Sex Acts
 ASR_HT_SRV          | Human Trafficking - Involuntary Servitude
 ASR_JUV_DIS         | Juvenile Disposition
 ASR_LIQ             | Liquor Laws
 ASR_LRC             | Larceny - Theft
 ASR_MAN             | Manslaughter by Negligence
 ASR_MVT             | Motor Vehicle Theft
 ASR_OTH             | All Other Offenses (Except Traffic)
 ASR_PRS             | Prostitution and Commercialized Vice
 ASR_PRS_PMP         | Prostitution and Commercialized Vice - Assisting or Promoting Prostitution
 ASR_PRS_PRO         | Prostitution and Commercialized Vice - Prostitution
 ASR_PRS_PUR         | Prostitution and Commercialized Vice - Purchasing Prostitution
 ASR_ROB             | Robbery
 ASR_RPE             | Rape
 ASR_RUN             | Runaway
 ASR_SEX             | Sex Offenses (Except Rape, and Prostitution and Commercialized Vice)
 ASR_STP             | Stolen Property: Buying, Receiving, Possessing
 ASR_SUS             | Suspicion
 ASR_VAG             | Vagrancy
 ASR_VAN             | Vandalism
 ASR_WEAP            | Weapons: Carrying, Possessing, Etc.
 ASR_ZERO            | Zero Report
"""
