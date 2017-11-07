# Temp tables
from invoke import task
from base import create_table


@task
def ten_year_participation(ctx):
    create_table('temp_ten_year_participation')


@task
def nibrs_start_years(ctx):
    create_table('temp_nibrs_start_years')


@task
def agency_reporting(ctx):
    create_table('temp_agency_reporting')


@task
def agency_reporting_nibrs(ctx):
    create_table('temp_agency_reporting_nibrs')


@task
def covering_counts(ctx):
    """ Create the temp_covering_counts table """
    create_table('temp_covering_counts')


@task(agency_reporting)
def agency_sums(ctx):
    """ Create the temp_agency_sums table """
    create_table('temp_agency_sums')


@task(agency_sums)
def agency_sums_by_offense(ctx):
    """ Create the temp_agency_sums_by_offense table """
    create_table('temp_agency_sums_by_offense')


@task(agency_sums)
def agency_sums_aggravated(ctx):
    """ Create the temp_agency_sums_aggravated table """
    create_table('temp_agency_sums_aggravated')


@task(agency_sums)
def agency_sums_by_classification(ctx):
    """ Create the temp_agency_sums_aggravated table """
    create_table('temp_agency_sums_by_classification')


@task
def arson_agency_reporting(ctx):
    """ Create the arson_agency_reporting table """
    create_table('temp_arson_agency_reporting')


@task(arson_agency_reporting)
def arson_agency_sums(ctx):
    """ Create the temp_arson_agency_sums table """
    create_table('temp_arson_agency_sums')
