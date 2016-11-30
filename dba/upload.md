
Uploading data to cloud.gov
===========================

See https://cloud.gov/docs/apps/s3/

This will upload to `crime-data-api-upload-db`, not to the live app's
database (`crime-data-api-db`).  Once the upload is successful, you can
switch the app to using the uploaded database (see below).

    export APP_NAME=crime-data-api

    # Set up an empty service to hold the S3 bucket and database
    cf create-service s3 basic $APP_NAME-upload-s3
    cf create-service aws-rds aws- basic $APP_NAME-upload-db -c '{"storage": 1024}'

    # edit manifest.yml with both services
    cd dba/upload-app
    cf push $APP_NAME

    # set environment variables for s3
    export S3_CREDENTIALS=`cf env $APP_NAME-upload | tail -n +5 | jq -r '.VCAP_SERVICES.s3 // empty' 2>/dev/null`
    export AWS_ACCESS_KEY_ID=`echo "${S3_CREDENTIALS}" | jq -r .[].credentials.access_key_id`
    export AWS_SECRET_ACCESS_KEY=`echo "${S3_CREDENTIALS}" | jq -r .[].credentials.secret_access_key`
    export BUCKET_NAME=`echo "${S3_CREDENTIALS}" | jq -r .[].credentials.bucket`
    export AWS_DEFAULT_REGION=`echo "${S3_CREDENTIALS}" | jq -r '.[].credentials.region // "us-east-1"'`

    pip install awscli
    aws s3 cp ~/werk/fbi/raw/(your .sql dumpfile) s3://${BUCKET_NAME}/

    cf install-plugin https://github.com/18F/cg-export-db/releases/download/v0.0.2/mac-cg-export-db

    # fake out import-data by exporting the data that does not yet exist on cloud.gov
    cf export-data

    # That created `db.sql` is in the S3 bucket
    aws s3 ls s3://${BUCKET_NAME}

    # Replace it with the real data
    aws s3 cp ~/werk/fbi/raw/cde_pgdump.verysmall.sql s3://${BUCKET_NAME}/db.sql

    # Load that data
    cf import-data

    # View it with psql

    # cf create-service-key $APP_NAME-upload-db EXTERNAL-ACCESS-KEY
    # export DB_SERVICE_KEY="`cf service-key $APP_NAME-upload-db EXTERNAL-ACCESS-KEY`"

    export SERVICE_KEY=`echo $SERVICE_KEY | sed 's/Getting key.*\.\.\. //g'`
    export UPLOAD_DB_URI=`echo $SERVICE_KEY | jq -r .uri`
    export UPLOAD_HOST=`echo $SERVICE_KEY | jq -r .host`

    # Set up an SSH tunnel to allow direct psql access from your machine
    cf ssh -N -L 65432:$UPLOAD_HOST:5432 $APP_NAME-upload
    # Leave that running, switch to another window, and copy $UPLOAD_DB_URI over
    to the new session.

    psql $UPLOAD_DB_URI

    # To try your local copy of the app against the uploaded db,
    # set SQLALCHEMY_DATABASE_URI to the value of $UPLOAD_DB_URI
    # in DevConfig in crime_data/settings.py.
