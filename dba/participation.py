from invoke import task
from base import create_table
import temp
import agencies


@task(temp.agency_reporting, temp.agency_reporting_nibrs, agencies.flat_covered_by_table)
def agencies(ctx):
    """ Create the agency_participation table """
    create_table('agency_participation')


@task(agencies)
def rates(ctx):
    """ Create the participation_rates table """
    create_table('participation_rates')


@task(agencies, rates, default=True)
def all(ctx):
    """ Build all participation tables """
    pass
