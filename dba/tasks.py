from invoke import Collection, task

import base
import funcs
import temp
import agencies
import participation
import geo
import reta

ns = Collection(base, funcs, temp, agencies, participation, geo, reta)

@task(base, funcs, agencies, participation, geo, reta)
def rebuild_all(ctx):
    print('ALL DONE')
