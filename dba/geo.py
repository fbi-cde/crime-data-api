from invoke import task
from base import create_table
import participation


@task(participation.rates)
def cde_counties(ctx):
    create_table('cde_counties')


@task(participation.rates)
def cde_states(ctx):
    create_table('cde_states')


@task(cde_counties, cde_states, default=True)
def all(ctx):
    pass
