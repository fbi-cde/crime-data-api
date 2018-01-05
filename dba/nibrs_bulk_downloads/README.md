# NIBRS Bulk Download Maker

This is a collection of tasks written in Luigi for downloading CSV
files of the NIBRS tables and packaging them into Zip archives for
uploading to S3.

Luigi is a tool for running tasks that can be spread across multiple
machines or run on a single machine. We can just use its "local
scheduler" to run on a single laptop. Luigi works like make, in that
it looks to see if files already exist and if not, it builds them.

To build files locally, you must do the following:

1. `pip install luigi`
2. Install the [cf service-connect](https://github.com/18F/cf-service-connect) plugin
3. Log in to cloud foundry

Then, you can run it to generate a zip file for a single year

``` sh
PYTHONPATH='.' luigi --module tasks ZipFile --year 2014 --state TN --local-scheduler
```

Luigi will look to see if it needs to create files in the following
directories and download them if it does.

1. `code_tables` this is where I download tables that don't change
   from year to year or from state to state as well as any
   documentation like the NIBRS ERD to be included in the final zip.
2. `data` this is where Luigi will download tables for each state and year
3. `zips` this is where Luigi will package up Zips to be uploaded to S3

## Adding Documentation to the ZIP

To add any files to the zipfiles that will be created, put them in the
`code_tables` directory. A good README would be nice.

## Using a Luigi Daemon

If you want to run more than one worker at a single time, you can
start a `luigid` locally in a directory where it can store some of its
information like so

``` sh
luigid --pidfile luigid.pid --logdir . --state-path luigid.statefile
```

Then if you go to [http://localhost:8082](http://localhost:8082) you
can see the Luigi admin console. This will tell you how tasks are
being executed and also allows you to terminate workers gracefully if
you need to. To run workers, you simply have to invoke luigi without
the `--local-scheduler` argument and they will instead talk to the
daemon to coordinate.

## Replacing Built Files

Let's say that you notice something is wrong in a specific file or a
class of files. There is no argument to tell Luigi to rebuild a file,
so the best bet is often to just delete the offending files and rerun
Luigi's command to rebuild all states (see below). Note that you
probably also need to delete all ZipFiles that might include the
affected files since those would not be rebuilt if they exist (Luigi
is great at rebuilding missing files for dependencies, but there is no
support to forcibly run all downstream workers).

## Uploading to S3

Currently, there is nothing in the Luigi workflow to replace files on
S3. Because I assume that you might want to review the generated files
and zips before uploading them, I just have a separate script called
upload_to_s3.sh that copies the zips to S3.

## Setting the DB_URI environment variable

Right now, the script can use `cf connect-to-service` to run its
queries, but it's much more stable and performant if you instead run
`cf connect-to-service --no-client crime-data-api
crime-data-upload-db` locally in a window and define an environment
variable named `DB_URI` with the value of the postgres database URI
that would be used to connect to the cloud-foundry database.

## Useful Luigi tasks

All of these could be appended to `PYTHONPATH='.' luigi --module tasks ` with
the appropriate arguments.

* `StateFiles --year=2015 --state=WV` build all the needed CSVs for a single state and year
* `ZipFile --year=2015 --state=WV` if no zip exists, run the `StateFiles` task and then make a zip archive of it
* `AllState --state=WV` run the `StateFiles` task for every year a state has participated in NIBRS
* `AllYear --year=2016` run the `StateFiles` task for every state that reported to NIBRS in that year
* `AllStates` run the `AllState` task for every state that has been part of NIBRS
* `AllZips` if the zipfile for a given state/year doesn't already exist, run the `ZipFile` for that state and year

The mappings of NIBRS years to states is defined in a dict at the top of `tasks.py`

Note that through a combination of commands, you can actually handle
complicated data scenarios. For instance, when I needed to load the
2015 and 2016 data to build these tables, I ran the tasks locally by
setting DB_URI to point to a local database on my machine and then
used the `AllYear` task to just focus my data building on 2015 and
2016.
