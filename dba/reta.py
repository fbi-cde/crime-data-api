from invoke import task
from base import create_table
import temp
# import funcs

@task(temp.agency_sums)
def agency_sums_view(ctx):
    create_table('agency_sums_view')


@task(temp.agency_sums_by_classification)
def agency_classification_view(ctx):
    create_table('agency_classification_view')


@task(temp.arson_agency_sums)
def agency_arson_view(ctx):
    create_table('agency_arson_view')
    

@task(temp.agency_sums_by_offense, temp.agency_sums_aggravated, agency_arson_view)
def agency_offenses_view(ctx):
    create_table('agency_offenses_view')


@task(agency_sums_view, agency_classification_view, agency_offenses_view, default=True)
def all(ctx):
    pass
