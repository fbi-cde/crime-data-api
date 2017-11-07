from invoke import task
from base import create_table
from temp import ten_year_participation, nibrs_start_years

@task
def flat_covered_by_table(ctx):
    """ Create the ref_agency_covered_by_flat table """
    create_table('ref_agency_covered_by_flat')


@task(ten_year_participation, nibrs_start_years, flat_covered_by_table, default=True)
def cde_agencies(ctx):
    """ Create the cde_agencies table """
    create_table('cde_agencies')
