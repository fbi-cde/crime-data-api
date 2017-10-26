import os
import time
from invoke import task, run


def _run_sql(path):
    out = run('psql $CRIME_DATA_API_DB_URL < tasks/%s > /dev/null' % path, hide='both')
    return out


def _create_table(table, path=None):
    print('TABLE %s: ' % table, end='')

    if _table_exists('ref_agency_covered_by_flat'):
        print('SKIP (exists)')
    else:
        if path is None:
            path = '%s.sql' % table

        t1 = time.time()
        _run_sql(path)
        t2 = time.time()
        print('DONE (%i secs)' % (t2 - t1))


def _table_exists(table):
    if os.getenv('FORCE'):
        return False

    cmd = "select EXISTS(select 1 from pg_tables WHERE schemaname = current_schema() AND tablename='%s');" % table
    out = run('psql $CRIME_DATA_API_DB_URL -tAc "%s"' % cmd, hide='both')
    return (out.stdout == 't\n')


@task
def environment(ctx):
    """ Check the environment variable is set correctly. """
    if not os.getenv('CRIME_DATA_API_DB_URL'):
        print('You must set the CRIME_DATA_API_DB_URL environment variable')
        exit(1)


@task(environment)
def scrub_fields(ctx):
    _create_table('scrub_private_for_prod')


@task(environment)
def count_estimate_function(ctx):
    _create_table('count_estimate_function')


@task(scrub_fields, count_estimate_function)
def setup_database(ctx):
    pass

@task(environment)
def flat_covered_by_table(ctx):
    _create_table('ref_agency_covered_by_flat')


@task(environment)
def temp_ten_year_participation(ctx):
    _create_table('temp_ten_year_participation')


@task(environment)
def temp_nibrs_start_years(ctx):
    _create_table('temp_nibrs_start_years')


@task(environment)
def temp_agency_reporting(ctx):
    _create_table('temp_agency_reporting')


@task(environment)
def temp_agency_reporting_nibrs(ctx):
    _create_table('temp_agency_reporting_nibrs')


@task(temp_ten_year_participation, temp_nibrs_start_years, flat_covered_by_table)
def cde_agencies(ctx):
    _create_table('cde_agencies')


@task(temp_agency_reporting, temp_agency_reporting_nibrs, flat_covered_by_table)
def agency_participation(ctx):
    _create_table('agency_participation')


@task(agency_participation)
def participation_rates(ctx):
    _create_table('participation_rates')


@task(participation_rates)
def cde_counties(ctx):
    _create_table('cde_counties')


@task(participation_rates)
def cde_states(ctx):
    _create_table('cde_states')


@task
def temp_covering_counts(ctx):
    _create_table('temp_covering_counts')


@task(setup_database, cde_agencies, cde_counties, cde_states)
def rebuild_all(ctx):
    print('ALL DONE')
