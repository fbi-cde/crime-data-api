# -*- coding: utf-8 -*-
"""The app module, containing the app factory function."""
import csv
import io
from os import getenv

import flask_restful as restful
from flask import Flask, render_template
from flask_cors import CORS

import crime_data.resources.agencies
import crime_data.resources.incidents
import crime_data.resources.offenses
import crime_data.resources.codes
import crime_data.resources.arson
import crime_data.resources.offenders
import crime_data.resources.victims
import crime_data.resources.cargo_theft
import crime_data.resources.hate_crime
import crime_data.resources.geo
import crime_data.resources.participation
import crime_data.resources.estimates
import crime_data.resources.arrests
import crime_data.resources.meta
import crime_data.resources.summarized
import crime_data.resources.police_employment

import crime_data.resources.summarized
import crime_data.resources.police_employment
=
import crime_data.resources.nibrs_counts


import crime_data.resources.human_traffic
from werkzeug.contrib.fixers import ProxyFix

from crime_data import commands
from crime_data.common.marshmallow_schemas import ma
from crime_data.common.models import db
from crime_data.common.credentials import get_credential
from crime_data.extensions import (cache, cache_control)
from crime_data.settings import ProdConfig

if __name__ == '__main__':
    app.run(debug=True)  # nosec, this isn't called on production
    #app.wsgi_app = ProxyFix(app.wsgi_app)


def create_app(config_object=ProdConfig):
    """An application factory, as explained here: http://flask.pocoo.org/docs/patterns/appfactories/.

    :param config_object: The configuration object to use.
    """
    app = Flask(__name__)
    app.config.from_object(config_object)
    register_extensions(app)
    register_blueprints(app)
    register_errorhandlers(app)
    register_shellcontext(app)
    register_newrelic(app)
    add_resources(app)
    register_commands(app)
    db.init_app(app)

    @app.after_request
    def after_request(response):
        response.headers['Content-Security-Policy'] = "default-src 'self'"
        return response

    return app


def register_extensions(app):
    """Register Flask extensions."""
    cache.init_app(app)
    db.init_app(app)
    ma.init_app(app)
    cache_control.init_app(app)
    CORS(app)
    return None


def register_blueprints(app):
    """Register Flask blueprints."""
    return None


def register_errorhandlers(app):
    """Register error handlers."""

    def render_error(error):
        """Render error template."""
        # If a HTTPException, pull the `code` attribute; default to 500
        error_code = getattr(error, 'code', 500)
        return render_template('{0}.html'.format(error_code)), error_code

    for errcode in [401, 404, 500]:
        app.errorhandler(errcode)(render_error)
    return None


def register_shellcontext(app):
    """Register shell context objects."""

    def shell_context():
        """Shell context objects."""
        return {'db': db}

    app.shell_context_processor(shell_context)


def register_commands(app):
    """Register Click commands."""
    app.cli.add_command(commands.test)
    app.cli.add_command(commands.lint)
    app.cli.add_command(commands.clean)
    app.cli.add_command(commands.urls)


