from invoke import task
from base import run_sql

@task
def count_estimate(ctx):
    """ Load the fast count estimate function """
    run_sql('count_estimate_function.sql')


@task(count_estimate, default=True)
def all(ctx):
    pass
