import crime_data.resources.beta.agencies
#import arrests
import crime_data.resources.beta.incidents
import crime_data.resources.beta.offenses
import crime_data.resources.beta.codes
import crime_data.resources.beta.arson
import crime_data.resources.beta.offenders
import crime_data.resources.beta.victims
import crime_data.resources.beta.cargo_theft
import crime_data.resources.beta.hate_crime
import crime_data.resources.beta.geo
import crime_data.resources.beta.participation
import crime_data.resources.beta.estimates
import crime_data.resources.beta.human_traffic

def register_api_endpoints(api):
    """Register API routes on an Restful API object"""
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

    api.add_resource(agencies.AgenciesList, '/agencies')
    api.add_resource(participation.AgenciesParticipation,
                     '/agencies/participation',
                     '/participation/agencies')
    api.add_resource(agencies.AgenciesDetail,
                     '/agencies/<string:ori>')

    api.add_resource(incidents.AgenciesSumsState,
                     '/agencies/count/states/suboffenses/<string:state_abbr>/<string:agency_ori>','/agencies/count/states/suboffenses/<string:state_abbr>' )

    api.add_resource(incidents.AgenciesSumsCounty,
                     '/agencies/count/states/suboffenses/<string:state_abbr>/counties/<string:county_fips_code>' )

    api.add_resource(incidents.AgenciesOffensesCount,
                     '/agencies/count/<string:agency_ori>/offenses','/agencies/count/states/<string:state_abbr>/offenses' )

    api.add_resource(incidents.AgenciesOffensesCountyCount,
                     '/agencies/count/states/offenses/<string:state_abbr>/counties/<string:county_fips_code>' )

    api.add_resource(arson.ArsonStateCounts,
                     '/arson/national', '/arson/states/<string:state_abbr>')

    api.add_resource(offenses.OffensesList, '/offenses/')
    api.add_resource(codes.CodeReferenceIndex,
                     '/codes')
    api.add_resource(codes.CodeReferenceList,
                     '/codes/<string:code_table>.<string:output>',
                     '/codes/<string:code_table>')

    api.add_resource(geo.StateDetail,
                     '/geo/states/<string:id>')
    api.add_resource(participation.StateParticipation,
                     '/participation/states/<string:state_abbr>')

    api.add_resource(geo.CountyDetail,
                     '/geo/counties/<string:fips>')


    api.add_resource(participation.NationalParticipation,
                     '/participation/national')

    api.add_resource(estimates.EstimatesNational,
                     '/estimates/national')
    api.add_resource(estimates.EstimatesState,
                     '/estimates/states/<string:state_id>')


    api.add_resource(offenses.OffensesCountNational,
                     '/offenses/count/national/<string:variable>')
    api.add_resource(offenses.OffensesCountStates,
                     '/offenses/count/states/<int:state_id>/<string:variable>',
                     '/offenses/count/states/<string:state_abbr>/<string:variable>')
    api.add_resource(offenses.OffensesCountAgencies,
                     '/offenses/count/agencies/<string:ori>/<string:variable>')


    api.add_resource(offenders.OffendersCountNational,
                     '/offenders/count/national/<string:variable>')
    api.add_resource(offenders.OffendersCountStates,
                     '/offenders/count/states/<int:state_id>/<string:variable>',
                     '/offenders/count/states/<string:state_abbr>/<string:variable>')

    api.add_resource(victims.VictimsCountNational,
                     '/victims/count/national/<string:variable>')
    api.add_resource(victims.VictimsCountStates,
                     '/victims/count/states/<int:state_id>/<string:variable>',
                     '/victims/count/states/<string:state_abbr>/<string:variable>')
    api.add_resource(offenders.OffendersCountAgencies,
                     '/offenders/count/agencies/<string:ori>/<string:variable>')
    api.add_resource(victims.VictimsCountAgencies,
                     '/victims/count/agencies/<string:ori>/<string:variable>')

    api.add_resource(cargo_theft.CargoTheftsCountNational,
                     '/ct/count/national/<string:variable>')
    api.add_resource(cargo_theft.CargoTheftsCountAgencies,
                     '/ct/count/agencies/<string:ori>/<string:variable>')
    api.add_resource(cargo_theft.CargoTheftsCountStates,
                     '/ct/count/states/<int:state_id>/<string:variable>',
                     '/ct/count/states/<string:state_abbr>/<string:variable>')

    api.add_resource(hate_crime.HateCrimesCountNational,
                     '/hc/count/national/<string:variable>')
    api.add_resource(hate_crime.HateCrimesCountAgencies,
                     '/hc/count/agencies/<string:ori>/<string:variable>')
    api.add_resource(hate_crime.HateCrimesCountStates,
                     '/hc/count/states/<int:state_id>/<string:variable>',
                     '/hc/count/states/<string:state_abbr>/<string:variable>')

    api.add_resource(human_traffic.HtAgencyList,
                     '/ht/agencies')
    api.add_resource(human_traffic.HtStatesList,
                     '/ht/states')

    api.add_resource(victims.VictimOffenseSubcounts,
                     '/victims/count/states/<int:state_id>/<string:variable>/offenses',
                     '/victims/count/states/<string:state_abbr>/<string:variable>/offenses',
                     '/victims/count/agencies/<string:ori>/<string:variable>/offenses',
                     '/victims/count/national/<string:variable>/offenses')
    api.add_resource(offenders.OffenderOffenseSubcounts,
                     '/offenders/count/states/<int:state_id>/<string:variable>/offenses',
                     '/offenders/count/states/<string:state_abbr>/<string:variable>/offenses',
                     '/offenders/count/agencies/<string:ori>/<string:variable>/offenses',
                     '/offenders/count/national/<string:variable>/offenses')
    api.add_resource(offenses.OffenseByOffenseTypeSubcounts,
                     '/offenses/count/states/<int:state_id>/<string:variable>/offenses',
                     '/offenses/count/states/<string:state_abbr>/<string:variable>/offenses',
                     '/offenses/count/agencies/<string:ori>/<string:variable>/offenses',
                     '/offenses/count/national/<string:variable>/offenses')
    api.add_resource(hate_crime.HateCrimeOffenseSubcounts,
                     '/hc/count/states/<int:state_id>/<string:variable>/offenses',
                     '/hc/count/states/<string:state_abbr>/<string:variable>/offenses',
                     '/hc/count/agencies/<string:ori>/<string:variable>/offenses',
                     '/hc/count/national/<string:variable>/offenses')
    api.add_resource(cargo_theft.CargoTheftOffenseSubcounts,
                     '/ct/count/states/<int:state_id>/<string:variable>/offenses',
                     '/ct/count/states/<string:state_abbr>/<string:variable>/offenses',
                     '/ct/count/national/<string:variable>/offenses',
                     '/ct/count/agencies/<string:ori>/<string:variable>/offenses')
