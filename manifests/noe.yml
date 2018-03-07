applications:
- name: crime-data-api-noe
  memory: 512M
  buildpack: python_buildpack
  host: crime-data-api-noe
  domain: fr.cloud.gov
env:
  FLASK_APP: autoapp.py
  NEW_RELIC_CONFIG_FILE: newrelic.ini
  NEW_RELIC_LOG: stdout
services:
- crime-data-staging-db
- crime-data-api-creds