def add_resources(app):
    """Register API routes and Swagger endpoints"""
    api = restful.Api(app)

    @api.representation('text/csv')
    def output_csv(data, code, headers=None):
        """Curl with -H "Accept: text/csv" """
        outfile = io.StringIO()
        keys = data[0].keys()
        writer = csv.DictWriter(outfile, keys)
        writer.writerows(data)
        outfile.seek(0)
        resp = api.make_response(outfile.read(), code)
        resp.headers.extend(headers or {})
        return resp

    api.add_resource(crime_data.resources.agencies.AgenciesList, '/agencies')
    api.add_resource(crime_data.resources.participation.AgenciesParticipation,
                     '/agencies/participation',
                     '/participation/agencies')
    api.add_resource(crime_data.resources.agencies.AgenciesDetail,
                     '/agencies/<string:ori>')

    api.add_resource(crime_data.resources.incidents.AgenciesSumsState,
                     '/agencies/count/states/suboffenses/<string:state_abbr>/<string:agency_ori>','/agencies/count/states/suboffenses/<string:state_abbr>' )

    api.add_resource(crime_data.resources.incidents.AgenciesSumsCounty,
                     '/agencies/count/states/suboffenses/<string:state_abbr>/counties/<string:county_fips_code>' )

    api.add_resource(crime_data.resources.incidents.AgenciesOffensesCount,
                     '/agencies/count/<string:agency_ori>/offenses','/agencies/count/states/<string:state_abbr>/offenses' )

    api.add_resource(crime_data.resources.incidents.AgenciesOffensesCountyCount,
                     '/agencies/count/states/offenses/<string:state_abbr>/counties/<string:county_fips_code>' )

    api.add_resource(crime_data.resources.arrests.ArrestsNational, '/arrests/national')

    api.add_resource(crime_data.resources.offenses.OffensesList, '/offenses/')
    api.add_resource(crime_data.resources.codes.CodeReferenceIndex,
                     '/codes')
    api.add_resource(crime_data.resources.codes.CodeReferenceList,
                     '/codes/<string:code_table>.<string:output>',
                     '/codes/<string:code_table>')

    api.add_resource(crime_data.resources.arson.ArsonStateCounts,
                     '/arson/national', '/arson/states/<string:state_abbr>', '/arson/regions/<string:region_name>')

    api.add_resource(crime_data.resources.geo.StateDetail,
                     '/geo/states/<string:id>')
    api.add_resource(crime_data.resources.participation.StateParticipation,
                     '/participation/states/<string:state_abbr>')

    api.add_resource(crime_data.resources.participation.RegionParticipation,
                     '/participation/regions/<string:region_name>')

    api.add_resource(crime_data.resources.geo.CountyDetail,
                     '/geo/counties/<string:fips>')


    api.add_resource(crime_data.resources.participation.NationalParticipation,
                     '/participation/national')

    api.add_resource(crime_data.resources.estimates.EstimatesNational,
                     '/estimates/national')
    api.add_resource(crime_data.resources.estimates.EstimatesState,
                     '/estimates/states/<string:state_id>')
    api.add_resource(crime_data.resources.estimates.EstimatesRegion,
                     '/estimates/regions/<string:region_name>')

    api.add_resource(crime_data.resources.offenses.OffensesCountNational,
                     '/offenses/count/national/<string:variable>')
    api.add_resource(crime_data.resources.offenses.OffensesCountStates,
                     '/offenses/count/states/<int:state_id>/<string:variable>',
                     '/offenses/count/states/<string:state_abbr>/<string:variable>')
    api.add_resource(crime_data.resources.offenses.OffensesCountAgencies,
                     '/offenses/count/agencies/<string:ori>/<string:variable>')


    api.add_resource(crime_data.resources.offenders.OffendersCountNational,
                     '/offenders/count/national/<string:variable>')
    api.add_resource(crime_data.resources.offenders.OffendersCountStates,
                     '/offenders/count/states/<int:state_id>/<string:variable>',
                     '/offenders/count/states/<string:state_abbr>/<string:variable>')

    api.add_resource(crime_data.resources.victims.VictimsCountNational,
                     '/victims/count/national/<string:variable>')
    api.add_resource(crime_data.resources.victims.VictimsCountStates,
                     '/victims/count/states/<int:state_id>/<string:variable>',
                     '/victims/count/states/<string:state_abbr>/<string:variable>')
    api.add_resource(crime_data.resources.offenders.OffendersCountAgencies,
                     '/offenders/count/agencies/<string:ori>/<string:variable>')
    api.add_resource(crime_data.resources.victims.VictimsCountAgencies,
                     '/victims/count/agencies/<string:ori>/<string:variable>')

    api.add_resource(crime_data.resources.cargo_theft.CargoTheftsCountNational,
                     '/ct/count/national/<string:variable>')
    api.add_resource(crime_data.resources.cargo_theft.CargoTheftsCountAgencies,
                     '/ct/count/agencies/<string:ori>/<string:variable>')
    api.add_resource(crime_data.resources.cargo_theft.CargoTheftsCountStates,
                     '/ct/count/states/<int:state_id>/<string:variable>',
                     '/ct/count/states/<string:state_abbr>/<string:variable>')

    api.add_resource(crime_data.resources.hate_crime.HateCrimesCountNational,
                     '/hc/count/national/<string:variable>')
    api.add_resource(crime_data.resources.hate_crime.HateCrimesCountAgencies,
                     '/hc/count/agencies/<string:ori>/<string:variable>')
    api.add_resource(crime_data.resources.hate_crime.HateCrimesCountStates,
                     '/hc/count/states/<int:state_id>/<string:variable>',
                     '/hc/count/states/<string:state_abbr>/<string:variable>')

    api.add_resource(crime_data.resources.human_traffic.HtAgencyList,
                     '/ht/agencies')
    api.add_resource(crime_data.resources.human_traffic.HtStatesList,
                     '/ht/states')
    api.add_resource(crime_data.resources.victims.VictimOffenseSubcounts,
                     '/victims/count/states/<int:state_id>/<string:variable>/offenses',
                     '/victims/count/states/<string:state_abbr>/<string:variable>/offenses',
                     '/victims/count/agencies/<string:ori>/<string:variable>/offenses',
                     '/victims/count/national/<string:variable>/offenses')
    api.add_resource(crime_data.resources.offenders.OffenderOffenseSubcounts,
                     '/offenders/count/states/<int:state_id>/<string:variable>/offenses',
                     '/offenders/count/states/<string:state_abbr>/<string:variable>/offenses',
                     '/offenders/count/agencies/<string:ori>/<string:variable>/offenses',
                     '/offenders/count/national/<string:variable>/offenses')
    api.add_resource(crime_data.resources.offenses.OffenseByOffenseTypeSubcounts,
                     '/offenses/count/states/<int:state_id>/<string:variable>/offenses',
                     '/offenses/count/states/<string:state_abbr>/<string:variable>/offenses',
                     '/offenses/count/agencies/<string:ori>/<string:variable>/offenses',
                     '/offenses/count/national/<string:variable>/offenses')
    api.add_resource(crime_data.resources.hate_crime.HateCrimeOffenseSubcounts,
                     '/hc/count/states/<int:state_id>/<string:variable>/offenses',
                     '/hc/count/states/<string:state_abbr>/<string:variable>/offenses',
                     '/hc/count/agencies/<string:ori>/<string:variable>/offenses',
                     '/hc/count/national/<string:variable>/offenses')
    api.add_resource(crime_data.resources.cargo_theft.CargoTheftOffenseSubcounts,
                     '/ct/count/states/<int:state_id>/<string:variable>/offenses',
                     '/ct/count/states/<string:state_abbr>/<string:variable>/offenses',
                     '/ct/count/national/<string:variable>/offenses',
                     '/ct/count/agencies/<string:ori>/<string:variable>/offenses')
    api.add_resource(crime_data.resources.meta.RegionLK,'/lookup/region')
    api.add_resource(crime_data.resources.meta.StateLK,'/lookup/state')

    api.add_resource(crime_data.resources.summarized.SummarizedDataAgency,
                    '/summarized/agency/<string:state_abbr>/<string:ori>')

    api.add_resource(crime_data.resources.summarized.SummarizedDataState,
                    '/summarized/state/<string:state_abbr>')

    api.add_resource(crime_data.resources.summarized.SummarizedDataRegion,
                    '/summarized/region/<string:region_name>')

    api.add_resource(crime_data.resources.summarized.SummarizedDataNational,'/summarized')

    api.add_resource(crime_data.resources.agencies.Agencies,'/new/agencies', '/new/agencies/state/<string:state_abbr>','/new/agencies/ori/<string:ori>')

    api.add_resource(crime_data.resources.police_employment.PoliceEmploymentDataNation,'/police-employment')
    api.add_resource(crime_data.resources.police_employment.PoliceEmploymentDataRegion,'/police-employment/region/<string:region_name>')
    api.add_resource(crime_data.resources.police_employment.PoliceEmploymentDataState,'/police-employment/state/<string:state_abbr>')
    api.add_resource(crime_data.resources.police_employment.PoliceEmploymentDataAgency,'/police-employment/agency/<string:state_abbr>/<string:ori>')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSAgencyVictimDenormCount,'/nibrs/victim/count/agencies/<string:ori>')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSAgencyVictimDenormSex,'/nibrs/victim/count/agencies/<string:ori>/sex')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSAgencyVictimDenormAge,'/nibrs/victim/count/agencies/<string:ori>/age')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSAgencyVictimDenormRace,'/nibrs/victim/count/agencies/<string:ori>/race')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSAgencyVictimDenormEthnicity,'/nibrs/victim/count/agencies/<string:ori>/ethnicity')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSAgencyVictimDenormLocation,'/nibrs/victim/count/agencies/<string:ori>/location')

    api.add_resource(crime_data.resources.nibrs_counts.NIBRSAgencyOffenderDenormCount,'/nibrs/offender/count/agencies/<string:ori>')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSAgencyOffenderDenormSex,'/nibrs/offender/count/agencies/<string:ori>/sex')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSAgencyOffenderDenormAge,'/nibrs/offender/count/agencies/<string:ori>/age')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSAgencyOffenderDenormRace,'/nibrs/offender/count/agencies/<string:ori>/race')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSAgencyOffenderDenormEthnicity,'/nibrs/offender/count/agencies/<string:ori>/ethnicity')

    api.add_resource(crime_data.resources.nibrs_counts.NIBRSStateVictimDenormCount,'/nibrs/victim/count/states/<string:state_abbr>')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSStateVictimDenormSex,'/nibrs/victim/count/states/<string:state_abbr>/sex')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSStateVictimDenormAge,'/nibrs/victim/count/states/<string:state_abbr>/age')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSStateVictimDenormRace,'/nibrs/victim/count/states/<string:state_abbr>/race')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSStateVictimDenormEthnicity,'/nibrs/victim/count/states/<string:state_abbr>/ethnicity')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSStateVictimDenormLocation,'/nibrs/victim/count/states/<string:state_abbr>/location')

    api.add_resource(crime_data.resources.nibrs_counts.NIBRSStateOffenderDenormCount,'/nibrs/offender/count/states/<string:state_abbr>')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSStateOffenderDenormSex,'/nibrs/offender/count/states/<string:state_abbr>/sex')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSStateOffenderDenormAge,'/nibrs/offender/count/states/<string:state_abbr>/age')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSStateOffenderDenormRace,'/nibrs/offender/count/states/<string:state_abbr>/race')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSStateOffenderDenormEthnicity,'/nibrs/offender/count/states/<string:state_abbr>/ethnicity')

    api.add_resource(crime_data.resources.nibrs_counts.NIBRSNationalVictimDenormCount,'/nibrs/victim/count/national')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSNationalVictimDenormSex,'/nibrs/victim/count/national/sex')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSNationalVictimDenormAge,'/nibrs/victim/count/national/age')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSNationalVictimDenormRace,'/nibrs/victim/count/national/race')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSNationalVictimDenormEthnicity,'/nibrs/victim/count/national/ethnicity')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSNationalVictimDenormLocation,'/nibrs/victim/count/national/location')

    api.add_resource(crime_data.resources.nibrs_counts.NIBRSNationalOffenderDenormCount,'/nibrs/offender/count/national')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSNationalOffenderDenormSex,'/nibrs/offender/count/national/sex')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSNationalOffenderDenormAge,'/nibrs/offender/count/national/age')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSNationalOffenderDenormRace,'/nibrs/offender/count/national/race')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSNationalOffenderDenormEthnicity,'/nibrs/offender/count/national/ethnicity')

    api.add_resource(crime_data.resources.nibrs_counts.NIBRSStateDenormVictimOffenderRelationship,'/nibrs/victim/count/states/<string:state_abbr>/relationships')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSAgencyDenormVictimOffenderRelationship,'/nibrs/victim/count/agencies/<string:ori>/relationships')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSNationalDenormVictimOffenderRelationship,'/nibrs/victim/count/national/relationships')

    api.add_resource(crime_data.resources.nibrs_counts.NIBRSStateOffenseCount,'/nibrs/offense/count/states/<string:state_abbr>')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSAgencyOffenseCount,'/nibrs/offense/count/agencies/<string:ori>')
    api.add_resource(crime_data.resources.nibrs_counts.NIBRSNationalOffenseCount,'/nibrs/offense/count/national')


def newrelic_status_endpoint():
    return 'OK'


def register_newrelic(app):
    """Setup New Relic monitoring for the application"""

    app.add_url_rule('/status', 'status', newrelic_status_endpoint)

    try:
        license_key = get_credential('NEW_RELIC_API_KEY')
        import newrelic.agent
        settings = newrelic.agent.global_settings()
        settings.license_key = license_key
        newrelic.agent.initialize()
    except: #nosec
        pass


from flask.helpers import get_debug_flag

from crime_data.settings import DevConfig, ProdConfig

CONFIG = DevConfig if get_debug_flag() else ProdConfig

app = create_app(CONFIG)
app.wsgi_app = ProxyFix(app.wsgi_app)

# Add some static routing
@app.route('/swagger.json')
def swagger_json():
    return app.send_static_file('swagger.json')
