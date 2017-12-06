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
