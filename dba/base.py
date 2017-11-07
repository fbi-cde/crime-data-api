from invoke import task, run
from os import getenv


def check_environment():
    """ Check the environment variable is set correctly. """
    if not getenv('CRIME_DATA_API_DB_URL'):
        print('You must set the CRIME_DATA_API_DB_URL environment variable')
        exit(1)

def run_sql(path):
    check_environment
    out = run('psql $CRIME_DATA_API_DB_URL < tasks/%s > /dev/null' % path, hide='both')
    return out


def create_table(table, path=None):
    check_environment
    print('TABLE %s: ' % table, end='')

    if _table_exists('ref_agency_covered_by_flat'):
        print('SKIP (exists)')
    else:
        if path is None:
            path = '%s.sql' % table

        t1 = time.time()
        run_sql(path)
        t2 = time.time()
        print('DONE (%i secs)' % (t2 - t1))


def table_exists(table):
    check_environment
    if getenv('FORCE'):
        return False

    cmd = "select EXISTS(select 1 from pg_tables WHERE schemaname = current_schema() AND tablename='%s');" % table
    out = run('psql $CRIME_DATA_API_DB_URL -tAc "%s"' % cmd, hide='both')
    return (out.stdout == 't\n')




@task
def scrub_fields(ctx):
    create_table('scrub_private_for_prod')


@task(scrub_fields, default=True)
def all(ctx):
    pass
